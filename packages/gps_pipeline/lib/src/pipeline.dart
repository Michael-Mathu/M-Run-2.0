import 'fix_validator.dart';
import 'gap_detector.dart';
import 'kalman_filter.dart';
import 'map_matcher.dart';
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
  final MapMatcher _mapMatcher;

  KalmanFilter? _kalmanFilter;
  RawFix? _previousRaw;
  RawFix? _previousProcessed;
  PipelineResult? _previousResult;

  // Real-time lookahead buffer for 3-point outlier detection
  RawFix? _bufferPrev;
  RawFix? _bufferCurr;

  GpsPipeline({
    required this.profile,
    bool enableMapMatching = false,
  })  : _validator = const FixValidator(),
        _qualityGate = QualityGate(profile: profile),
        _outlierDetector = OutlierDetector(profile: profile),
        _stationarySuppressor = StationarySuppressor(),
        _gapDetector = const GapDetector(),
        _mapMatcher = MapMatcher(enabled: enableMapMatching);

  /// Process a fix in real-time. This method introduces a 1-fix delay
  /// to allow for 3-point spike detection.
  PipelineResult? process(RawFix fix) {
    // Pipeline stage 1: validation
    final valResult = _validator.validate(fix, _previousRaw);
    if (!valResult.isValid) {
      return PipelineResult(
        raw: fix,
        filterStatus: FilterStatus.rejected,
        rejectReason: valResult.rejectReason,
      );
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

    final prev = _bufferPrev!;
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
      return PipelineResult(
        raw: curr,
        filterStatus: FilterStatus.rejected,
        rejectReason: gateResult.rejectReason,
      );
    }

    // Stage 3: Outlier Detection
    if (_previousProcessed != null) {
      final outlierResult = _outlierDetector.check(_previousProcessed!, curr, next);
      if (outlierResult.isOutlier) {
        return PipelineResult(
          raw: curr,
          filterStatus: FilterStatus.rejected,
          rejectReason: outlierResult.rejectReason,
        );
      }
    }

    // Initialize Kalman filter origin on first accepted point
    _kalmanFilter ??= KalmanFilter(originLat: curr.lat, originLng: curr.lng);

    // Stage 4: Kalman Filter
    var result = _kalmanFilter!.process(curr);

    // Stage 5: Stationary Suppression
    result = _stationarySuppressor.process(result);

    // Stage 6: Gap Detection
    result = _gapDetector.process(result, _previousResult);

    // Stage 7: Map Matching (optional)
    result = _mapMatcher.process(result);

    if (result.filterStatus != FilterStatus.rejected) {
      _previousProcessed = curr;
      _previousResult = result;
    }

    return result;
  }

  /// Reprocess an entire session.
  List<PipelineResult> reprocess(List<RawFix> fixes) {
    // Reset state
    _kalmanFilter = null;
    _previousRaw = null;
    _previousProcessed = null;
    _previousResult = null;
    _bufferPrev = null;
    _bufferCurr = null;

    final results = <PipelineResult>[];

    for (var i = 0; i < fixes.length; i++) {
      final curr = fixes[i];
      final next = (i + 1 < fixes.length) ? fixes[i + 1] : null;

      final valResult = _validator.validate(curr, _previousRaw);
      if (!valResult.isValid) {
        results.add(PipelineResult(
          raw: curr,
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

  /// Reprocess an entire session asynchronously (includes Map Matching)
  Future<List<PipelineResult>> reprocessAsync(List<RawFix> fixes) async {
    final results = reprocess(fixes);
    return await _mapMatcher.matchBatch(results);
  }
}
