import 'dart:convert';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:uuid/uuid.dart';

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
  // ponytail: route/elevation/pace/times are now computed dynamically from rawFixes
  // via the GpsPipeline to support post-session reprocessing.
  final List<RawFix> rawFixes;
  final List<PipelineResult> _pipelineResults; // Cached

  RunRecord({
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
  }) : _pipelineResults = GpsPipeline(profile: ActivityProfile.run).reprocess(rawFixes);

  List<LatLng> get route => _pipelineResults.where((r) => r.isAccepted).map((r) => LatLng(r.smoothedLat ?? r.raw.lat, r.smoothedLng ?? r.raw.lng)).toList();
  List<double> get elevation => _pipelineResults.where((r) => r.isAccepted).map((r) => r.raw.elevation).toList();
  List<double> get pace => _pipelineResults.where((r) => r.isAccepted).map((r) => r.raw.speedMps > 0.3 ? 1000 / (r.raw.speedMps * 60) : 0.0).toList();
  List<DateTime> get times => _pipelineResults.where((r) => r.isAccepted).map((r) => r.raw.timestamp).toList();

  double get avgPaceMinPerKm =>
      distanceM > 0 ? (durationMs / 60000) / (distanceM / 1000) : 0;

  factory RunRecord.fromJson(Map<String, dynamic> j) => RunRecord(
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
        rawFixes: j['rawFixes'] != null
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
              ),
      );

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

  static String newId() => const Uuid().v4();
}

/// Build a [RunRecord] from a finished tracking session.
RunRecord runRecordFromSession({
  required List<TrackPoint> trackPoints,
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
  return RunRecord(
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
  );
}

String encodeRunRecord(RunRecord r) => jsonEncode(r.toJson());
