import 'models.dart';
import 'coordinate_util.dart';
import 'dart:collection';

enum StationaryState { moving, maybeStationary, stationary, maybeMoving }

class StationarySuppressor {
  final double speedThresholdMps;
  final int confirmSeconds;

  StationaryState _state = StationaryState.moving;
  DateTime? _stateChangeTime;

  // Cluster aggregation
  double _sumLat = 0;
  double _sumLng = 0;
  double _sumWeight = 0;
  int _pointCount = 0;

  // Window for drift detection
  final Queue<PipelineResult> _window = Queue<PipelineResult>();

  StationarySuppressor({
    this.speedThresholdMps = 0.5,
    this.confirmSeconds = 5,
  });

  PipelineResult process(PipelineResult result) {
    if (result.filterStatus == FilterStatus.rejected) {
      return result;
    }

    final fix = result.raw;
    final now = fix.timestamp;
    final speed = fix.speedMps;

    // Manage 15-second rolling window
    _window.addLast(result);
    while (_window.isNotEmpty &&
        now.difference(_window.first.raw.timestamp).inSeconds > 15) {
      _window.removeFirst();
    }

    // Drift detection: if window is at least 10s and distance moved is less than accuracy
    if (_window.length >= 5 &&
        now.difference(_window.first.raw.timestamp).inSeconds >= 10) {
      final first = _window.first;
      final dist = CoordinateUtil.haversineMetres(
        first.smoothedLat ?? first.raw.lat,
        first.smoothedLng ?? first.raw.lng,
        result.smoothedLat ?? result.raw.lat,
        result.smoothedLng ?? result.raw.lng,
      );
      if (dist < fix.accuracy + 2.0 && _state != StationaryState.stationary) {
        // Force stationary/rejected state to kill ghost drift
        _state = StationaryState.stationary;
        _startCluster(result);
        return result.copyWith(
          filterStatus: FilterStatus.rejected,
          rejectReason: RejectReason.stationary,
        );
      }
    }

    switch (_state) {
      case StationaryState.moving:
        if (speed < speedThresholdMps) {
          _state = StationaryState.maybeStationary;
          _stateChangeTime = now;
        }
        return result;

      case StationaryState.maybeStationary:
        if (speed >= speedThresholdMps &&
            _state != StationaryState.stationary) {
          _state = StationaryState.moving;
          _stateChangeTime = null;
          return result;
        }
        if (now.difference(_stateChangeTime!).inSeconds >= confirmSeconds) {
          _state = StationaryState.stationary;
          _startCluster(result);
          return _emitCentroid(result);
        }
        return result;

      case StationaryState.stationary:
        if (speed >= speedThresholdMps) {
          _state = StationaryState.maybeMoving;
          _stateChangeTime = now;
          return result.copyWith(
            filterStatus: FilterStatus.rejected,
            rejectReason: RejectReason.stationary,
          );
        }
        _addToCluster(result);
        return result.copyWith(
          filterStatus: FilterStatus.rejected,
          rejectReason: RejectReason.stationary,
        );

      case StationaryState.maybeMoving:
        if (speed < speedThresholdMps) {
          _state = StationaryState.stationary;
          _stateChangeTime = null;
          _addToCluster(result);
          return result.copyWith(
            filterStatus: FilterStatus.rejected,
            rejectReason: RejectReason.stationary,
          );
        }
        if (now.difference(_stateChangeTime!).inSeconds >= confirmSeconds) {
          _state = StationaryState.moving;
          _stateChangeTime = null;
          return result;
        }
        return result.copyWith(
          filterStatus: FilterStatus.rejected,
          rejectReason: RejectReason.stationary,
        );
    }
  }

  void _startCluster(PipelineResult result) {
    _sumLat = 0;
    _sumLng = 0;
    _sumWeight = 0;
    _pointCount = 0;
    _addToCluster(result);
  }

  void _addToCluster(PipelineResult result) {
    // Weight points by their accuracy (lower accuracy = higher weight)
    // We cap at 5m so highly accurate points don't dominate excessively
    final variance = (result.raw.accuracy * result.raw.accuracy)
        .clamp(25.0, double.infinity);
    final weight = 1.0 / variance;

    _sumLat += (result.smoothedLat ?? result.raw.lat) * weight;
    _sumLng += (result.smoothedLng ?? result.raw.lng) * weight;
    _sumWeight += weight;
    _pointCount++;
  }

  PipelineResult _emitCentroid(PipelineResult result) {
    if (_pointCount == 0 || _sumWeight == 0) {
      return result.copyWith(filterStatus: FilterStatus.stationary);
    }

    final centroidLat = _sumLat / _sumWeight;
    final centroidLng = _sumLng / _sumWeight;

    return result.copyWith(
      smoothedLat: centroidLat,
      smoothedLng: centroidLng,
      filterStatus: FilterStatus.stationary,
    );
  }
}
