import 'dart:math';

import 'coordinate_util.dart';
import 'models.dart';

class KalmanState {
  double east;
  double north;
  double vEast;
  double vNorth;

  // Covariance matrix P
  double p00, p01, p02, p03;
  double p10, p11, p12, p13;
  double p20, p21, p22, p23;
  double p30, p31, p32, p33;

  KalmanState({
    required this.east,
    required this.north,
    this.vEast = 0,
    this.vNorth = 0,
    this.p00 = 100,
    this.p01 = 0,
    this.p02 = 0,
    this.p03 = 0,
    this.p10 = 0,
    this.p11 = 100,
    this.p12 = 0,
    this.p13 = 0,
    this.p20 = 0,
    this.p21 = 0,
    this.p22 = 25,
    this.p23 = 0,
    this.p30 = 0,
    this.p31 = 0,
    this.p32 = 0,
    this.p33 = 25,
  });
}

class KalmanFilter {
  KalmanState? _state;
  DateTime? _lastTimestamp;
  final double _originLat;
  final double _originLng;

  // Innovation gate threshold (Mahalanobis distance squared)
  // ~5 sigma
  final double innovationGateSq = 25.0;

  // ponytail: calibrated 2026-08-16 via synthetic_runner.dart at running speed.
  // Ceiling: synthetic noise model; refine with real Nairobi urban-canyon data when available.
  // Upgrade: re-run kalman_calibrate.dart with real traces and replace this value.
  static const double _motionSigmaMoving = 2.0;
  static const double _motionSigmaStationary = 0.3;

  KalmanFilter({required double originLat, required double originLng})
      : _originLat = originLat,
        _originLng = originLng;

