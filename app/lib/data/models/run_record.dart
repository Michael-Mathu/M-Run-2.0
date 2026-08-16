import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:uuid/uuid.dart';

import '../../features/learn/data/beat_legends.dart';
import '../sample_activities.dart';

/// A completed run persisted on-device (offline-first). Replaces the
/// `SampleActivity` fakes once a user finishes a real recording.
class RunRecord {
  final String id;
  final String type;
  final DateTime startedAt;
  final double distanceM;
  final int durationMs;
  final int movingTimeMs;
  final int calories;
  final double elevationGainM;
  final int avgHeartRate;
  final int avgCadence;
  final List<RawFix> rawFixes;
  final List<PipelineResult> filteredResults;
  final List<PipelineResult>? matchedResults;
  final TrackVersion trackVersion;
  
  final String? ghostId;
  final bool? ghostWon;
  final int? ghostRaceVersion;

  final List<LatLng> route;
  final List<double> elevation;
  final List<double> pace;
  final List<DateTime> times;

  RunRecord._({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.distanceM,
    required this.durationMs,
    required this.movingTimeMs,
    required this.calories,
    required this.elevationGainM,
    required this.avgHeartRate,
    required this.avgCadence,
    required this.rawFixes,
    required this.filteredResults,
    this.matchedResults,
    required this.trackVersion,
    this.ghostId,
    this.ghostWon,
    this.ghostRaceVersion,
  }) : route = filteredResults.where((r) => r.isAccepted).map((r) => LatLng(r.smoothedLat ?? r.raw.lat, r.smoothedLng ?? r.raw.lng)).toList(),
       elevation = filteredResults.where((r) => r.isAccepted).map((r) => r.raw.elevation).toList(),
       pace = filteredResults.where((r) => r.isAccepted).map((r) => r.raw.speedMps > 0.3 ? 1000 / (r.raw.speedMps * 60) : 0.0).toList(),
       times = filteredResults.where((r) => r.isAccepted).map((r) => r.raw.timestamp).toList();

  factory RunRecord.fromFiltered({
    required String id,
    required String type,
    required DateTime startedAt,
    required double distanceM,
    required int durationMs,
    required int movingTimeMs,
    required int calories,
    required double elevationGainM,
    required int avgHeartRate,
    required int avgCadence,
    required List<RawFix> rawFixes,
    required List<PipelineResult> filteredResults,
    List<PipelineResult>? matchedResults,
    required TrackVersion trackVersion,
    String? ghostId,
    bool? ghostWon,
    int? ghostRaceVersion,
  }) {
    return RunRecord._(
      id: id,
      type: type,
      startedAt: startedAt,
      distanceM: distanceM,
      durationMs: durationMs,
      movingTimeMs: movingTimeMs,
      calories: calories,
      elevationGainM: elevationGainM,
      avgHeartRate: avgHeartRate,
      avgCadence: avgCadence,
      rawFixes: rawFixes,
      filteredResults: filteredResults,
      matchedResults: matchedResults,
      trackVersion: trackVersion,
      ghostId: ghostId,
      ghostWon: ghostWon,
      ghostRaceVersion: ghostRaceVersion,
    );
  }

  factory RunRecord.fromLegacy({
    required String id,
    required String type,
    required DateTime startedAt,
    required double distanceM,
    required int durationMs,
    required int movingTimeMs,
    required int calories,
    required double elevationGainM,
    required int avgHeartRate,
    required int avgCadence,
    required List<RawFix> rawFixes,
  }) {
    final fakeFiltered = rawFixes.asMap().entries.map((e) => PipelineResult(
      raw: e.value,
      pointIndex: e.key,
      trackVersion: TrackVersion.deviceLive,
      filterStatus: FilterStatus.filtered,
      smoothedLat: e.value.lat,
      smoothedLng: e.value.lng,
      smoothedSpeedMps: e.value.speedMps,
    )).toList();

    return RunRecord._(
      id: id,
      type: type,
      startedAt: startedAt,
      distanceM: distanceM,
      durationMs: durationMs,
      movingTimeMs: movingTimeMs,
      calories: calories,
      elevationGainM: elevationGainM,
      avgHeartRate: avgHeartRate,
      avgCadence: avgCadence,
      rawFixes: rawFixes,
      filteredResults: fakeFiltered,
      trackVersion: TrackVersion.deviceLive,
    );
  }

  double get avgPaceMinPerKm =>
      distanceM > 0 ? (durationMs / 60000) / (distanceM / 1000) : 0;

