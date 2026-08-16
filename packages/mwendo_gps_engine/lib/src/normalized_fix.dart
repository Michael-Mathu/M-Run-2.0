class NormalizedFix {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;
  final double speedMps;
  final double accuracyM;
  final double? verticalAccuracyM;
  final double? hdop;
  final int? satelliteCount;
  final String provider;
  final bool isMocked;
  final String fixType;
  final double? bearingDeg;
  final double? bearingAccuracyDeg;
  
  const NormalizedFix({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
    required this.speedMps,
    required this.accuracyM,
    this.verticalAccuracyM,
    this.hdop,
    this.satelliteCount,
    required this.provider,
    required this.isMocked,
    required this.fixType,
    this.bearingDeg,
    this.bearingAccuracyDeg,
  });

  factory NormalizedFix.fromMap(Map<dynamic, dynamic> map) {
    return NormalizedFix(
      lat: map['lat'] as double,
      lng: map['lng'] as double,
      elevation: map['elevation'] as double? ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int, isUtc: true),
      speedMps: (map['speed'] as double? ?? 0.0).clamp(0.0, double.infinity),
      accuracyM: map['accuracy'] as double? ?? 10.0,
      verticalAccuracyM: map['verticalAccuracy'] as double?,
      hdop: map['hdop'] as double?,
      satelliteCount: map['satelliteCount'] as int?,
      provider: map['provider'] as String? ?? 'unknown',
      isMocked: map['isMocked'] as bool? ?? false,
      fixType: map['fixType'] as String? ?? 'unknown',
      bearingDeg: map['bearing'] as double?,
      bearingAccuracyDeg: map['bearingAccuracy'] as double?,
    );
  }
}
