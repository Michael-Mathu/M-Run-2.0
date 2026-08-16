import 'coordinate_util.dart';
import 'models.dart';

class SessionQualityReport {
  final double rejectionRatePct;
  final double medianAccuracyM;
  final double p95AccuracyM;
  final int jumpsPerKm;
  final double maxImpliedSpeedMps;
  final double rawDistanceM;
  final double filteredDistanceM;
  final int signalGapCount;
  final double totalGapSeconds;
  final double interpolatedPct; // Note: currently no interpolation logic, so this is 0
  final int stationaryClusterCount;

  const SessionQualityReport({
    required this.rejectionRatePct,
    required this.medianAccuracyM,
    required this.p95AccuracyM,
    required this.jumpsPerKm,
    required this.maxImpliedSpeedMps,
    required this.rawDistanceM,
    required this.filteredDistanceM,
    required this.signalGapCount,
    required this.totalGapSeconds,
    required this.interpolatedPct,
    required this.stationaryClusterCount,
  });

  static SessionQualityReport compute(List<PipelineResult> results) {
    if (results.isEmpty) {
      return const SessionQualityReport(
        rejectionRatePct: 0,
        medianAccuracyM: 0,
        p95AccuracyM: 0,
        jumpsPerKm: 0,
        maxImpliedSpeedMps: 0,
        rawDistanceM: 0,
        filteredDistanceM: 0,
        signalGapCount: 0,
        totalGapSeconds: 0,
        interpolatedPct: 0,
        stationaryClusterCount: 0,
      );
    }

    int rejectedCount = 0;
    final accuracies = <int>[];
    
    double maxImpliedSpeed = 0;
    double rawDistance = 0;
    double filteredDistance = 0;
    
    int signalGapCount = 0;
    double totalGapSeconds = 0;
    int stationaryClusterCount = 0;
    int excessiveSpeedJumps = 0;

    PipelineResult? prevRawResult;
    PipelineResult? prevFilteredResult;

    for (final res in results) {
      accuracies.add(res.raw.accuracy);
      if (!res.isAccepted) {
        rejectedCount++;
        if (res.rejectReason == 'excessive_speed') {
          excessiveSpeedJumps++;
        }
      }

      if (prevRawResult != null) {
        final dist = CoordinateUtil.haversineMetres(
            prevRawResult.raw.lat, prevRawResult.raw.lng, res.raw.lat, res.raw.lng);
        rawDistance += dist;

        final dt = res.raw.timestamp.difference(prevRawResult.raw.timestamp).inMilliseconds / 1000.0;
        if (dt > 0) {
          final speed = dist / dt;
          if (speed > maxImpliedSpeed) maxImpliedSpeed = speed;
        }
      }
      prevRawResult = res;

      if (res.isAccepted) {
        if (prevFilteredResult != null) {
          final fDist = CoordinateUtil.haversineMetres(
              prevFilteredResult.smoothedLat ?? prevFilteredResult.raw.lat,
              prevFilteredResult.smoothedLng ?? prevFilteredResult.raw.lng,
              res.smoothedLat ?? res.raw.lat,
              res.smoothedLng ?? res.raw.lng);
          filteredDistance += fDist;
        }
        prevFilteredResult = res;

        if (res.filterStatus == FilterStatus.gapLong || res.filterStatus == FilterStatus.gapShort) {
           signalGapCount++;
           // We just record the count for now, a full duration requires keeping the actual gap delta
        } else if (res.filterStatus == FilterStatus.stationary) {
           stationaryClusterCount++;
        }
      }
    }

    accuracies.sort();
    final medianAcc = accuracies.isNotEmpty ? accuracies[accuracies.length ~/ 2].toDouble() : 0.0;
    final p95Acc = accuracies.isNotEmpty ? accuracies[(accuracies.length * 0.95).floor()].toDouble() : 0.0;
    final jumpsPerKm = (filteredDistance > 0) ? (excessiveSpeedJumps / (filteredDistance / 1000.0)).round() : 0;

    return SessionQualityReport(
      rejectionRatePct: (rejectedCount / results.length) * 100,
      medianAccuracyM: medianAcc,
      p95AccuracyM: p95Acc,
      jumpsPerKm: jumpsPerKm,
      maxImpliedSpeedMps: maxImpliedSpeed,
      rawDistanceM: rawDistance,
      filteredDistanceM: filteredDistance,
      signalGapCount: signalGapCount,
      totalGapSeconds: totalGapSeconds,
      interpolatedPct: 0,
      stationaryClusterCount: stationaryClusterCount,
    );
  }
}