  factory RunRecord.fromJson(Map<String, dynamic> j) {
    final rawFixes = j['rawFixes'] != null
            ? (j['rawFixes'] as List).map((rf) => RawFix(
                  lat: (rf['lat'] as num).toDouble(),
                  lng: (rf['lng'] as num).toDouble(),
                  elevation: (rf['elevation'] as num).toDouble(),
                  timestamp: DateTime.parse(rf['timestamp']),
                  speedMps: (rf['speedMps'] as num).toDouble(),
                  accuracy: (rf['accuracy'] as num).toInt(),
                  hdop: rf['hdop'] != null ? (rf['hdop'] as num).toDouble() : null,
                  satelliteCount: rf['satelliteCount'],
                  provider: rf['provider'],
                  isMocked: rf['isMocked'] ?? false,
                  fixType: rf['fixType'],
                )).toList()
            : _synthesizeRawFixes(
                j['route'] as List?,
                j['elevation'] as List?,
                j['pace'] as List?,
                j['times'] as List?,
              );

    final filteredResults = j['filteredResults'] != null
        ? (j['filteredResults'] as List).map((r) => PipelineResult.fromJson(r as Map<String, dynamic>)).toList()
        : GpsPipeline(profile: ActivityProfile.run).reprocess(rawFixes);

    final matchedResults = j['matchedResults'] != null
        ? (j['matchedResults'] as List).map((r) => PipelineResult.fromJson(r as Map<String, dynamic>)).toList()
        : null;

    final trackVersion = j['trackVersion'] != null
        ? TrackVersion.values.firstWhere((e) => e.id == j['trackVersion'], orElse: () => TrackVersion.deviceLive)
        : TrackVersion.kalmanEkf;

    return RunRecord._(
        id: j['id'],
        type: j['type'] ?? 'Run',
        startedAt: DateTime.parse(j['startedAt']),
        distanceM: (j['distanceM'] ?? 0).toDouble(),
        durationMs: j['durationMs'] ?? 0,
        movingTimeMs: j['movingTimeMs'] ?? j['durationMs'] ?? 0,
        calories: j['calories'] ?? 0,
        elevationGainM: (j['elevationGainM'] ?? 0).toDouble(),
        avgHeartRate: j['avgHeartRate'] ?? 0,
        avgCadence: j['avgCadence'] ?? 0,
        rawFixes: rawFixes,
        filteredResults: filteredResults,
        matchedResults: matchedResults,
        trackVersion: trackVersion,
        ghostId: j['ghostId'],
        ghostWon: j['ghostWon'],
        ghostRaceVersion: j['ghostRaceVersion'],
    );
  }

  static List<RawFix> _synthesizeRawFixes(List? route, List? elevation, List? pace, List? times) {
    if (route == null || elevation == null || pace == null || times == null) return [];
    final fixes = <RawFix>[];
    for (int i = 0; i < route.length; i++) {
      final p = route[i];
      final pVal = (pace[i] as num).toDouble();
      final speedMps = pVal > 0 ? 1000 / (pVal * 60) : 0.0;
      fixes.add(RawFix(
        lat: (p[0] as num).toDouble(),
        lng: (p[1] as num).toDouble(),
        elevation: (elevation[i] as num).toDouble(),
        timestamp: DateTime.parse(times[i]),
        speedMps: speedMps,
        accuracy: 10, // synthesized
      ));
    }
    return fixes;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'startedAt': startedAt.toIso8601String(),
        'distanceM': distanceM,
        'durationMs': durationMs,
        'movingTimeMs': movingTimeMs,
        'calories': calories,
        'elevationGainM': elevationGainM,
        'avgHeartRate': avgHeartRate,
        'avgCadence': avgCadence,
        'rawFixes': rawFixes.map((f) => {
              'lat': f.lat,
              'lng': f.lng,
              'elevation': f.elevation,
              'timestamp': f.timestamp.toIso8601String(),
              'speedMps': f.speedMps,
              'accuracy': f.accuracy,
              if (f.hdop != null) 'hdop': f.hdop,
              if (f.satelliteCount != null) 'satelliteCount': f.satelliteCount,
              if (f.provider != null) 'provider': f.provider,
              if (f.isMocked) 'isMocked': f.isMocked,
              if (f.fixType != 'unknown') 'fixType': f.fixType,
            }).toList(),
        'filteredResults': filteredResults.map((r) => r.toJson()).toList(),
        if (matchedResults != null) 'matchedResults': matchedResults!.map((r) => r.toJson()).toList(),
        'trackVersion': trackVersion.id,
        if (ghostId != null) 'ghostId': ghostId,
        if (ghostWon != null) 'ghostWon': ghostWon,
        if (ghostRaceVersion != null) 'ghostRaceVersion': ghostRaceVersion,
      };

