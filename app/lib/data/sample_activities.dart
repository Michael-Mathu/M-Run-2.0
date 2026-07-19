import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Deterministic sample activity so the detail/list screens have real content
/// to render and chart before the database is wired up.
class SampleActivity {
  final String id;
  final String type;
  final DateTime startedAt;
  final double distanceM;
  final int durationMs;
  final int calories;
  final double elevationGainM;
  final int avgHeartRate;
  final int avgCadence;
  final List<LatLng> route;
  final List<double> elevation; // metres, per sampled point
  final List<double> pace; // min/km, per sampled point
  final List<DateTime> times; // UTC timestamp per sampled point

  SampleActivity({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.distanceM,
    required this.durationMs,
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

  static List<SampleActivity> all() => const ['a1', 'a2', 'a3'].map(forId).toList();

  static SampleActivity forId(String id) {
    final seed = id.hashCode.abs();
    final rnd = Random(seed);
    final baseLat = -1.2921 + (rnd.nextDouble() - 0.5) * 0.02;
    final baseLng = 36.8219 + (rnd.nextDouble() - 0.5) * 0.02;

    const n = 120;
    final route = <LatLng>[];
    final elevation = <double>[];
    final pace = <double>[];
    double lat = baseLat;
    double lng = baseLng;
    double elev = 1600;
    for (int i = 0; i < n; i++) {
      final t = i / n * 2 * pi;
      lat += cos(t + seed) * 0.00018;
      lng += sin(t * 1.3 + seed) * 0.00018;
      elev += sin(t * 2 + seed) * 4;
      route.add(LatLng(lat, lng));
      elevation.add(elev);
      pace.add(5 + 1.5 * sin(t * 3 + seed));
    }

    final distanceM = 3200 + rnd.nextInt(6000).toDouble();
    final durationMs = (distanceM / 1000 * (5.5 * 60000)).round();
    final stepMs = (durationMs / n).round();
    final startedAt = DateTime.now().subtract(Duration(days: seed % 14));
    final times = [
      for (var i = 0; i < n; i++) startedAt.add(Duration(milliseconds: stepMs * i))
    ];
    final elevationGainM = elevation.reduce((a, b) => a > b ? a : b) -
        elevation.reduce((a, b) => a < b ? a : b);
    final calories = (durationMs / 60000 * 11).round();
    final avgHeartRate = 138 + rnd.nextInt(24);
    final types = ['Morning Run', 'Evening Run', 'Long Run'];
    final type = types[seed % types.length];

    return SampleActivity(
      id: id,
      type: type,
      startedAt: startedAt,
      distanceM: distanceM,
      durationMs: durationMs,
      calories: calories,
      elevationGainM: elevationGainM,
      avgHeartRate: avgHeartRate,
      avgCadence: 170 + rnd.nextInt(15),
      route: route,
      elevation: elevation,
      pace: pace,
      times: times,
    );
  }
}
