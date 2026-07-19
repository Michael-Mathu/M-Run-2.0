class Activity {
  final String id;
  final String userId;
  final String type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceM;
  final int durationMs;
  final int movingTimeMs;
  final String status;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.startedAt,
    this.endedAt,
    required this.distanceM,
    required this.durationMs,
    required this.movingTimeMs,
    required this.status,
  });
}