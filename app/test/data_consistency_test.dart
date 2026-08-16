import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_app/data/gpx_export.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:gps_pipeline/gps_pipeline.dart';

void main() {
  test('Data consistency between live controller, RunRecord, and GPX', () {
    final rawFixes = [
      RawFix(lat: 0.0, lng: 0.0, elevation: 10, timestamp: DateTime(2026), speedMps: 2.0, accuracy: 5, provider: 'gps', fixType: '3d'),
      RawFix(lat: 0.0001, lng: 0.0, elevation: 10, timestamp: DateTime(2026).add(const Duration(seconds: 1)), speedMps: 2.0, accuracy: 5, provider: 'gps', fixType: '3d'),
      RawFix(lat: 0.0002, lng: 0.0, elevation: 10, timestamp: DateTime(2026).add(const Duration(seconds: 2)), speedMps: 2.0, accuracy: 5, provider: 'gps', fixType: '3d'),
    ];

    final pipeline = GpsPipeline(profile: ActivityProfile.run);
    final results = <PipelineResult>[];
    for (final f in rawFixes) {
      final r = pipeline.process(f);
      if (r != null) results.add(r);
    }
    results.addAll(pipeline.flush());

    final record = RunRecord.fromFiltered(
      id: 'test_123',
      type: 'run',
      startedAt: rawFixes.first.timestamp,
      distanceM: 22.2, // Simulated live distance
      durationMs: 2000,
      movingTimeMs: 2000,
      calories: 10,
      elevationGainM: 0,
      avgHeartRate: 0,
      avgCadence: 0,
      rawFixes: rawFixes,
      filteredResults: results,
      trackVersion: TrackVersion.kalmanEkf,
    );

    // 1. live distance == RunRecord.distanceM
    expect(record.distanceM, 22.2);

    // 2. RunRecord.route matches filteredResults exact coords
    final acceptedResults = results.where((r) => r.isAccepted).toList();
    expect(record.route.length, acceptedResults.length);
    for (int i = 0; i < record.route.length; i++) {
      expect(record.route[i].latitude, acceptedResults[i].smoothedLat ?? acceptedResults[i].raw.lat);
      expect(record.route[i].longitude, acceptedResults[i].smoothedLng ?? acceptedResults[i].raw.lng);
    }

    // 3. gpx_export matches RunRecord.route
    final gpxStr = gpxFromRunRecord(record);
    final parsedGpx = pointsFromGpx(gpxStr);
    
    expect(parsedGpx.length, record.route.length);
    for (int i = 0; i < parsedGpx.length; i++) {
      expect(parsedGpx[i].lat, record.route[i].latitude);
      expect(parsedGpx[i].lng, record.route[i].longitude);
    }
  });
}
