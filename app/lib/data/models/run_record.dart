import 'dart:convert';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
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
  // ponytail: route/elevation/pace/times are parallel arrays indexed by sample
  // point. They MUST stay the same length and index-aligned — adding a point
  // requires updating all four together (see runRecordFromSession). A future
  // caller that appends to one without the others desyncs every consumer.
  final List<LatLng> route;
  final List<double> elevation; // m, per sampled point
  final List<double> pace; // min/km, per sampled point
  final List<DateTime> times; // UTC timestamp per sampled point

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
    required this.route,
    required this.elevation,
    required this.pace,
    required this.times,
  });

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
        route: j['route'] != null
            ? (j['route'] as List)
                .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
                .toList()
            : [],
        elevation: j['elevation'] != null
            ? (j['elevation'] as List).map((e) => (e as num).toDouble()).toList()
            : [],
        pace: j['pace'] != null
            ? (j['pace'] as List).map((p) => (p as num).toDouble()).toList()
            : [],
        times: j['times'] != null
            ? (j['times'] as List).map((t) => DateTime.parse(t as String)).toList()
            : [],
      );

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
        'route': route.map((p) => [p.latitude, p.longitude]).toList(),
        'elevation': elevation,
        'pace': pace,
        'times': times.map((t) => t.toUtc().toIso8601String()).toList(),
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
  final route = <LatLng>[];
  final elevation = <double>[];
  final pace = <double>[];
  final times = <DateTime>[];
  int hrSum = 0;
  int hrCount = 0;
  for (final p in trackPoints) {
    route.add(LatLng(p.lat, p.lng));
    elevation.add(p.elevation);
    pace.add(p.speedMps > 0.3 ? 1000 / (p.speedMps * 60) : 0.0);
    times.add(p.timestamp);
    if (p.heartRate != null) {
      hrSum += p.heartRate!;
      hrCount++;
    }
  }
  final startedAt = trackPoints.isNotEmpty
      ? trackPoints.first.timestamp
      : DateTime.now();
  assert(route.length == elevation.length &&
      elevation.length == pace.length &&
      pace.length == times.length);
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
    route: route,
    elevation: elevation,
    pace: pace,
    times: times,
  );
}

String encodeRunRecord(RunRecord r) => jsonEncode(r.toJson());
