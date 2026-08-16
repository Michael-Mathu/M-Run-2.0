import 'models.dart';

class GapDetector {
  final int maxContinuousGapSeconds;
  final int longGapSeconds;

  const GapDetector({
    this.maxContinuousGapSeconds = 10,
    this.longGapSeconds = 60,
  });

  PipelineResult process(
      PipelineResult result, PipelineResult? previousResult) {
    if (result.filterStatus == FilterStatus.rejected) return result;
    if (previousResult == null ||
        previousResult.filterStatus == FilterStatus.rejected) {
      return result;
    }

    final dtSec =
        result.raw.timestamp.difference(previousResult.raw.timestamp).inSeconds;

    if (dtSec > longGapSeconds) {
      return result.copyWith(filterStatus: FilterStatus.gapLong);
    }

    if (dtSec > maxContinuousGapSeconds) {
      return result.copyWith(filterStatus: FilterStatus.gapShort);
    }

    return result;
  }
}
