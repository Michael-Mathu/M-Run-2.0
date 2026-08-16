import 'dart:math';

class CoordinateUtil {
  static const double _r = 6371000.0; // Earth radius in meters

  static double haversineMetres(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return _r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double bearingDeg(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRad(lon2 - lon1);
    final y = sin(dLon) * cos(_toRad(lat2));
    final x = cos(_toRad(lat1)) * sin(_toRad(lat2)) -
        sin(_toRad(lat1)) * cos(_toRad(lat2)) * cos(dLon);
    return (_toDeg(atan2(y, x)) + 360) % 360;
  }

  /// Convert WGS84 to local ENU (East, North) meters relative to origin.
  /// Uses a flat-earth approximation suitable for short distances (< 50km).
  static (double east, double north) toEnu(
      double originLat, double originLng, double lat, double lng) {
    final dLat = _toRad(lat - originLat);
    final dLng = _toRad(lng - originLng);
    final north = dLat * _r;
    final east = dLng * _r * cos(_toRad(originLat));
    return (east, north);
  }

  /// Convert local ENU (East, North) meters back to WGS84 relative to origin.
  static (double lat, double lng) fromEnu(
      double originLat, double originLng, double east, double north) {
    final dLat = north / _r;
    final lat = originLat + _toDeg(dLat);
    final dLng = east / (_r * cos(_toRad(originLat)));
    final lng = originLng + _toDeg(dLng);
    return (lat, lng);
  }

  static double _toRad(double d) => d * pi / 180;
  static double _toDeg(double r) => r * 180 / pi;
}
