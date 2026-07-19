import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

/// Computes the ghost's expected time (in seconds) at a given distance along the route.
/// Interpolates between ghost splits based on distance proportion.
double ghostExpectedTimeAtDistance(GhostPace ghost, double userDistanceM) {
  if (userDistanceM <= 0) return 0;
  final totalDistanceM = ghost.distanceKm * 1000;
  if (userDistanceM >= totalDistanceM) return ghost.totalSeconds.toDouble();

final progress = userDistanceM / totalDistanceM;
   final splitCount = ghost.splits.length;

   final exactSplitIndex = progress * splitCount;
  final lowerIndex = exactSplitIndex.floor().clamp(0, splitCount - 1);
  final upperIndex = (lowerIndex + 1).clamp(0, splitCount - 1);

  if (lowerIndex == upperIndex) {
    return ghost.splits.take(lowerIndex + 1).fold(0.0, (a, b) => a + b);
  }

  final lowerTime = ghost.splits.take(lowerIndex + 1).fold(0.0, (a, b) => a + b);
  final upperTime = ghost.splits.take(upperIndex + 1).fold(0.0, (a, b) => a + b);
  final t = exactSplitIndex - lowerIndex;

  return lowerTime + (upperTime - lowerTime) * t;
}

/// Projects the ghost's finish time based on current pace vs remaining splits.
double ghostProjectedFinishTime(
    GhostPace ghost, double userDistanceM, double userElapsedMs) {
  final elapsedSeconds = userElapsedMs / 1000;
  ghostExpectedTimeAtDistance(ghost, userDistanceM);

  if (userDistanceM >= ghost.distanceKm * 1000) return elapsedSeconds;

  // Project based on current pace
  final userPaceSecPerM = userDistanceM > 0 ? elapsedSeconds / userDistanceM : 0;
  final remainingDistanceM = ghost.distanceKm * 1000 - userDistanceM;
  final projectedRemaining = userPaceSecPerM * remainingDistanceM;

  return elapsedSeconds + projectedRemaining;
}

/// Computes the ghost's position along the route polyline at the user's current distance.
/// Returns null if the ghost hasn't started or route is invalid.
LatLng? computeGhostPosition(
    GhostPace ghost, double userDistanceM, List<LatLng> routePoints) {
  if (routePoints.length < 2 || userDistanceM <= 0) return null;

  final totalDistanceM = ghost.distanceKm * 1000;
  final progress = (userDistanceM / totalDistanceM).clamp(0.0, 1.0);

  // Compute cumulative distances along route polyline
  final distances = <double>[0];
  for (int i = 1; i < routePoints.length; i++) {
    final d = _haversine(
      routePoints[i - 1].latitude,
      routePoints[i - 1].longitude,
      routePoints[i].latitude,
      routePoints[i].longitude,
    );
    distances.add(distances.last + d);
  }

  final routeLength = distances.last;
  if (routeLength <= 0) return routePoints.first;

  final targetDist = routeLength * progress;

  // Find segment containing targetDist
  int segmentIndex = 0;
  while (segmentIndex < distances.length - 1 &&
      distances[segmentIndex + 1] < targetDist) {
    segmentIndex++;
  }

  if (segmentIndex >= routePoints.length - 1) {
    return routePoints.last;
  }

  final segStartDist = distances[segmentIndex];
  final segEndDist = distances[segmentIndex + 1];
  final segLength = segEndDist - segStartDist;

  if (segLength <= 0) return routePoints[segmentIndex];

  final t = (targetDist - segStartDist) / segLength;
  return _lerpLatLng(routePoints[segmentIndex], routePoints[segmentIndex + 1], t);
}

/// Computes the user's current split index and delta vs ghost for that split.
SplitComparison computeCurrentSplitComparison(
    GhostPace ghost, double userDistanceM, double userElapsedMs) {
  final totalDistanceM = ghost.distanceKm * 1000;
  final splitCount = ghost.splits.length;
  final splitDistance = totalDistanceM / splitCount;

final currentSplitIndex = (userDistanceM / splitDistance).floor().clamp(0, splitCount - 1);
   final splitStartDist = currentSplitIndex * splitDistance;

   final ghostSplitTime = ghost.splits[currentSplitIndex];

   // User's time in this split so far
   final userSplitStartTime = ghostExpectedTimeAtDistance(ghost, splitStartDist);
   final userSplitElapsed = (userElapsedMs / 1000) - userSplitStartTime;
   final userSplitElapsedClamped = userSplitElapsed.clamp(0.0, double.infinity);

   // Projected user split time based on current pace in this split
   final progressInSplit = ((userDistanceM - splitStartDist) / splitDistance).clamp(0.0, 1.0);
  final projectedUserSplitTime = progressInSplit > 0.01
      ? userSplitElapsedClamped / progressInSplit
      : ghostSplitTime; // fallback to ghost time if barely started

  final delta = projectedUserSplitTime - ghostSplitTime;
  final isAhead = delta < 0;

  return SplitComparison(
    splitIndex: currentSplitIndex,
    splitNumber: currentSplitIndex + 1,
    ghostSplitTime: ghostSplitTime,
    userProjectedSplitTime: projectedUserSplitTime,
    deltaSeconds: delta,
    isAhead: isAhead,
    progressInSplit: progressInSplit,
  );
}

/// Represents a comparison between user and ghost for a single split.
class SplitComparison {
  final int splitIndex;
  final int splitNumber;
  final double ghostSplitTime;
  final double userProjectedSplitTime;
  final double deltaSeconds;
  final bool isAhead;
  final double progressInSplit;

  const SplitComparison({
    required this.splitIndex,
    required this.splitNumber,
    required this.ghostSplitTime,
    required this.userProjectedSplitTime,
    required this.deltaSeconds,
    required this.isAhead,
    required this.progressInSplit,
  });

  String get deltaFormatted {
    final abs = deltaSeconds.abs();
    final sign = deltaSeconds < 0 ? '-' : '+';
    return '$sign${formatSeconds(abs)}';
  }

  String get statusIcon {
    if (progressInSplit < 0.01) return '⏳';
    if (isAhead) return '🟢';
    if (deltaSeconds.abs() < 5) return '🟡';
    return '🔴';
  }
}

/// Formats seconds as mm:ss or ss
String formatSeconds(double seconds) {
  final s = seconds.round();
  if (s >= 60) {
    final m = s ~/ 60;
    final rem = s % 60;
return '$m:${rem.toString().padLeft(2, '0')}';
  }
  return '${s}s';
}

/// Formats seconds as mm:ss for split times
String formatSecondsAsMinSec(double seconds) {
  final s = seconds.round();
  final m = s ~/ 60;
  final rem = s % 60;
  return '$m:${rem.toString().padLeft(2, '0')}';
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = _sin(dLat / 2) * _sin(dLat / 2) +
      _cos(_toRad(lat1)) * _cos(_toRad(lat2)) * _sin(dLon / 2) * _sin(dLon / 2);
  return r * 2 * _atan2(_sqrt(a), _sqrt(1 - a));
}

LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
  return LatLng(
    a.latitude + (b.latitude - a.latitude) * t,
    a.longitude + (b.longitude - a.longitude) * t,
  );
}

double _toRad(double d) => d * 3.141592653589793 / 180;
double _sin(double d) => math.sin(d);
double _cos(double d) => math.cos(d);
double _sqrt(double d) => math.sqrt(d);
double _atan2(double y, double x) => math.atan2(y, x);