  PipelineResult process(
      RawFix fix, int pointIndex, TrackVersion trackVersion) {
    final (measuredEast, measuredNorth) =
        CoordinateUtil.toEnu(_originLat, _originLng, fix.lat, fix.lng);

    if (_state == null || _lastTimestamp == null) {
      _state = KalmanState(east: measuredEast, north: measuredNorth);
      _lastTimestamp = fix.timestamp;
      return PipelineResult(
        raw: fix,
        pointIndex: pointIndex,
        trackVersion: trackVersion,
        smoothedLat: fix.lat,
        smoothedLng: fix.lng,
        smoothedSpeedMps: fix.speedMps,
        filterStatus: FilterStatus.filtered,
      );
    }

    final dt =
        fix.timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;
    if (dt <= 0) {
      // Should be caught by validator, but safe fallback
      return PipelineResult(
        raw: fix,
        pointIndex: pointIndex,
        trackVersion: trackVersion,
        filterStatus: FilterStatus.rejected,
        rejectReason: RejectReason.invalidTimestamp,
      );
    }

    // Adaptive process noise based on whether we are moving
    final motionSigma =
        fix.speedMps > 0.3 ? _motionSigmaMoving : _motionSigmaStationary;
    final qPos = (motionSigma * dt * dt / 2);
    final qVel = motionSigma * dt;
    final qPosSq = qPos * qPos;
    final qVelSq = qVel * qVel;
    final qPosVel = qPos * qVel;

    final s = _state!;

    // 1. Predict
    // x = F * x
    final predEast = s.east + s.vEast * dt;
    final predNorth = s.north + s.vNorth * dt;
    final predVEast = s.vEast;
    final predVNorth = s.vNorth;

    // P = F * P * F^T + Q
    final p00 = s.p00 + dt * (s.p20 + s.p02) + dt * dt * s.p22 + qPosSq;
    final p01 = s.p01 + dt * (s.p21 + s.p03) + dt * dt * s.p23;
    final p02 = s.p02 + dt * s.p22 + qPosVel;
    final p03 = s.p03 + dt * s.p23;

    final p10 = s.p10 + dt * (s.p30 + s.p12) + dt * dt * s.p32;
    final p11 = s.p11 + dt * (s.p31 + s.p13) + dt * dt * s.p33 + qPosSq;
    final p12 = s.p12 + dt * s.p32;
    final p13 = s.p13 + dt * s.p33 + qPosVel;

    final p20 = s.p20 + dt * s.p22 + qPosVel;
    final p21 = s.p21 + dt * s.p23;
    final p22 = s.p22 + qVelSq;
    final p23 = s.p23;

    final p30 = s.p30 + dt * s.p32;
    final p31 = s.p31 + dt * s.p33 + qPosVel;
    final p32 = s.p32;
    final p33 = s.p33 + qVelSq;

    // 2. Update
    // Measurement noise R
    double rVariance =
        fix.accuracy > 0 ? (fix.accuracy * fix.accuracy).toDouble() : 100.0;

    // Cap innovation variance when stationary to eagerly reject jitter
    if (fix.speedMps < 0.1) {
      rVariance = min(rVariance, 25.0); // 5m max variance
    }

    // Innovation y = z - H * x
    final yEast = measuredEast - predEast;
    final yNorth = measuredNorth - predNorth;
    final distSq = yEast * yEast + yNorth * yNorth;

    // Innovation covariance S = H * P * H^T + R
    final s00 = p00 + rVariance;
    final s11 = p11 + rVariance;

    // Innovation gate (simplified Mahalanobis)
    final mahalanobisSq = (yEast * yEast) / s00 + (yNorth * yNorth) / s11;
    if (mahalanobisSq > innovationGateSq) {
      // Reject measurement, keep prediction
      _state = KalmanState(
        east: predEast,
        north: predNorth,
        vEast: predVEast,
        vNorth: predVNorth,
        p00: p00,
        p01: p01,
        p02: p02,
        p03: p03,
        p10: p10,
        p11: p11,
        p12: p12,
        p13: p13,
        p20: p20,
        p21: p21,
        p22: p22,
        p23: p23,
        p30: p30,
        p31: p31,
        p32: p32,
        p33: p33,
      );
      _lastTimestamp = fix.timestamp;
      return PipelineResult(
        raw: fix,
        pointIndex: pointIndex,
        trackVersion: trackVersion,
        filterStatus: FilterStatus.rejected,
        rejectReason: RejectReason.largeInnovation,
        innovationDistance: sqrt(distSq),
      );
    }

    // Optimal Kalman gain K = P * H^T * S^-1
    // Since H is just the identity for position (2x4) and S is diagonal approx
    final k00 = p00 / s00;
    final k01 = p01 / s11;
    final k10 = p10 / s00;
    final k11 = p11 / s11;
    final k20 = p20 / s00;
    final k21 = p21 / s11;
    final k30 = p30 / s00;
    final k31 = p31 / s11;

    // New state x = x + K * y
    final newEast = predEast + k00 * yEast + k01 * yNorth;
    final newNorth = predNorth + k10 * yEast + k11 * yNorth;
    final newVEast = predVEast + k20 * yEast + k21 * yNorth;
    final newVNorth = predVNorth + k30 * yEast + k31 * yNorth;

    // New covariance P = (I - K * H) * P
    final np00 = (1 - k00) * p00 - k01 * p10;
    final np01 = (1 - k00) * p01 - k01 * p11;
    final np02 = (1 - k00) * p02 - k01 * p12;
    final np03 = (1 - k00) * p03 - k01 * p13;

    final np10 = -k10 * p00 + (1 - k11) * p10;
    final np11 = -k10 * p01 + (1 - k11) * p11;
    final np12 = -k10 * p02 + (1 - k11) * p12;
    final np13 = -k10 * p03 + (1 - k11) * p13;

    final np20 = -k20 * p00 - k21 * p10 + p20;
    final np21 = -k20 * p01 - k21 * p11 + p21;
    final np22 = -k20 * p02 - k21 * p12 + p22;
    final np23 = -k20 * p03 - k21 * p13 + p23;

    final np30 = -k30 * p00 - k31 * p10 + p30;
    final np31 = -k30 * p01 - k31 * p11 + p31;
    final np32 = -k30 * p02 - k31 * p12 + p32;
    final np33 = -k30 * p03 - k31 * p13 + p33;

    _state = KalmanState(
      east: newEast,
      north: newNorth,
      vEast: newVEast,
      vNorth: newVNorth,
      p00: np00,
      p01: np01,
      p02: np02,
      p03: np03,
      p10: np10,
      p11: np11,
      p12: np12,
      p13: np13,
      p20: np20,
      p21: np21,
      p22: np22,
      p23: np23,
      p30: np30,
      p31: np31,
      p32: np32,
      p33: np33,
    );
    _lastTimestamp = fix.timestamp;

    final (smoothedLat, smoothedLng) =
        CoordinateUtil.fromEnu(_originLat, _originLng, newEast, newNorth);
    final smoothedSpeedMps = sqrt(newVEast * newVEast + newVNorth * newVNorth);

    return PipelineResult(
      raw: fix,
      pointIndex: pointIndex,
      trackVersion: trackVersion,
      smoothedLat: smoothedLat,
      smoothedLng: smoothedLng,
      smoothedSpeedMps: smoothedSpeedMps,
      filterStatus: FilterStatus.filtered,
      innovationDistance: sqrt(distSq),
    );
  }
}