  SampleActivity toSampleActivity() => SampleActivity(
        id: id,
        type: type,
        startedAt: startedAt,
        distanceM: distanceM,
        durationMs: durationMs,
        calories: calories,
        elevationGainM: elevationGainM,
        avgHeartRate: avgHeartRate,
        avgCadence: avgCadence,
        route: route,
        elevation: elevation,
        pace: pace,
        times: times,
      );

  /// Converts this local run into an offline [GhostPace] allowing the user
  /// to race against their previous personal effort.
  GhostPace toGhostPace({String? customName}) {
    final distKm = distanceM / 1000.0;
    final totalSec = (durationMs / 1000).round();
    final segCount = distKm >= 5 ? distKm.round() : (distKm * 2).clamp(1, 20).round();
    final splitTime = segCount > 0 ? (totalSec / segCount).toDouble() : totalSec.toDouble();
    final computedSplits = List<double>.filled(segCount > 0 ? segCount : 1, splitTime);

    return GhostPace(
      id: 'local-$id',
      legendSlug: 'eliud-kipchoge',
      name: customName ?? 'My Run (${distKm.toStringAsFixed(2)}km)',
      distanceLabel: '${distKm.toStringAsFixed(1)}km',
      distanceKm: distKm > 0 ? distKm : 1.0,
      splits: computedSplits,
      totalSeconds: totalSec > 0 ? totalSec : 1,
      description: 'Personal offline recording from ${startedAt.toLocal().toString().split('.').first}',
      accent: const Color(0xFF2BB673),
      splitStyle: 'even',
    );
  }

  RunRecord copyWith({
    String? id,
    String? type,
    DateTime? startedAt,
    double? distanceM,
    int? durationMs,
    int? movingTimeMs,
    int? calories,
    double? elevationGainM,
    int? avgHeartRate,
    int? avgCadence,
    List<RawFix>? rawFixes,
    List<PipelineResult>? filteredResults,
    List<PipelineResult>? matchedResults,
    TrackVersion? trackVersion,
    String? ghostId,
    bool? ghostWon,
    int? ghostRaceVersion,
  }) {
    return RunRecord._(
      id: id ?? this.id,
      type: type ?? this.type,
      startedAt: startedAt ?? this.startedAt,
      distanceM: distanceM ?? this.distanceM,
      durationMs: durationMs ?? this.durationMs,
      movingTimeMs: movingTimeMs ?? this.movingTimeMs,
      calories: calories ?? this.calories,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      avgCadence: avgCadence ?? this.avgCadence,
      rawFixes: rawFixes ?? this.rawFixes,
      filteredResults: filteredResults ?? this.filteredResults,
      matchedResults: matchedResults ?? this.matchedResults,
      trackVersion: trackVersion ?? this.trackVersion,
      ghostId: ghostId ?? this.ghostId,
      ghostWon: ghostWon ?? this.ghostWon,
      ghostRaceVersion: ghostRaceVersion ?? this.ghostRaceVersion,
    );
  }

  static String newId() => const Uuid().v4();
}

/// Build a [RunRecord] from a finished tracking session.
RunRecord runRecordFromSession({
  required List<TrackPoint> trackPoints,
  required List<PipelineResult> filteredResults,
  required TrackVersion trackVersion,
  required double distanceM,
  required int durationMs,
  required double elevationGainM,
  required int calories,
  int? avgHeartRate,
  int avgCadence = 0,
  int movingTimeMs = 0,
  String type = 'Run',
}) {
  final rawFixes = <RawFix>[];
  int hrSum = 0;
  int hrCount = 0;
  for (final p in trackPoints) {
    rawFixes.add(RawFix(
      lat: p.lat,
      lng: p.lng,
      elevation: p.elevation,
      timestamp: p.timestamp,
      speedMps: p.speedMps,
      accuracy: p.accuracy,
      hdop: p.hdop,
      satelliteCount: p.satelliteCount,
      provider: p.provider,
      isMocked: p.isMocked,
      fixType: p.fixType,
    ));
    if (p.heartRate != null) {
      hrSum += p.heartRate!;
      hrCount++;
    }
  }
  final startedAt = trackPoints.isNotEmpty
      ? trackPoints.first.timestamp
      : DateTime.now();
  return RunRecord.fromFiltered(
    id: RunRecord.newId(),
    type: type,
    startedAt: startedAt,
    distanceM: distanceM,
    durationMs: durationMs,
    movingTimeMs: movingTimeMs > 0 ? movingTimeMs : durationMs,
    calories: calories,
    elevationGainM: elevationGainM,
    avgHeartRate: avgHeartRate ?? (hrCount > 0 ? (hrSum / hrCount).round() : 0),
    avgCadence: avgCadence,
    rawFixes: rawFixes,
    filteredResults: filteredResults,
    trackVersion: trackVersion,
  );
}

String encodeRunRecord(RunRecord r) => jsonEncode(r.toJson());
