import 'dart:io';
import 'package:test/test.dart';
import 'package:gps_pipeline/gps_pipeline.dart';

import 'utils/ndjson_helper.dart';

void main() {
  group('Replay Tests', () {
    test('Can ingest ndjson and output results', () {
      final tempDir = Directory.systemTemp.createTempSync('gps_pipeline_test');
      final fixturePath = '${tempDir.path}/sample_run.ndjson';

      final t0 = DateTime.utc(2025, 1, 1, 12, 0, 0);
      final fixes = [
        RawFix(
            lat: 0,
            lng: 0,
            elevation: 10,
            timestamp: t0,
            speedMps: 2.0,
            accuracy: 5),
        RawFix(
            lat: 0.00005,
            lng: 0,
            elevation: 10,
            timestamp: t0.add(const Duration(seconds: 1)),
            speedMps: 2.0,
            accuracy: 5),
        RawFix(
            lat: 0.00010,
            lng: 0,
            elevation: 10,
            timestamp: t0.add(const Duration(seconds: 2)),
            speedMps: 2.0,
            accuracy: 5),
      ];
      NdjsonHelper.writeFixes(fixturePath, fixes);

      final readFixes = NdjsonHelper.readFixes(fixturePath);
      final pipeline = GpsPipeline(profile: ActivityProfile.run);
      final results = pipeline.reprocess(readFixes);

      expect(results.length, readFixes.length);
      expect(results.last.filterStatus, FilterStatus.filtered);

      tempDir.deleteSync(recursive: true);
    });
  });
}
