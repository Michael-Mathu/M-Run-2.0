import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../data/models/run_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:mwendo_app/data/models/session_draft.dart';
import 'package:mwendo_app/data/repositories/session_draft_repository.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:mwendo_app/features/tracking/map_match_job.dart';
enum AppEngineState { idle, recording, paused, recovering }

class DisplaySegment {
  final List<TrackPoint> points;
  final FilterStatus type;
  
  const DisplaySegment({required this.points, required this.type});
}

class TrackingState {
  final AppEngineState state;
  final double distanceM;
  final int elapsedMs;
  final int movingTimeMs;
  final double paceMinPerKm; // 0 = unknown
  final int? heartRate;
  final int? cadence;
  final double elevationGainM;
  final int calories;
  final int pointCount; // lightweight signal for UI, avoids copying _pts every tick
  final double currentAccuracy; // latest GPS accuracy for readiness indicator
  final DateTime? lastPointTime; // time of the last received GPS point
  final ActivityProfile profile;

  const TrackingState({
    required this.state,
    this.distanceM = 0,
    this.elapsedMs = 0,
    this.movingTimeMs = 0,
    this.paceMinPerKm = 0,
    this.heartRate,
    this.cadence,
    this.elevationGainM = 0,
    this.calories = 0,
    this.pointCount = 0,
    this.currentAccuracy = double.infinity,
    this.lastPointTime,
    this.profile = ActivityProfile.run,
  });

  static const initial = TrackingState(state: AppEngineState.idle);

  TrackingState copyWith({
    AppEngineState? state,
    double? distanceM,
    int? elapsedMs,
    int? movingTimeMs,
    double? paceMinPerKm,
    int? heartRate,
    int? cadence,
    double? elevationGainM,
    int? calories,
    int? pointCount,
    double? currentAccuracy,
    DateTime? lastPointTime,
    ActivityProfile? profile,
  }) {
    return TrackingState(
        state: state ?? this.state,
        distanceM: distanceM ?? this.distanceM,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        movingTimeMs: movingTimeMs ?? this.movingTimeMs,
        paceMinPerKm: paceMinPerKm ?? this.paceMinPerKm,
        heartRate: heartRate ?? this.heartRate,
        cadence: cadence ?? this.cadence,
        elevationGainM: elevationGainM ?? this.elevationGainM,
        calories: calories ?? this.calories,
        pointCount: pointCount ?? this.pointCount,
        currentAccuracy: currentAccuracy ?? this.currentAccuracy,
        lastPointTime: lastPointTime ?? this.lastPointTime,
        profile: profile ?? this.profile,
      );
  }
}

class TrackingModel extends Notifier<TrackingState> {
  final _engine = MwendoGpsEngine();
  final List<TrackPoint> _pts = [];
  final List<RawFix> _rawFixes = [];
  late GpsPipeline _pipeline;
  
  double _elevationGain = 0;
  Timer? _ticker;
  DateTime? _runStart;
  int _accumulatedMs = 0;
  int _accumulatedMovingMs = 0;
  DateTime? _lastPtWallClock;
  StreamSubscription<TrackPoint>? _sub;

  // ponytail: the live map polyline is decoupled from the raw GPS stream.
  // Raw points remain the source of truth (DB / GPX / distance / SOS); the
  // pipeline-smoothed _displaySegments is what the map actually draws.
  final List<DisplaySegment> _displaySegments = [];

  /// Serial command queue — prevents start/stop/pause race conditions during
  // rapid pause/resume cycles (blueprint: "lock start/stop commands").
  Future<void>? _lock;

  /// Tracks the most recent recovery write future so `stop()` can await it
  /// before clearing, preventing a stale write from resurrecting a ghost run.
  Future<void>? _pendingWrite;

  /// Accepted GPS points — the source of truth for DB/ GPX/ distance/ SOS.
  List<TrackPoint> get points => _pts;
  
  /// Diagnostic log of every single raw fix.
  List<RawFix> get rawFixes => _rawFixes;

