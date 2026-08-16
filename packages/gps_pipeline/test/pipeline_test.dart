import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:test/test.dart';

void main() {
  group('GpsPipeline Tests', () {
    test('Stationary point -> suppressed', () {
      final pipeline = GpsPipeline(profile: ActivityProfile.run);
      final t0 = DateTime.now().subtract(const Duration(minutes: 5));

      // Emit first point, will pass
      var res = pipeline.process(RawFix(lat: 0, lng: 0, elevation: 0, timestamp: t0, speedMps: 0.1, accuracy: 5));
      expect(res?.filterStatus, FilterStatus.filtered);
      
      // Buffer absorbs this one
      pipeline.process(RawFix(lat: 0.00001, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 1)), speedMps: 0.1, accuracy: 5));
      
      // Now this pushes the previous one out
      res = pipeline.process(RawFix(lat: 0.00002, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 2)), speedMps: 0.1, accuracy: 5));
      
      // Moving state, hasn't passed 5s confirm yet
      expect(res?.filterStatus, FilterStatus.filtered);

      // Pass time
      pipeline.process(RawFix(lat: 0.00003, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 7)), speedMps: 0.1, accuracy: 5));
      pipeline.process(RawFix(lat: 0.00004, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 8)), speedMps: 0.1, accuracy: 5));
      res = pipeline.process(RawFix(lat: 0.00005, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 9)), speedMps: 0.1, accuracy: 5));

      // Should be stationary now
      expect(res?.filterStatus, FilterStatus.stationary);
    });

    test('Accuracy > 30m -> rejected', () {
      final pipeline = GpsPipeline(profile: ActivityProfile.run);
      final t0 = DateTime.now().subtract(const Duration(minutes: 5));
      final res = pipeline.process(RawFix(
        lat: 0, lng: 0, elevation: 0, timestamp: t0, speedMps: 1, accuracy: 50
      ));
      expect(res?.filterStatus, FilterStatus.rejected);
      expect(res?.rejectReason, 'poor_accuracy');
    });

    test('Mocked fix -> rejected', () {
      final pipeline = GpsPipeline(profile: ActivityProfile.run);
      final t0 = DateTime.now().subtract(const Duration(minutes: 5));
      final res = pipeline.process(RawFix(
        lat: 0, lng: 0, elevation: 0, timestamp: t0, speedMps: 1, accuracy: 5, isMocked: true
      ));
      expect(res?.filterStatus, FilterStatus.rejected);
      expect(res?.rejectReason, 'mocked_fix');
    });

    test('3-point spike -> caught', () {
      final pipeline = GpsPipeline(profile: ActivityProfile.run);
      final t0 = DateTime.now().subtract(const Duration(minutes: 5));
      
      // A (valid, will be emitted)
      pipeline.process(RawFix(lat: 0, lng: 0, elevation: 0, timestamp: t0, speedMps: 2, accuracy: 5));
      // B (spike - 22m away, under speed limit for 5 seconds, but sharply returns)
      pipeline.process(RawFix(lat: 0.00020, lng: 0, elevation: 0, timestamp: t0.add(const Duration(seconds: 5)), speedMps: 2, accuracy: 5));
      // C (return near A - 0m away)
      final res = pipeline.process(RawFix(lat: 0.00000, lng: 0.00000, elevation: 0, timestamp: t0.add(const Duration(seconds: 10)), speedMps: 2, accuracy: 5));
      
      expect(res?.filterStatus, FilterStatus.rejected);
      expect(res?.rejectReason, '3_point_spike');
    });
  });
}
