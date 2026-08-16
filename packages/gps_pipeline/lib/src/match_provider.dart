abstract interface class MatchProvider {
  String get name;
  String get version;
  Future<MatchResult> match(List<MatchRequest> points);
  Future<bool> isAvailable();
}

class MatchRequest {
  final double lat;
  final double lng;
  final double accuracyM;
  final DateTime timestamp;

  const MatchRequest({
    required this.lat,
    required this.lng,
    required this.accuracyM,
    required this.timestamp,
  });
}

class MatchResult {
  final List<MatchedPoint?> points; // null = no match for this input
  final double meanSnapDistanceM;
  final double p95SnapDistanceM;
  final int matchedCount;
  final int unmatchedCount;
  final double providerConfidence; // 0..1, provider-supplied or derived

  const MatchResult({
    required this.points,
    required this.meanSnapDistanceM,
    required this.p95SnapDistanceM,
    required this.matchedCount,
    required this.unmatchedCount,
    required this.providerConfidence,
  });
}

class MatchedPoint {
  final double lat;
  final double lng;
  final String? wayId;
  final double snapDistanceM;

  const MatchedPoint({
    required this.lat,
    required this.lng,
    this.wayId,
    required this.snapDistanceM,
  });
}
