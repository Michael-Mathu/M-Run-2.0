import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';

void main() {
  group('Platform Parity - NormalizedFix Contract', () {
    test('Parses Android-style payload', () {
      final payload = {
        'lat': -1.2921,
        'lng': 36.8219,
        'elevation': 1600.5,
        'timestamp': 1690000000000,
        'speed': 3.2,
        'accuracy': 5.5,
        'verticalAccuracy': 2.0,
        'hdop': null,
        'satelliteCount': 12,
        'provider': 'gps',
        'isMocked': false,
        'fixType': 'unknown',
        'bearing': 45.0,
        'bearingAccuracy': 10.0,
      };

      final fix = NormalizedFix.fromMap(payload);

      expect(fix.lat, -1.2921);
      expect(fix.lng, 36.8219);
      expect(fix.elevation, 1600.5);
      expect(fix.timestamp.millisecondsSinceEpoch, 1690000000000);
      expect(fix.speedMps, 3.2);
      expect(fix.accuracyM, 5.5);
      expect(fix.verticalAccuracyM, 2.0);
      expect(fix.hdop, isNull);
      expect(fix.satelliteCount, 12);
      expect(fix.provider, 'gps');
      expect(fix.isMocked, isFalse);
      expect(fix.bearingDeg, 45.0);
      expect(fix.bearingAccuracyDeg, 10.0);
    });

    test('Parses iOS-style payload', () {
      final payload = {
        'lat': -1.2921,
        'lng': 36.8219,
        'elevation': 1600.5,
        'timestamp': 1690000000000,
        'speed': 2.8,
        'accuracy': 8.0,
        'verticalAccuracy': 4.0,
        'hdop': null,
        'satelliteCount': null,
        'provider': 'gps',
        'isMocked': true,
        'fixType': 'unknown',
        'bearing': 90.0,
        'bearingAccuracy': 15.0,
      };

      final fix = NormalizedFix.fromMap(payload);

      expect(fix.lat, -1.2921);
      expect(fix.lng, 36.8219);
      expect(fix.elevation, 1600.5);
      expect(fix.timestamp.millisecondsSinceEpoch, 1690000000000);
      expect(fix.speedMps, 2.8);
      expect(fix.accuracyM, 8.0);
      expect(fix.verticalAccuracyM, 4.0);
      expect(fix.hdop, isNull);
      expect(fix.satelliteCount, isNull);
      expect(fix.provider, 'gps');
      expect(fix.isMocked, isTrue);
      expect(fix.bearingDeg, 90.0);
      expect(fix.bearingAccuracyDeg, 15.0);
    });

    test('Handles missing optional fields safely', () {
      final payload = {
        'lat': -1.2921,
        'lng': 36.8219,
        'timestamp': 1690000000000,
      };

      final fix = NormalizedFix.fromMap(payload);

      expect(fix.lat, -1.2921);
      expect(fix.lng, 36.8219);
      expect(fix.elevation, 0.0);
      expect(fix.timestamp.millisecondsSinceEpoch, 1690000000000);
      expect(fix.speedMps, 0.0);
      expect(fix.accuracyM, 10.0);
      expect(fix.verticalAccuracyM, isNull);
      expect(fix.hdop, isNull);
      expect(fix.satelliteCount, isNull);
      expect(fix.provider, 'unknown');
      expect(fix.isMocked, isFalse);
      expect(fix.bearingDeg, isNull);
      expect(fix.bearingAccuracyDeg, isNull);
    });
    
    test('Clamps negative speeds to 0', () {
      final payload = {
        'lat': -1.2921,
        'lng': 36.8219,
        'timestamp': 1690000000000,
        'speed': -1.5,
      };

      final fix = NormalizedFix.fromMap(payload);
      expect(fix.speedMps, 0.0);
    });
  });
}
