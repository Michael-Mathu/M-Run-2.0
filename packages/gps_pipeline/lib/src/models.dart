import 'track_version.dart';
export 'track_version.dart';

enum ActivityProfile {
  run(
    maxAccuracyM: 20,
    maxSpeedMps: 12,
    stationarySpeedMps: 0.5,
    spikeMultiplier: 4,
    status: 'Priority — calibrated',
  ),
  walk(
    maxAccuracyM: 25,
    maxSpeedMps: 4,
    stationarySpeedMps: 0.4,
    spikeMultiplier: 3,
    status: 'ponytail: conservative defaults — not yet calibrated',
  ),
  cycle(
    maxAccuracyM: 20,
    maxSpeedMps: 20,
    stationarySpeedMps: 0.5,
    spikeMultiplier: 5,
    status: 'ponytail: conservative defaults — not yet calibrated',
  ),
  drive(
    maxAccuracyM: 30,
    maxSpeedMps: 60,
    stationarySpeedMps: 1.0,
    spikeMultiplier: 6,
    status: 'ponytail: conservative defaults — not yet calibrated',
  ),
  hike(
    maxAccuracyM: 30,
    maxSpeedMps: 6,
    stationarySpeedMps: 0.4,
    spikeMultiplier: 3,
    status: 'ponytail: conservative defaults — not yet calibrated',
  ),
  indoorPoor(
    maxAccuracyM: 50,
    maxSpeedMps: 2,
    stationarySpeedMps: 0.5,
    spikeMultiplier: 2,
    status: 'ponytail: conservative defaults — not yet calibrated',
  );

  final double maxAccuracyM;
  final double maxSpeedMps;
  final double stationarySpeedMps;
  final double spikeMultiplier;
  final String status;

  const ActivityProfile({
    required this.maxAccuracyM,
    required this.maxSpeedMps,
    required this.stationarySpeedMps,
    required this.spikeMultiplier,
    required this.status,
  });
}

enum FilterStatus {
  measured,
  filtered,
  stationary,
  gapShort,
  gapLong,
  rejected,
}

enum RejectReason {
  invalidCoord,
  invalidTimestamp,
  duplicateTimestamp,
  staleTimestamp,
  poorAccuracy,
  zeroAccuracy,
  excessiveSpeed,
  spikeDetected,
  stationary,
  outOfBounds,
  mocked,
  largeInnovation,
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
  final int pointIndex;
  final TrackVersion trackVersion;

  /// The filtered coordinates, null if rejected.
  final double? smoothedLat;
  final double? smoothedLng;
  final double? smoothedSpeedMps;

  final FilterStatus filterStatus;
  final RejectReason? rejectReason;
  final double? innovationDistance;

  PipelineResult({
    required this.raw,
    required this.pointIndex,
    required this.trackVersion,
    this.smoothedLat,
    this.smoothedLng,
    this.smoothedSpeedMps,
    required this.filterStatus,
    this.rejectReason,
    this.innovationDistance,
  });

  PipelineResult copyWith({
    double? smoothedLat,
    double? smoothedLng,
    FilterStatus? filterStatus,
    RejectReason? rejectReason,
    double? innovationDistance,
  }) {
    return PipelineResult(
      raw: raw,
      pointIndex: pointIndex,
      trackVersion: trackVersion,
      smoothedLat: smoothedLat ?? this.smoothedLat,
      smoothedLng: smoothedLng ?? this.smoothedLng,
      filterStatus: filterStatus ?? this.filterStatus,
      rejectReason: rejectReason ?? this.rejectReason,
      innovationDistance: innovationDistance ?? this.innovationDistance,
    );
  }

  bool get isAccepted => filterStatus != FilterStatus.rejected;

