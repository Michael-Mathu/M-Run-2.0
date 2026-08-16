import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:gps_pipeline/gps_pipeline.dart';

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
  }) =>
      TrackingState(
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
      );
}

class TrackingModel extends Notifier<TrackingState> {
  final _engine = MwendoGpsEngine();
  final List<TrackPoint> _pts = [];
  final List<RawFix> _rawFixes = [];
  final _pipeline = GpsPipeline(profile: ActivityProfile.run, enableMapMatching: true);
  
  double _elevationGain = 0;
  Timer? _ticker;
  DateTime? _runStart;
  int _accumulatedMs = 0;
  int _accumulatedMovingMs = 0;
  DateTime? _movingStart;
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

  /// Raw GPS points — the source of truth for DB/ GPX/ distance/ SOS.
  List<TrackPoint> get points => _pts;
  
  /// Diagnostic log of every single raw fix.
  List<RawFix> get rawFixes => _rawFixes;

  /// Smoothed, gap-aware segments for the live map polyline.
  List<DisplaySegment> get displaySegments => _displaySegments;

  @override
  TrackingState build() {
    ref.onDispose(() => _ticker?.cancel());
    return TrackingState.initial;
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
      // Moving time only counts when speed > 0.3 m/s
      int movingMs = _accumulatedMovingMs;
      if (_movingStart != null && _pts.isNotEmpty) {
        final lastSpeed = _pts.last.speedMps;
        if (lastSpeed > 0.3) {
          movingMs += DateTime.now().difference(_movingStart!).inMilliseconds;
        }
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
      _movingStart = null;
    }
  }

  File _recoveryFile() {
    // ponytail: a single JSON file is the simplest crash-recovery store; swap
    // for the Drift-backed table when ActivityRepository is migrated.
    final dir = Directory.systemTemp;
    return File(p.join(dir.path, 'mwendo_recovery.json'));
  }

  Future<void> _writeRecovery() async {
    try {
      final data = _pts
          .map((t) => {
                'lat': t.lat,
                'lng': t.lng,
                'elevation': t.elevation,
                'timestamp': t.timestamp.toIso8601String(),
                'speed': t.speedMps,
                'hr': t.heartRate,
                'cadence': t.cadence,
                'accuracy': t.accuracy,
                'hdop': t.hdop,
                'satelliteCount': t.satelliteCount,
                'provider': t.provider,
                'isMocked': t.isMocked,
                'fixType': t.fixType,
              })
          .toList();
      await _recoveryFile().writeAsString(jsonEncode({
        'distanceM': state.distanceM,
        'elapsedMs': state.elapsedMs,
        'movingTimeMs': state.movingTimeMs,
        'elevationGainM': _elevationGain,
        'points': data,
      }));
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
      return (j['points'] as List?)?.isNotEmpty ?? false;
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
      final pts = (j['points'] as List)
              .map((e) => TrackPoint(
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
                    state: 'run',
                  ))
              .toList();
      _pts
        ..clear()
        ..addAll(pts);
      _rawFixes.clear();
      for (final p in pts) {
        _rawFixes.add(RawFix(
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
        ));
      }
      _rebuildDisplay();
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
        if (_pts.isNotEmpty && _pts.last.speedMps > 0.3) {
          _movingStart = DateTime.now();
        }
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
    _movingStart = null;
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

    if (!result.isAccepted) return;

    final isMoving = result.filterStatus == FilterStatus.filtered || result.filterStatus == FilterStatus.gapLong || result.filterStatus == FilterStatus.gapShort;

    if (isMoving && _movingStart == null) {
      _movingStart = DateTime.now();
    } else if (!isMoving && _movingStart != null) {
      _accumulatedMovingMs += DateTime.now().difference(_movingStart!).inMilliseconds;
      _movingStart = null;
    }

    if (_pts.isNotEmpty) {
      final prev = _pts.last;
      final d = _haversine(prev.lat, prev.lng, p.lat, p.lng);
      
      final gained = (p.elevation - prev.elevation);
      if (gained > 0) _elevationGain += gained;
      
      state = state.copyWith(
        state: AppEngineState.recording,
        distanceM: state.distanceM + d,
        paceMinPerKm: p.speedMps > 0 ? 1000 / (p.speedMps * 60) : state.paceMinPerKm,
        heartRate: p.heartRate,
        cadence: p.cadence,
        elevationGainM: _elevationGain,
        pointCount: _pts.length + 1,
      );
    } else {
      state = state.copyWith(
        state: AppEngineState.recording,
        paceMinPerKm: isMoving ? 1000 / (p.speedMps * 60) : 0.0,
        heartRate: p.heartRate,
        cadence: p.cadence,
        elevationGainM: 0,
        pointCount: 1,
      );
    }

    _pts.add(p);
    _addDisplayPoint(p, result);

    if (_pts.length % 10 == 0) {
      _pendingWrite = _writeRecovery();
    }
  }

  void _addDisplayPoint(TrackPoint rawPoint, PipelineResult result) {
    if (!result.isAccepted) return;
    
    final pt = TrackPoint(
      lat: result.smoothedLat ?? result.raw.lat,
      lng: result.smoothedLng ?? result.raw.lng,
      elevation: result.raw.elevation,
      timestamp: result.raw.timestamp,
      speedMps: result.raw.speedMps,
      heartRate: result.raw.heartRate,
      cadence: result.raw.cadence,
      accuracy: result.raw.accuracy,
      hdop: result.raw.hdop,
      satelliteCount: result.raw.satelliteCount,
      provider: result.raw.provider,
      isMocked: result.raw.isMocked,
      fixType: result.raw.fixType,
      state: result.filterStatus.name,
    );

    if (_displaySegments.isEmpty || _displaySegments.last.type != result.filterStatus) {
      _displaySegments.add(DisplaySegment(points: [pt], type: result.filterStatus));
    } else {
      _displaySegments.last.points.add(pt);
    }
  }

  void _rebuildDisplay() {
    _displaySegments.clear();
    final results = _pipeline.reprocess(_rawFixes);
    for (var i = 0; i < results.length; i++) {
      if (results[i].isAccepted && i < _pts.length) {
         _addDisplayPoint(_pts[i], results[i]);
      }
    }
  }

  void pause() => _enqueue(() async {
        _engine.pause();
        _stopTicker();
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

  Future<void> stop() => _enqueue(() async {
        // Await any in-flight recovery write before clearing — prevents
        // the race where _writeRecovery writes after _clearRecovery deletes
        // the file (fixes Bug #8).
        await _pendingWrite;
        _pts.clear(); // Clear points before recovery clear (fixes Bug #7)
        _rawFixes.clear();
        _displaySegments.clear();
        _sub?.cancel();
        _sub = null;
        _stopTicker();
        await _engine.stop();
        await _clearRecovery();
        state = TrackingState.initial;
      });

  /// Serialise commands so rapid start/stop/pause can never interleave.
  /// Exceptions propagate to the caller so corrupt engine state is surfaced
  /// instead of silently swallowed (fixes Bug #2).
  Future<void> _enqueue(Future<void> Function() op) {
    final prev = _lock;
    final completer = Completer<void>();
    _lock = completer.future;
    (prev ?? Future.value()).then((_) async {
      try {
        await op();
        completer.complete();
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