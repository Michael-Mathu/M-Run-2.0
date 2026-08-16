import 'models.dart';

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

    switch (_state) {
      case StationaryState.moving:
        if (speed < speedThresholdMps) {
          _state = StationaryState.maybeStationary;
          _stateChangeTime = now;
        }
        return result;

      case StationaryState.maybeStationary:
        if (speed >= speedThresholdMps) {
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
          return _emitCentroid(result);
        }
        _addToCluster(result);
        return _emitCentroid(result);

      case StationaryState.maybeMoving:
        if (speed < speedThresholdMps) {
          _state = StationaryState.stationary;
          _stateChangeTime = null;
          _addToCluster(result);
          return _emitCentroid(result);
        }
        if (now.difference(_stateChangeTime!).inSeconds >= confirmSeconds) {
          _state = StationaryState.moving;
          _stateChangeTime = null;
          return result;
        }
        return _emitCentroid(result);
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
    final variance = (result.raw.accuracy * result.raw.accuracy).clamp(25.0, double.infinity);
    final weight = 1.0 / variance;

    _sumLat += (result.smoothedLat ?? result.raw.lat) * weight;
    _sumLng += (result.smoothedLng ?? result.raw.lng) * weight;
    _sumWeight += weight;
    _pointCount++;
  }

  PipelineResult _emitCentroid(PipelineResult result) {
    if (_pointCount == 0 || _sumWeight == 0) {
      return PipelineResult(
        raw: result.raw,
        smoothedLat: result.smoothedLat,
        smoothedLng: result.smoothedLng,
        filterStatus: FilterStatus.stationary,
        innovationDistance: result.innovationDistance,
      );
    }

    final centroidLat = _sumLat / _sumWeight;
    final centroidLng = _sumLng / _sumWeight;

    return PipelineResult(
      raw: result.raw,
      smoothedLat: centroidLat,
      smoothedLng: centroidLng,
      filterStatus: FilterStatus.stationary,
      innovationDistance: result.innovationDistance,
    );
  }
}
