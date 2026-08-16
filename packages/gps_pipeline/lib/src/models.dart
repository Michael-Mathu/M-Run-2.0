enum ActivityProfile {
  run(maxAccuracyM: 30, maxSpeedMps: 8),
  cycle(maxAccuracyM: 75, maxSpeedMps: 22),
  drive(maxAccuracyM: 100, maxSpeedMps: 55);

  final double maxAccuracyM;
  final double maxSpeedMps;
  const ActivityProfile({required this.maxAccuracyM, required this.maxSpeedMps});
}

enum FilterStatus {
  measured,
  filtered,
  stationary,
  gapShort,
  gapLong,
  rejected,
}

class RawFix {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;
  final double speedMps;
  final int? heartRate;
  final int? cadence;
  final int accuracy;
  final double? hdop;
  final int? satelliteCount;
  final String? provider;
  final bool isMocked;
  final String fixType;

  const RawFix({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
    required this.speedMps,
    this.heartRate,
    this.cadence,
    required this.accuracy,
    this.hdop,
    this.satelliteCount,
    this.provider,
    this.isMocked = false,
    this.fixType = 'unknown',
  });
}

class PipelineResult {
  final RawFix raw;
  final double? smoothedLat;
  final double? smoothedLng;
  final FilterStatus filterStatus;
  final String? rejectReason;
  final double? innovationDistance;

  const PipelineResult({
    required this.raw,
    this.smoothedLat,
    this.smoothedLng,
    required this.filterStatus,
    this.rejectReason,
    this.innovationDistance,
  });

  bool get isAccepted => filterStatus != FilterStatus.rejected;
}