  /// Smoothed, gap-aware segments for the live map polyline.
  List<DisplaySegment> get displaySegments => _displaySegments;

  @override
  TrackingState build() {
    _pipeline = GpsPipeline(profile: ActivityProfile.run);
    ref.onDispose(() => _ticker?.cancel());
    return TrackingState.initial;
  }

  void setProfile(ActivityProfile profile) {
    _pipeline = GpsPipeline(profile: profile);
    state = state.copyWith(profile: profile);
  }

  /// Drives `elapsedMs` from the wall clock so the timer ticks live regardless
  /// of GPS quality. GPS only feeds distance/pace; the clock is independent.
  void _startTicker() {
    _runStart = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_runStart == null) return;
      final total =
          _accumulatedMs + DateTime.now().difference(_runStart!).inMilliseconds;
      // Moving time only counts exact GPS deltas. We add an optimistic live tick
      // capped at 10s so the UI feels live between 1hz updates.
      int movingMs = _accumulatedMovingMs;
      if (_pts.isNotEmpty && _pts.last.state == FilterStatus.filtered.name && _lastPtWallClock != null) {
        final liveDelta = DateTime.now().difference(_lastPtWallClock!).inMilliseconds;
        movingMs += min(liveDelta, 10000);
      }
      state = state.copyWith(
        elapsedMs: total,
        movingTimeMs: movingMs,
        calories: (movingMs / 60000 * 11).round(),
      );
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (_runStart != null) {
      _accumulatedMs += DateTime.now().difference(_runStart!).inMilliseconds;
      _runStart = null;
      // Persist current moving time before clearing the moving timer
      _accumulatedMovingMs = state.movingTimeMs;
      _lastPtWallClock = null;
    }
  }

  String? _draftId;

  File _recoveryFile() {
    // ponytail: a single JSON file is the simplest crash-recovery store; swap
    // for the Drift-backed table when ActivityRepository is migrated.
    final dir = Directory.systemTemp;
    return File(p.join(dir.path, 'mwendo_recovery.json'));
  }

  Future<void> _writeRecovery() async {
    try {
      if (_draftId == null) return;
      final filtered = _pipeline.reprocess(_rawFixes);
      final draft = SessionDraft(
        id: _draftId!,
        rawFixes: _rawFixes.toList(growable: false),
        filteredResults: filtered,
        filterVersion: _pipeline.trackVersion,
        filteredDistanceM: state.distanceM,
        durationMs: state.elapsedMs,
        movingTimeMs: state.movingTimeMs,
        elevationGainM: _elevationGain,
        calories: state.calories,
        status: PostProcessingStatus.pending,
        qualityReport: SessionQualityReport.compute(filtered),
        activityType: state.profile,
        createdAt: _rawFixes.isNotEmpty ? _rawFixes.first.timestamp : DateTime.now(),
      );
      await ref.read(sessionDraftRepositoryProvider).saveDraft(draft);
    } catch (_) {
      // offline-first: best-effort recovery snapshot
    }
  }

  Future<void> _clearRecovery() async {
    try {
      final f = _recoveryFile();
      if (await f.exists()) await f.delete();
    } catch (e) {
      // Log but don't crash - recovery file may be locked by antivirus/etc.
      // Will be cleaned up on next successful run.
    }
  }

  /// True if a previously interrupted run was found on disk.
  Future<bool> hasRecoverableRun() async {
    try {
      final f = _recoveryFile();
      if (!await f.exists()) return false;
      final raw = await f.readAsString();
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (j['rawFixes'] as List?)?.isNotEmpty ?? (j['points'] as List?)?.isNotEmpty ?? false;
    } catch (_) {
      return false;
    }
  }

