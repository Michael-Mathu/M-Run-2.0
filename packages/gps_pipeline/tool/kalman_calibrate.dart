import 'dart:convert';
import 'dart:io';

import 'package:gps_pipeline/gps_pipeline.dart';

void main() async {
  final rawFile = File('test/fixtures/synthetic_raw.ndjson');
  final truthFile = File('test/fixtures/synthetic_truth.ndjson');

  if (!rawFile.existsSync() || !truthFile.existsSync()) {
    print('Run synthetic_runner.dart first to generate fixtures.');
    return;
  }

  final rawFixes = <RawFix>[];
  for (var line in rawFile.readAsLinesSync()) {
    final j = jsonDecode(line);
    rawFixes.add(RawFix(
      lat: j['lat'],
      lng: j['lng'],
      elevation: j['elevation'],
      timestamp: DateTime.parse(j['timestamp']),
      speedMps: j['speedMps'],
      accuracy: j['accuracy'],
    ));
  }

  final truth = <Map<String, double>>[];
  for (var line in truthFile.readAsLinesSync()) {
    final j = jsonDecode(line);
    truth.add({'lat': j['lat'], 'lng': j['lng']});
  }

  double totalTruthDist = 0;
  for (int i = 0; i < truth.length - 1; i++) {
    totalTruthDist += CoordinateUtil.haversineMetres(truth[i]['lat']!,
        truth[i]['lng']!, truth[i + 1]['lat']!, truth[i + 1]['lng']!);
  }

  print(
      'Loaded ${rawFixes.length} fixes. Truth dist: ${totalTruthDist.toStringAsFixed(1)}m');

  final sigmas = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0];

  print('\nGrid Search Results (motionSigmaMoving):');
  print('Sigma | MeanDev | P95Dev | DistErr% | FilteredDist');
  print('------------------------------------------------------');

  for (final sigma in sigmas) {
    // Removed KalmanFilter.motionSigmaMoving = sigma;
    final pipeline = GpsPipeline(profile: ActivityProfile.run);
    final results = <PipelineResult>[];

    for (final fix in rawFixes) {
      final res = pipeline.process(fix);
      if (res != null && res.isAccepted) {
        results.add(res);
      }
    }

    final flushed = pipeline.flush();
    for (final res in flushed) {
      if (res.isAccepted) results.add(res);
    }

    double filteredDist = 0;
    for (int i = 0; i < results.length - 1; i++) {
      filteredDist += CoordinateUtil.haversineMetres(
          results[i].smoothedLat ?? results[i].raw.lat,
          results[i].smoothedLng ?? results[i].raw.lng,
          results[i + 1].smoothedLat ?? results[i + 1].raw.lat,
          results[i + 1].smoothedLng ?? results[i + 1].raw.lng);
    }

    // Deviation from ground truth
    List<double> deviations = [];
    for (final r in results) {
      final rLat = r.smoothedLat ?? r.raw.lat;
      final rLng = r.smoothedLng ?? r.raw.lng;

      double minDist = double.infinity;
      for (final t in truth) {
        final d =
            CoordinateUtil.haversineMetres(rLat, rLng, t['lat']!, t['lng']!);
        if (d < minDist) minDist = d;
      }
      deviations.add(minDist);
    }

    deviations.sort();
    final meanDev = deviations.isEmpty
        ? 0.0
        : deviations.reduce((a, b) => a + b) / deviations.length;
    final p95Dev = deviations.isEmpty
        ? 0.0
        : deviations[
            (deviations.length * 0.95).floor().clamp(0, deviations.length - 1)];

    final distErrPct =
        (filteredDist - totalTruthDist).abs() / totalTruthDist * 100.0;

    print('${sigma.toStringAsFixed(1).padRight(5)} | '
        '${meanDev.toStringAsFixed(2).padLeft(7)}m | '
        '${p95Dev.toStringAsFixed(2).padLeft(6)}m | '
        '${distErrPct.toStringAsFixed(2).padLeft(7)}% | '
        '${filteredDist.toStringAsFixed(1)}m');
  }
}
