import 'coordinate_util.dart';
import 'models.dart';

class OutlierResult {
  final bool isOutlier;
  final String? rejectReason;

  const OutlierResult.ok()
      : isOutlier = false,
        rejectReason = null;

  const OutlierResult.reject(this.rejectReason) : isOutlier = true;
}

class OutlierDetector {
  final ActivityProfile profile;

  const OutlierDetector({required this.profile});

  OutlierResult check(RawFix prev, RawFix curr, RawFix? next) {
    final dtSec = curr.timestamp.difference(prev.timestamp).inMilliseconds / 1000.0;
    if (dtSec <= 0) return const OutlierResult.reject('invalid_timestamp');

    final dist = CoordinateUtil.haversineMetres(prev.lat, prev.lng, curr.lat, curr.lng);
    final impliedSpeed = dist / dtSec;

    // 1. Check if implied speed exceeds maximum for activity
    if (impliedSpeed > profile.maxSpeedMps) {
      return const OutlierResult.reject('excessive_speed');
    }

    // 2. Lookahead for 3-point spike (A -> far away B -> near A/C)
    if (next != null) {
      final distToNext = CoordinateUtil.haversineMetres(curr.lat, curr.lng, next.lat, next.lng);
      final distPrevToNext = CoordinateUtil.haversineMetres(prev.lat, prev.lng, next.lat, next.lng);

      // If B is far from both A and C, but A and C are close, B is a spike
      if (dist > 15.0 && distToNext > 15.0 && distPrevToNext < dist * 0.5) {
         return const OutlierResult.reject('3_point_spike');
      }
    }

    return const OutlierResult.ok();
  }
}
