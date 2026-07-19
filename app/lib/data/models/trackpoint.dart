class Trackpoint {
  final int? id;
  final String activityId;
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;
  final double speedMps;
  final int? heartRate;
  final int? cadence;
  final int accuracy;
  final String state;

  Trackpoint({
    this.id,
    required this.activityId,
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
    required this.speedMps,
    this.heartRate,
    this.cadence,
    required this.accuracy,
    required this.state,
  });
}