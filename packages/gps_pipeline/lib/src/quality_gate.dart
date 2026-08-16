import 'dart:math';
import 'models.dart';

class GateResult {
  final bool passes;
  final double weight;
  final RejectReason? rejectReason;

  const GateResult({
    required this.passes,
    required this.weight,
    this.rejectReason,
  });
}

class QualityGate {
  final ActivityProfile profile;

  const QualityGate({required this.profile});

  GateResult accept(RawFix fix) {
    if (fix.accuracy <= 0) {
      return const GateResult(
        passes: false,
        weight: 0.0,
        rejectReason: RejectReason.zeroAccuracy,
      );
    }

    if (fix.accuracy > profile.maxAccuracyM) {
      return const GateResult(
        passes: false,
        weight: 0.0,
        rejectReason: RejectReason.poorAccuracy,
      );
    }

    // Weight formula: 1.0 / max(accuracy², minimum_variance)
    // We cap minimum variance at 25 (equivalent to 5m accuracy) so highly accurate
    // points don't cause instability in the Kalman filter.
    final variance = max(fix.accuracy * fix.accuracy.toDouble(), 25.0);
    final weight = 1.0 / variance;

    return GateResult(
      passes: true,
      weight: weight,
    );
  }
}