  Map<String, dynamic> toJson() => {
        'raw': {
          'lat': raw.lat,
          'lng': raw.lng,
          'elevation': raw.elevation,
          'timestamp': raw.timestamp.toIso8601String(),
          'speedMps': raw.speedMps,
          'accuracy': raw.accuracy,
          if (raw.heartRate != null) 'heartRate': raw.heartRate,
          if (raw.cadence != null) 'cadence': raw.cadence,
          if (raw.hdop != null) 'hdop': raw.hdop,
          if (raw.satelliteCount != null) 'satelliteCount': raw.satelliteCount,
          if (raw.provider != null) 'provider': raw.provider,
          'isMocked': raw.isMocked,
          'fixType': raw.fixType,
        },
        'pointIndex': pointIndex,
        'trackVersion': trackVersion.id,
        if (smoothedLat != null) 'smoothedLat': smoothedLat,
        if (smoothedLng != null) 'smoothedLng': smoothedLng,
        if (smoothedSpeedMps != null) 'smoothedSpeedMps': smoothedSpeedMps,
        'filterStatus': filterStatus.name,
        if (rejectReason != null) 'rejectReason': rejectReason!.name,
        if (innovationDistance != null)
          'innovationDistance': innovationDistance,
      };

  factory PipelineResult.fromJson(Map<String, dynamic> j) {
    final rawJson = j['raw'] as Map<String, dynamic>;
    return PipelineResult(
      raw: RawFix(
        lat: (rawJson['lat'] as num).toDouble(),
        lng: (rawJson['lng'] as num).toDouble(),
        elevation: (rawJson['elevation'] as num).toDouble(),
        timestamp: DateTime.parse(rawJson['timestamp'] as String),
        speedMps: (rawJson['speedMps'] as num).toDouble(),
        accuracy: (rawJson['accuracy'] as num).toInt(),
        heartRate: rawJson['heartRate'] as int?,
        cadence: rawJson['cadence'] as int?,
        hdop: rawJson['hdop'] != null
            ? (rawJson['hdop'] as num).toDouble()
            : null,
        satelliteCount: rawJson['satelliteCount'] as int?,
        provider: rawJson['provider'] as String?,
        isMocked: rawJson['isMocked'] as bool? ?? false,
        fixType: rawJson['fixType'] as String? ?? 'unknown',
      ),
      pointIndex: (j['pointIndex'] as num).toInt(),
      trackVersion: TrackVersion.values.firstWhere(
        (e) => e.id == j['trackVersion'],
        orElse: () => TrackVersion.deviceLive,
      ),
      smoothedLat: j['smoothedLat'] != null
          ? (j['smoothedLat'] as num).toDouble()
          : null,
      smoothedLng: j['smoothedLng'] != null
          ? (j['smoothedLng'] as num).toDouble()
          : null,
      smoothedSpeedMps: j['smoothedSpeedMps'] != null
          ? (j['smoothedSpeedMps'] as num).toDouble()
          : null,
      filterStatus: FilterStatus.values.firstWhere(
        (e) => e.name == j['filterStatus'],
        orElse: () => FilterStatus.measured,
      ),
      rejectReason: j['rejectReason'] != null
          ? RejectReason.values.firstWhere((e) => e.name == j['rejectReason'])
          : null,
      innovationDistance: j['innovationDistance'] != null
          ? (j['innovationDistance'] as num).toDouble()
          : null,
    );
  }
}

/// Emitted by the pipeline for significant state changes (gaps, rejections, stationary).
class SessionEvent {
  final FilterStatus status;
  final String? detail;
  final PipelineResult result;

  const SessionEvent({
    required this.status,
    this.detail,
    required this.result,
  });
}

/// Metadata describing the platform and environment where the track was recorded.
class PlatformMetadata {
  final String osVersion;
  final String hardwareModel;
  final String appVersion;

  const PlatformMetadata({
    required this.osVersion,
    required this.hardwareModel,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'osVersion': osVersion,
        'hardwareModel': hardwareModel,
        'appVersion': appVersion,
      };

  factory PlatformMetadata.fromJson(Map<String, dynamic> json) {
    return PlatformMetadata(
      osVersion: json['osVersion'] as String,
      hardwareModel: json['hardwareModel'] as String,
      appVersion: json['appVersion'] as String,
    );
  }
}
