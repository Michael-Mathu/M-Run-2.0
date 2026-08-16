import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:gps_pipeline/src/coordinate_util.dart';
import 'package:gps_pipeline/src/models.dart';

class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class SyntheticTrace {
  final List<RawFix> noisyFixes;
  final List<LatLng> groundTruth;

  SyntheticTrace(this.noisyFixes, this.groundTruth);
}

final _random = Random(42); // fixed seed for reproducibility

double _nextGaussian() {
  double u1 = _random.nextDouble();
  double u2 = _random.nextDouble();
  return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
}

SyntheticTrace generateSyntheticRun({
  List<LatLng> polyline = const [
    LatLng(-1.2921, 36.8219), // Nairobi
    LatLng(-1.2931, 36.8229),
    LatLng(-1.2941, 36.8210),
    LatLng(-1.2921, 36.8200),
    LatLng(-1.2921, 36.8219), // Loop back
  ],
  double meanSpeed = 3.2,
  double stdDevSpeed = 0.4,
  double outlierProb = 0.03,
  double stationaryClustersPerKm = 1.5,
}) {
  List<RawFix> fixes = [];
  List<LatLng> truth = [];

  double totalDist = 0;
  for (int i = 0; i < polyline.length - 1; i++) {
    totalDist += CoordinateUtil.haversineMetres(polyline[i].lat,
        polyline[i].lng, polyline[i + 1].lat, polyline[i + 1].lng);
  }

  int expectedStationaryStops =
      (totalDist / 1000 * stationaryClustersPerKm).round();
  List<double> stopDistances = List.generate(
      expectedStationaryStops, (_) => _random.nextDouble() * totalDist)
    ..sort();

  double currentDist = 0;
  DateTime currentTime = DateTime.utc(2026, 1, 1, 6, 0, 0); // 6 AM

  int stopIdx = 0;

  for (int i = 0; i < polyline.length - 1; i++) {
    final start = polyline[i];
    final end = polyline[i + 1];
    final segDist =
        CoordinateUtil.haversineMetres(start.lat, start.lng, end.lat, end.lng);

    double segProgress = 0;
    while (segProgress < segDist) {
      double currentSpeed = max(0.5, meanSpeed + _nextGaussian() * stdDevSpeed);

      // Check if we hit a stop
      if (stopIdx < stopDistances.length &&
          currentDist + segProgress >= stopDistances[stopIdx]) {
        // Stop for 10-60 seconds
        int stopSeconds = 10 + _random.nextInt(50);
        for (int s = 0; s < stopSeconds; s++) {
          final pLat =
              start.lat + (end.lat - start.lat) * (segProgress / segDist);
          final pLng =
              start.lng + (end.lng - start.lng) * (segProgress / segDist);
          truth.add(LatLng(pLat, pLng));

          double accuracy = 3.0 + _random.nextDouble() * 12.0; // 3-15m
          // Gaussian noise
          final noiseX = _nextGaussian() * accuracy;
          final noiseY = _nextGaussian() * accuracy;
          final (nLat, nLng) =
              CoordinateUtil.fromEnu(pLat, pLng, noiseX, noiseY);

          fixes.add(RawFix(
            lat: nLat,
            lng: nLng,
            elevation: 1600.0,
            timestamp: currentTime,
            speedMps: _random.nextDouble() * 0.5, // GPS jitter speed
            accuracy: accuracy.round(),
          ));
          currentTime = currentTime.add(const Duration(seconds: 1));
        }
        stopIdx++;
      }

      final pLat = start.lat + (end.lat - start.lat) * (segProgress / segDist);
      final pLng = start.lng + (end.lng - start.lng) * (segProgress / segDist);
      truth.add(LatLng(pLat, pLng));

      double accuracy = 3.0 + _random.nextDouble() * 12.0; // 3-15m
      double outLat = pLat;
      double outLng = pLng;

      if (_random.nextDouble() < outlierProb) {
        // Outlier 20-200m
        double spikeDist = 20.0 + _random.nextDouble() * 180.0;
        double spikeAngle = _random.nextDouble() * 2 * pi;
        final dx = spikeDist * cos(spikeAngle);
        final dy = spikeDist * sin(spikeAngle);
        final res = CoordinateUtil.fromEnu(pLat, pLng, dx, dy);
        outLat = res.$1;
        outLng = res.$2;
        accuracy = 20.0 + _random.nextDouble() * 50.0; // worse accuracy
      } else {
        final noiseX = _nextGaussian() * accuracy;
        final noiseY = _nextGaussian() * accuracy;
        final res = CoordinateUtil.fromEnu(pLat, pLng, noiseX, noiseY);
        outLat = res.$1;
        outLng = res.$2;
      }

      fixes.add(RawFix(
        lat: outLat,
        lng: outLng,
        elevation: 1600.0,
        timestamp: currentTime,
        speedMps: currentSpeed,
        accuracy: accuracy.round(),
      ));

      segProgress += currentSpeed; // 1 second step
      currentTime = currentTime.add(const Duration(seconds: 1));
    }
    currentDist += segDist;
  }

  return SyntheticTrace(fixes, truth);
}

void main() async {
  final trace = generateSyntheticRun();

  final rawFile = File('test/fixtures/synthetic_raw.ndjson');
  final truthFile = File('test/fixtures/synthetic_truth.ndjson');

  if (!rawFile.parent.existsSync()) {
    rawFile.parent.createSync(recursive: true);
  }

  final rawSink = rawFile.openWrite();
  for (var f in trace.noisyFixes) {
    rawSink.writeln(jsonEncode({
      'lat': f.lat,
      'lng': f.lng,
      'elevation': f.elevation,
      'timestamp': f.timestamp.toIso8601String(),
      'speedMps': f.speedMps,
      'accuracy': f.accuracy,
    }));
  }
  await rawSink.close();

  final truthSink = truthFile.openWrite();
  for (var t in trace.groundTruth) {
    truthSink.writeln(jsonEncode(t.toJson()));
  }
  await truthSink.close();

  print('Generated ${trace.noisyFixes.length} points.');
}
