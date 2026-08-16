import 'coordinate_util.dart';
import 'match_provider.dart';
import 'models.dart';

enum MatchStatus {
  pending,
  matching,
  matched,
  skippedNoConsent,
  unavailable,
  rejectedLowQuality,
  failedNetwork,
}

class MatchQuality {
  final double routeContinuityScore;
  final double headingAgreementScore;
  final double unmatchedFraction;
  final bool passesThresholds;

  const MatchQuality({
    required this.routeContinuityScore,
    required this.headingAgreementScore,
    required this.unmatchedFraction,
    required this.passesThresholds,
  });

  static MatchQuality evaluate(List<PipelineResult> filteredResults, MatchResult matchResult) {
    if (matchResult.points.isEmpty || filteredResults.isEmpty) {
       return const MatchQuality(routeContinuityScore: 0, headingAgreementScore: 0, unmatchedFraction: 1.0, passesThresholds: false);
    }

    int continuityPassCount = 0;
    int continuityTotal = 0;
    int headingPassCount = 0;
    int headingTotal = 0;

    MatchedPoint? prevMatched;
    PipelineResult? prevResult;

    for (int i = 0; i < matchResult.points.length; i++) {
      final matched = matchResult.points[i];
      final original = filteredResults[i];

       if (matched != null) {
        if (prevMatched != null && prevResult != null) {
          final matchedHeading = CoordinateUtil.bearingDeg(prevMatched.lat, prevMatched.lng, matched.lat, matched.lng);
          final rawHeading = CoordinateUtil.bearingDeg(prevResult.raw.lat, prevResult.raw.lng, original.raw.lat, original.raw.lng);
          
          continuityTotal++;
          headingTotal++;
          final diff = _angleDiff(matchedHeading, rawHeading);
          if (diff.abs() < 45.0) {
            headingPassCount++;
          }
        }
        prevMatched = matched;
        prevResult = original;
      }
    }

    // Continuity requires computing change in matched headings.
    prevMatched = null;
    double? prevHeading;
    for (int i = 0; i < matchResult.points.length; i++) {
      final matched = matchResult.points[i];
      if (matched != null) {
        if (prevMatched != null) {
          final heading = CoordinateUtil.bearingDeg(prevMatched.lat, prevMatched.lng, matched.lat, matched.lng);
          if (prevHeading != null) {
            continuityTotal++;
            final diff = _angleDiff(heading, prevHeading);
            if (diff.abs() < 90.0) {
              continuityPassCount++;
            }
          }
          prevHeading = heading;
        }
        prevMatched = matched;
      }
    }

    final routeContinuityScore = continuityTotal > 0 ? continuityPassCount / continuityTotal : 1.0;
    final headingAgreementScore = headingTotal > 0 ? headingPassCount / headingTotal : 1.0;
    final unmatchedFraction = matchResult.unmatchedCount / (matchResult.matchedCount + matchResult.unmatchedCount);

    final passesThresholds = 
        unmatchedFraction < 0.15 &&
        matchResult.p95SnapDistanceM < 25 &&
        matchResult.providerConfidence > 0.6 &&
        routeContinuityScore > 0.8;

    return MatchQuality(
      routeContinuityScore: routeContinuityScore,
      headingAgreementScore: headingAgreementScore,
      unmatchedFraction: unmatchedFraction,
      passesThresholds: passesThresholds,
    );
  }

  static double _angleDiff(double a, double b) {
     double diff = (a - b) % 360.0;
     if (diff > 180.0) diff -= 360.0;
     if (diff < -180.0) diff += 360.0;
     return diff;
  }
}
