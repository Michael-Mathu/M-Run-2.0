import 'dart:async';

import 'fix_validator.dart';
import 'gap_detector.dart';
import 'kalman_filter.dart';

import 'models.dart';
import 'outlier_detector.dart';
import 'quality_gate.dart';
import 'stationary_suppressor.dart';

class GpsPipeline {
  final ActivityProfile profile;
  final FixValidator _validator;
  final QualityGate _qualityGate;
  final OutlierDetector _outlierDetector;
  final StationarySuppressor _stationarySuppressor;
  final GapDetector _gapDetector;

  KalmanFilter? _kalmanFilter;
  RawFix? _previousRaw;
  RawFix? _previousProcessed;
  PipelineResult? _previousResult;

  // Real-time lookahead buffer for 3-point outlier detection
  RawFix? _bufferPrev;
  RawFix? _bufferCurr;

  int _pointsProcessed = 0;
  final TrackVersion trackVersion = TrackVersion.kalmanEkf;

  final _eventController = StreamController<SessionEvent>.broadcast();
  Stream<SessionEvent> get eventStream => _eventController.stream;

  GpsPipeline({
    required this.profile,
  })  : _validator = const FixValidator(),
        _qualityGate = QualityGate(profile: profile),
        _outlierDetector = OutlierDetector(profile: profile),
        _stationarySuppressor = StationarySuppressor(),
        _gapDetector = const GapDetector();
  PipelineResult? process(RawFix fix) {
    // Pipeline stage 1: validation
    final valResult = _validator.validate(fix, _previousRaw);
    if (!valResult.isValid) {
      final res = PipelineResult(
        raw: fix,
        pointIndex: _pointsProcessed++,
        trackVersion: trackVersion,
        filterStatus: FilterStatus.rejected,
        rejectReason: valResult.rejectReason,
      );
      _emitEvent(res, valResult.rejectReason?.name);
      return res;
    }
    _previousRaw = fix;

    // Buffer management for lookahead
    if (_bufferCurr == null) {
      if (_bufferPrev == null) {
        _bufferPrev = fix;
        // Cannot process yet (need at least 2 points to even think about speed)
        // For the very first point, we just emit it without lookahead.
        return _processInner(fix, null);
      } else {
        _bufferCurr = fix;
        return null; // Wait for the next point to check for a spike
      }
    }


    final curr = _bufferCurr!;
    final next = fix;

    // Shift buffer
    _bufferPrev = curr;
    _bufferCurr = next;

    // Process the *current* point now that we have its future
    return _processInner(curr, next);
  }

  PipelineResult _processInner(RawFix curr, RawFix? next) {
    // Stage 2: Quality Gate
    final gateResult = _qualityGate.accept(curr);
    if (!gateResult.passes) {
      final res = PipelineResult(
        raw: curr,
        pointIndex: _pointsProcessed++,
        trackVersion: trackVersion,
        filterStatus: FilterStatus.rejected,
        rejectReason: gateResult.rejectReason,
      );
      _emitEvent(res, gateResult.rejectReason?.name);
      return res;
    }

    // Stage 3: Outlier Detection
    if (_previousProcessed != null) {
      final outlierResult =
          _outlierDetector.check(_previousProcessed!, curr, next);
      if (outlierResult.isOutlier) {
        final res = PipelineResult(
          raw: curr,
          pointIndex: _pointsProcessed++,
          trackVersion: trackVersion,
          filterStatus: FilterStatus.rejected,
          rejectReason: outlierResult.rejectReason,
        );
        _emitEvent(res, outlierResult.rejectReason?.name);
        return res;
      }
    }

    // Initialize Kalman filter origin on first accepted point
    _kalmanFilter ??= KalmanFilter(originLat: curr.lat, originLng: curr.lng);

    // Stage 4: Kalman Filter
    var result = _kalmanFilter!.process(curr, _pointsProcessed++, trackVersion);

    // Stage 5: Stationary Suppression
    result = _stationarySuppressor.process(result);

    // Stage 6: Gap Detection
    result = _gapDetector.process(result, _previousResult);



    if (result.filterStatus != FilterStatus.rejected) {
      _previousProcessed = curr;
      _previousResult = result;
    }

    if (result.filterStatus != FilterStatus.filtered) {
      _emitEvent(result, null);
    }

    return result;
  }

  void _emitEvent(PipelineResult result, String? detail) {
    if (!_eventController.isClosed) {
      _eventController.add(SessionEvent(
        status: result.filterStatus,
        detail: detail,
        result: result,
      ));
    }
  }

  /// Called at the end of a session to process any buffered points.
  List<PipelineResult> flush() {
    final out = <PipelineResult>[];
    if (_bufferPrev != null) out.add(_processInner(_bufferPrev!, _bufferCurr));
    if (_bufferCurr != null) out.add(_processInner(_bufferCurr!, null));
    _bufferPrev = null;
    _bufferCurr = null;
    return out;
  }

  /// Resets the pipeline state to start a new session.
  void reset() {
    _kalmanFilter = null;
    _previousRaw = null;
    _previousProcessed = null;
    _previousResult = null;
    _bufferPrev = null;
    _bufferCurr = null;
    _pointsProcessed = 0;
  }

  /// Reprocess an entire session.
  List<PipelineResult> reprocess(List<RawFix> fixes) {
    reset();

    final results = <PipelineResult>[];

    for (var i = 0; i < fixes.length; i++) {
      final curr = fixes[i];
      final next = (i + 1 < fixes.length) ? fixes[i + 1] : null;

      final valResult = _validator.validate(curr, _previousRaw);
      if (!valResult.isValid) {
        results.add(PipelineResult(
          raw: curr,
          pointIndex: _pointsProcessed++,
          trackVersion: trackVersion,
          filterStatus: FilterStatus.rejected,
          rejectReason: valResult.rejectReason,
        ));
        continue;
      }
      _previousRaw = curr;

      final res = _processInner(curr, next);
      results.add(res);
    }

    return results;
  }

  Future<List<PipelineResult>> reprocessAsync(List<RawFix> fixes) async {
    return reprocess(fixes);
  }

  void dispose() {
    _eventController.close();
  }
}