/// Load an interrupted run from disk and resume it in a `recovering` state.
  Future<void> restoreInterrupted() async {
    try {
      final f = _recoveryFile();
      if (!await f.exists()) return;
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      
      final fixesList = (j['rawFixes'] as List?) ?? (j['points'] as List?) ?? [];
      
      final pts = fixesList
              .map((e) => RawFix(
                    lat: (e['lat'] as num).toDouble(),
                    lng: (e['lng'] as num).toDouble(),
                    elevation: (e['elevation'] as num).toDouble(),
                    timestamp: DateTime.parse(e['timestamp'] as String),
                    speedMps: (e['speed'] as num).toDouble(),
                    heartRate: e['hr'] as int?,
                    cadence: e['cadence'] as int?,
                    accuracy: (e['accuracy'] as num?)?.toInt() ?? 0,
                    hdop: (e['hdop'] as num?)?.toDouble(),
                    satelliteCount: e['satelliteCount'] as int?,
                    provider: e['provider'] as String?,
                    isMocked: e['isMocked'] as bool? ?? false,
                    fixType: e['fixType'] as String? ?? 'unknown',
                  ))
              .toList();

      _rawFixes
        ..clear()
        ..addAll(pts);

      _pts.clear();
      _displaySegments.clear();
      _pipeline.reset();
      
      // Reconstruct filtered points silently
      for (final p in _rawFixes) {
        final r = _pipeline.process(p);
        if (r != null) {
          final acceptedPt = TrackPoint(
            raw: NormalizedFix(
              lat: r.smoothedLat ?? r.raw.lat,
              lng: r.smoothedLng ?? r.raw.lng,
              elevation: p.elevation,
              timestamp: p.timestamp,
              speedMps: p.speedMps,
              accuracyM: p.accuracy.toDouble(),
              hdop: p.hdop,
              satelliteCount: p.satelliteCount,
              provider: p.provider ?? 'unknown',
              isMocked: p.isMocked,
              fixType: p.fixType,
            ),
            heartRate: p.heartRate,
            cadence: p.cadence,
            state: r.filterStatus.name,
          );
          if (r.isAccepted) {
            _pts.add(acceptedPt);
            _addDisplayPoint(acceptedPt, r);
          }
        }
      }
      
      for (final r in _pipeline.flush()) {
        if (r.isAccepted) {
          final p = r.raw;
          final acceptedPt = TrackPoint(
            raw: NormalizedFix(
              lat: r.smoothedLat ?? r.raw.lat,
              lng: r.smoothedLng ?? r.raw.lng,
              elevation: p.elevation,
              timestamp: p.timestamp,
              speedMps: p.speedMps,
              accuracyM: p.accuracy.toDouble(),
              hdop: p.hdop,
              satelliteCount: p.satelliteCount,
              provider: p.provider ?? 'unknown',
              isMocked: p.isMocked,
              fixType: p.fixType,
            ),
            heartRate: p.heartRate,
            cadence: p.cadence,
            state: r.filterStatus.name,
          );
          _pts.add(acceptedPt);
          _addDisplayPoint(acceptedPt, r);
        }
      }
      _pipeline.reset();

      _elevationGain = (j['elevationGainM'] as num?)?.toDouble() ?? 0;
      _accumulatedMs = (j['elapsedMs'] as num?)?.toInt() ?? 0;
      _accumulatedMovingMs = (j['movingTimeMs'] as num?)?.toInt() ?? 0;
      state = state.copyWith(
        state: AppEngineState.recovering,
        distanceM: (j['distanceM'] as num?)?.toDouble() ?? 0,
        elapsedMs: (j['elapsedMs'] as num?)?.toInt() ?? 0,
        movingTimeMs: (j['movingTimeMs'] as num?)?.toInt() ?? 0,
        elevationGainM: _elevationGain,
        pointCount: _pts.length,
      );
    } catch (_) {
      // corrupt snapshot — ignore
    }
  }

  Future<void> start() => _enqueue(() => _start());

  Future<void> _start() async {
    // If a previous run was interrupted, continue from where we left off.
    if (await hasRecoverableRun()) {
      await restoreInterrupted();
      if (state.state == AppEngineState.recovering) {
        // restoreInterrupted() only loads the saved points/state. The engine is
        // started here (and only here, via the permission-gated start/resume
        // path) so a recovered run actually records (fixes C3) without ever
        // auto-starting GPS on page load — which crashed when location
        // permission wasn't granted yet.
        _sub?.cancel();
        _sub = _engine.startRecording().listen(
          _onPoint,
          onError: (e, st) {
            debugPrint('GPS stream error during recovery: $e');
          },
        );
        _startTicker();
        state = state.copyWith(state: AppEngineState.recording);
        return;
      }
    }
    _pts.clear();
    _rawFixes.clear();
    _displaySegments.clear();
    _elevationGain = 0;
    _accumulatedMs = 0;
    _accumulatedMovingMs = 0;
    _lastPtWallClock = null;
    _draftId = RunRecord.newId();
    state = state.copyWith(
      state: AppEngineState.recording,
      distanceM: 0,
      elapsedMs: 0,
      movingTimeMs: 0,
      paceMinPerKm: 0,
      heartRate: null,
      cadence: null,
      elevationGainM: 0,
      calories: 0,
      pointCount: 0,
    );
    _startTicker();
    _sub?.cancel();
    _sub = _engine.startRecording().listen(
      _onPoint,
      onError: (e, st) {
        // Stream errors (e.g., SecurityException after fresh permission grant)
        // must be handled instead of crashing the app.
        debugPrint('GPS stream error: $e');
      },
    );
  }

  void _onPoint(TrackPoint p) {
    final raw = RawFix(
      lat: p.lat,
      lng: p.lng,
      elevation: p.elevation,
      timestamp: p.timestamp,
      speedMps: p.speedMps,
      heartRate: p.heartRate,
      cadence: p.cadence,
      accuracy: p.accuracy,
      hdop: p.hdop,
      satelliteCount: p.satelliteCount,
      provider: p.provider,
      isMocked: p.isMocked,
      fixType: p.fixType,
    );
    _rawFixes.add(raw);

    final result = _pipeline.process(raw);
    if (result == null) return; // buffered

    _handleResult(result, p);
  }

  void _handleResult(PipelineResult result, [TrackPoint? originalPt]) {
    if (!result.isAccepted) {
        // ponytail: diagnostics only. Do not accumulate distance or pace.
        return;
    }

    final isFiltered = result.filterStatus == FilterStatus.filtered;

    final smoothedLat = result.smoothedLat ?? result.raw.lat;
    final smoothedLng = result.smoothedLng ?? result.raw.lng;
    final smoothedSpeed = result.smoothedSpeedMps ?? result.raw.speedMps;

    double d = 0;
    if (_pts.isNotEmpty) {
      final prev = _pts.last;
      d = _haversine(prev.lat, prev.lng, smoothedLat, smoothedLng);
      final gained = (result.raw.elevation - prev.elevation);
      if (gained > 0) _elevationGain += gained;

      if (isFiltered && prev.state == FilterStatus.filtered.name) {
        final deltaMs = result.raw.timestamp.difference(prev.timestamp).inMilliseconds;
        if (deltaMs > 0 && deltaMs <= 10000) {
          _accumulatedMovingMs += deltaMs;
        }
      }
    }
    
    _lastPtWallClock = DateTime.now();

    state = state.copyWith(
      state: AppEngineState.recording,
      distanceM: state.distanceM + d,
      paceMinPerKm: (isFiltered && smoothedSpeed > 0) ? 1000 / (smoothedSpeed * 60) : state.paceMinPerKm,
      heartRate: originalPt?.heartRate ?? result.raw.heartRate,
      cadence: originalPt?.cadence ?? result.raw.cadence,
      elevationGainM: _elevationGain,
      pointCount: _pts.length + 1,
      currentAccuracy: result.raw.accuracy.toDouble(),
      lastPointTime: DateTime.now(),
    );

    // ponytail: Store the smoothed/accepted coordinates in the points array
    // so that later downstream clients don't accidentally compute distance on raw.
    final acceptedPt = TrackPoint(
      raw: NormalizedFix(
        lat: smoothedLat,
        lng: smoothedLng,
        elevation: originalPt?.elevation ?? result.raw.elevation,
        timestamp: originalPt?.timestamp ?? result.raw.timestamp,
        speedMps: originalPt?.speedMps ?? result.raw.speedMps,
        accuracyM: (originalPt?.accuracy ?? result.raw.accuracy).toDouble(),
        hdop: originalPt?.hdop ?? result.raw.hdop,
        satelliteCount: originalPt?.satelliteCount ?? result.raw.satelliteCount,
        provider: originalPt?.provider ?? result.raw.provider ?? 'unknown',
        isMocked: originalPt?.isMocked ?? result.raw.isMocked,
        fixType: originalPt?.fixType ?? result.raw.fixType,
      ),
      heartRate: originalPt?.heartRate ?? result.raw.heartRate,
      cadence: originalPt?.cadence ?? result.raw.cadence,
      state: originalPt?.state ?? result.filterStatus.name,
    );
    _pts.add(acceptedPt);
    _addDisplayPoint(acceptedPt, result);

    if (_pts.length % 10 == 0) {
      _pendingWrite = _writeRecovery();
    }
  }

  void _addDisplayPoint(TrackPoint rawPoint, PipelineResult result) {
    if (!result.isAccepted) return;
    
    final pt = TrackPoint(
      raw: NormalizedFix(
        lat: result.smoothedLat ?? result.raw.lat,
        lng: result.smoothedLng ?? result.raw.lng,
        elevation: result.raw.elevation,
        timestamp: result.raw.timestamp,
        speedMps: result.raw.speedMps,
        accuracyM: result.raw.accuracy.toDouble(),
        hdop: result.raw.hdop,
        satelliteCount: result.raw.satelliteCount,
        provider: result.raw.provider ?? 'unknown',
        isMocked: result.raw.isMocked,
        fixType: result.raw.fixType,
      ),
      heartRate: result.raw.heartRate,
      cadence: result.raw.cadence,
      state: result.filterStatus.name,
    );

    if (_displaySegments.isEmpty || _displaySegments.last.type != result.filterStatus) {
      _displaySegments.add(DisplaySegment(points: [pt], type: result.filterStatus));
    } else {
      _displaySegments.last.points.add(pt);
    }
  }



  RunRecord buildRunRecord(String type, {String? ghostId, bool? ghostWon, int? ghostRaceVersion}) {
    final results = _pipeline.reprocess(_rawFixes);
    final rawFixes = _rawFixes.toList(growable: false);
    
    int hrSum = 0, hrCount = 0, cadenceSum = 0, cadenceCount = 0;
    for (final p in rawFixes) {
      if (p.heartRate != null) { hrSum += p.heartRate!; hrCount++; }
      if (p.cadence != null) { cadenceSum += p.cadence!; cadenceCount++; }
    }

    double finalDistanceM = 0;
    PipelineResult? prev;
    for (final r in results) {
      if (r.filterStatus == FilterStatus.filtered) {
        if (prev != null) {
          finalDistanceM += _haversine(
            prev.smoothedLat ?? prev.raw.lat,
            prev.smoothedLng ?? prev.raw.lng,
            r.smoothedLat ?? r.raw.lat,
            r.smoothedLng ?? r.raw.lng,
          );
        }
        prev = r;
      }
    }
    
    return RunRecord.fromFiltered(
      id: RunRecord.newId(),
      type: type,
      startedAt: rawFixes.isNotEmpty ? rawFixes.first.timestamp : DateTime.now(),
      distanceM: finalDistanceM,
      durationMs: state.elapsedMs,
      movingTimeMs: state.movingTimeMs > 0 ? state.movingTimeMs : state.elapsedMs,
      calories: state.calories,
      elevationGainM: state.elevationGainM,
      avgHeartRate: hrCount > 0 ? (hrSum / hrCount).round() : 0,
      avgCadence: cadenceCount > 0 ? (cadenceSum / cadenceCount).round() : 0,
      rawFixes: rawFixes,
      filteredResults: results,
      trackVersion: _pipeline.trackVersion,
      ghostId: ghostId,
      ghostWon: ghostWon,
      ghostRaceVersion: ghostRaceVersion,
    );
  }

  void pause() => _enqueue(() async {
        _engine.pause();
        _stopTicker();
        for (final r in _pipeline.flush()) {
          _handleResult(r);
        }
        _pipeline.reset();
        _pendingWrite = _writeRecovery();
        await _pendingWrite;
        state = state.copyWith(state: AppEngineState.paused);
      });

  void resume() => _enqueue(() async {
        // If the engine was never started (e.g. a recovered run the user is
        // resuming from the `recovering` state), begin it through _start()
        // rather than _engine.resume(), which would be a silent no-op.
        if (_sub == null) {
          await _start();
          return;
        }
        _engine.resume();
        _startTicker();
        state = state.copyWith(state: AppEngineState.recording);
      });

  Future<SessionDraft?> stop() => _enqueueWithResult(() async {
        // Await any in-flight recovery write before clearing — prevents
        // the race where _writeRecovery writes after _clearRecovery deletes
        // the file (fixes Bug #8).
        await _pendingWrite;

        _sub?.cancel();
        _sub = null;
        _stopTicker();

        for (final r in _pipeline.flush()) {
          _handleResult(r);
        }
        
        SessionDraft? finalDraft;
        
        if (_draftId != null) {
          final filtered = _pipeline.reprocess(_rawFixes);
          
          double finalDistanceM = 0;
          PipelineResult? prev;
          for (final r in filtered) {
            if (r.filterStatus == FilterStatus.filtered) {
              if (prev != null) {
                finalDistanceM += _haversine(
                  prev.smoothedLat ?? prev.raw.lat,
                  prev.smoothedLng ?? prev.raw.lng,
                  r.smoothedLat ?? r.raw.lat,
                  r.smoothedLng ?? r.raw.lng,
                );
              }
              prev = r;
            }
          }

          final draft = SessionDraft(
            id: _draftId!,
            rawFixes: _rawFixes.toList(growable: false),
            filteredResults: filtered,
            filterVersion: _pipeline.trackVersion,
            filteredDistanceM: finalDistanceM,
            durationMs: state.elapsedMs,
            movingTimeMs: state.movingTimeMs,
            elevationGainM: _elevationGain,
            calories: state.calories,
            status: PostProcessingStatus.pending,
            qualityReport: SessionQualityReport.compute(filtered),
            activityType: state.profile,
            createdAt: _rawFixes.isNotEmpty ? _rawFixes.first.timestamp : DateTime.now(),
          );
          await ref.read(sessionDraftRepositoryProvider).saveDraft(draft);
          
          // Trigger post-session map matching job (fire and forget)
          ref.read(mapMatchJobProvider).processSession(draft).ignore();
          finalDraft = draft;
        }
        _draftId = null;

        _pipeline.reset();

        _pts.clear(); // Clear points before recovery clear (fixes Bug #7)
        _rawFixes.clear();
        _displaySegments.clear();
        await _engine.stop();
        await _clearRecovery();
        state = TrackingState.initial;
        return finalDraft;
      });

  Future<void> discardRecovery() => _enqueue(() async {
        await _clearRecovery();
        _pts.clear();
        _rawFixes.clear();
        _displaySegments.clear();
        state = TrackingState.initial;
      });

  Future<void> _enqueue(Future<void> Function() op) {
    return _enqueueWithResult<void>(() async {
      await op();
    });
  }

  Future<T> _enqueueWithResult<T>(Future<T> Function() op) {
    final prev = _lock;
    final completer = Completer<T>();
    _lock = completer.future;
    (prev ?? Future.value()).then((_) async {
      try {
        final result = await op();
        completer.complete(result);
      } catch (e, st) {
        // If _start() throws (e.g. platform exception from the GPS engine),
        // propagate the error to the caller so it can rollback state, rather
        // than silently leaving the engine in a corrupt "recording" state.
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

final trackingModelProvider = NotifierProvider<TrackingModel, TrackingState>(TrackingModel.new);

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRad(double d) => d * pi / 180;