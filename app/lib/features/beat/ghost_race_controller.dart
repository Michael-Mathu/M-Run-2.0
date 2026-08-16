import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

/// Represents the current state of a ghost race.
enum GhostRaceState {
  idle,
  armed,
  racing,
  finished,
}

enum GhostRaceResult {
  win,
  loss,
}

/// Reliability of the ghost comparison based on GPS quality.
enum GhostComparisonReliability {
  reliable,
  degraded,
  paused,
}

/// Controller for managing ghost race state and live computations.
class GhostRaceController extends Notifier<GhostRaceStateData> {
  @override
  GhostRaceStateData build() => GhostRaceStateData.idle();

  /// Arms the race with a ghost and tier (called from BeatLegendsPage).
  void arm(GhostPace ghost, DifficultyTier tier) {
    state = GhostRaceStateData.armed(ghost.forTier(tier), tier);
  }

  /// Starts the race when user begins running.
  void start() {
    if (state is! GhostRaceArmedData) return;
    final armed = state as GhostRaceArmedData;
    state = GhostRaceStateData.racing(armed.ghost, armed.tier);
  }

  /// Updates live comparison data during the run.
  void update({
    required double userDistanceM,
    required double userElapsedMs,
    required List<LatLng> routePoints,
  }) {
    if (state is! GhostRaceRacingData) return;
    final racing = state as GhostRaceRacingData;

    final result = _computeAllSplitComparisons(
      ghost: racing.ghost,
      userDistanceM: userDistanceM,
      userElapsedMs: userElapsedMs,
    );

    final ghostPos = computeGhostPosition(
      racing.ghost,
      userDistanceM,
      routePoints,
    );

    final ghostElapsedAtDist = ghostExpectedTimeAtDistance(racing.ghost, userDistanceM);
    final delta = (userElapsedMs / 1000) - ghostElapsedAtDist;
    final projectedFinish = ghostProjectedFinishTime(racing.ghost, userDistanceM, userElapsedMs);

    final userPace = userDistanceM > 0 ? (userElapsedMs / 1000) / (userDistanceM / 1000) : 0.0;
    final ghostPace = userDistanceM > 0 ? ghostElapsedAtDist / (userDistanceM / 1000) : 0.0;
    final paceGap = userDistanceM > 0 ? userPace - ghostPace : 0.0;

    // Approximate distance gap using ghost's current pace
    final ghostCurrentPaceMps = racing.ghost.distanceKm * 1000 / racing.ghost.totalSeconds;
    final distanceGap = -delta * ghostCurrentPaceMps;

    state = racing.copyWith(
      splitComparisons: result.$1,
      ghostPosition: ghostPos,
      deltaSeconds: delta,
      projectedFinishSeconds: projectedFinish,
      currentSplitIndex: result.$2,
      distanceGapM: distanceGap,
      paceGapSecPerKm: paceGap,
    );
  }

  /// Sets the reliability of the ghost comparison (based on GPS signal).
  void setReliability(GhostComparisonReliability reliability) {
    if (state is! GhostRaceRacingData) return;
    final racing = state as GhostRaceRacingData;
    if (racing.reliability == reliability) return;
    state = racing.copyWith(reliability: reliability);
  }

  /// Finishes the race and records result.
  void finish({required bool userWon, required int userElapsedMs}) {
    if (state is! GhostRaceRacingData) return;
    final racing = state as GhostRaceRacingData;
    state = GhostRaceStateData.finished(
      ghost: racing.ghost,
      tier: racing.tier,
      result: userWon ? GhostRaceResult.win : GhostRaceResult.loss,
      userElapsedMs: userElapsedMs,
      splitComparisons: racing.splitComparisons,
    );
  }

  /// Resets to idle state.
  void reset() => state = GhostRaceStateData.idle();

  /// Computes comparisons for all splits up to current.
  (List<SplitComparison>, int) _computeAllSplitComparisons({
    required GhostPace ghost,
    required double userDistanceM,
    required double userElapsedMs,
  }) {
    final totalDistanceM = ghost.distanceKm * 1000;
    final splitCount = ghost.splits.length;
    if (splitCount == 0) return (<SplitComparison>[], 0);
    
    final splitDistance = totalDistanceM / splitCount;
    final completedSplits = (userDistanceM / splitDistance).floor().clamp(0, splitCount);
    final currentSplitIndex = completedSplits == 0 ? 0 : completedSplits.clamp(0, splitCount - 1);

    final results = <SplitComparison>[];

    for (int i = 0; i < splitCount; i++) {
      final splitStartDist = i * splitDistance;
      final ghostSplitTime = ghost.splits[i];

      double userProjectedSplitTime;
      bool isAhead;

      if (i < completedSplits) {
        // Completed split: estimate from average pace
        userProjectedSplitTime = completedSplits > 0
            ? (userElapsedMs / 1000) / completedSplits * splitCount
            : ghostSplitTime;
        isAhead = userProjectedSplitTime < ghostSplitTime;
      } else if (i == currentSplitIndex && userDistanceM > splitStartDist) {
        // Current split: project from current pace
        final progressInSplit = (userDistanceM - splitStartDist) / splitDistance;
        final userSplitStartTime = ghostExpectedTimeAtDistance(ghost, splitStartDist);
        final userSplitElapsed = (userElapsedMs / 1000) - userSplitStartTime;
        userProjectedSplitTime = progressInSplit > 0.01
            ? userSplitElapsed / progressInSplit
            : ghostSplitTime;
        isAhead = userProjectedSplitTime < ghostSplitTime;
      } else {
        // Future split: assume ghost pace
        userProjectedSplitTime = ghostSplitTime;
        isAhead = false;
      }

      results.add(SplitComparison(
        splitIndex: i,
        splitNumber: i + 1,
        ghostSplitTime: ghostSplitTime,
        userProjectedSplitTime: userProjectedSplitTime,
        deltaSeconds: userProjectedSplitTime - ghostSplitTime,
        isAhead: isAhead,
        progressInSplit: i == currentSplitIndex
            ? ((userDistanceM - splitStartDist) / splitDistance).clamp(0.0, 1.0)
            : (i < completedSplits ? 1.0 : 0.0),
      ));
    }

    return (results, currentSplitIndex);
  }
}

/// Base sealed class for ghost race state data.
sealed class GhostRaceStateData {
  const GhostRaceStateData();

  static GhostRaceStateData idle() => const GhostRaceIdleData();
  static GhostRaceStateData armed(GhostPace ghost, DifficultyTier tier) =>
      GhostRaceArmedData(ghost, tier);
  static GhostRaceStateData racing(GhostPace ghost, DifficultyTier tier) =>
      GhostRaceRacingData(ghost: ghost, tier: tier);
  static GhostRaceStateData finished({
    required GhostPace ghost,
    required DifficultyTier tier,
    required GhostRaceResult result,
    required int userElapsedMs,
    required List<SplitComparison> splitComparisons,
  }) =>
      GhostRaceFinishedData(
        ghost: ghost,
        tier: tier,
        result: result,
        userElapsedMs: userElapsedMs,
        splitComparisons: splitComparisons,
      );

  T? maybeWhen<T>({
    T Function()? idle,
    T Function(GhostPace ghost, DifficultyTier tier)? armed,
    T Function(GhostRaceRacingData state)? racing,
    T Function(GhostRaceFinishedData state)? finished,
  }) {
    switch (this) {
      case GhostRaceIdleData():
        return idle?.call();
      case GhostRaceArmedData(ghost: final g, tier: final t):
        return armed?.call(g, t);
      case GhostRaceRacingData():
        return racing?.call(this as GhostRaceRacingData);
      case GhostRaceFinishedData():
        return finished?.call(this as GhostRaceFinishedData);
    }
  }
}

class GhostRaceIdleData extends GhostRaceStateData {
  const GhostRaceIdleData();
}

class GhostRaceArmedData extends GhostRaceStateData {
  final GhostPace ghost;
  final DifficultyTier tier;
  const GhostRaceArmedData(this.ghost, this.tier);
}

class GhostRaceRacingData extends GhostRaceStateData {
  final GhostPace ghost;
  final DifficultyTier tier;
  final List<SplitComparison> splitComparisons;
  final LatLng? ghostPosition;
  final double deltaSeconds; // user - ghost (negative = user ahead)
  final double projectedFinishSeconds;
  final int currentSplitIndex;
  final GhostComparisonReliability reliability;
  final double distanceGapM; // positive = user ahead
  final double paceGapSecPerKm; // negative = user faster

  const GhostRaceRacingData({
    required this.ghost,
    required this.tier,
    this.splitComparisons = const [],
    this.ghostPosition,
    this.deltaSeconds = 0,
    this.projectedFinishSeconds = 0,
    this.currentSplitIndex = 0,
    this.reliability = GhostComparisonReliability.reliable,
    this.distanceGapM = 0,
    this.paceGapSecPerKm = 0,
  });

  GhostRaceRacingData copyWith({
    List<SplitComparison>? splitComparisons,
    LatLng? ghostPosition,
    double? deltaSeconds,
    double? projectedFinishSeconds,
    int? currentSplitIndex,
    GhostComparisonReliability? reliability,
    double? distanceGapM,
    double? paceGapSecPerKm,
  }) => GhostRaceRacingData(
        ghost: ghost,
        tier: tier,
        splitComparisons: splitComparisons ?? this.splitComparisons,
        ghostPosition: ghostPosition ?? this.ghostPosition,
        deltaSeconds: deltaSeconds ?? this.deltaSeconds,
        projectedFinishSeconds: projectedFinishSeconds ?? this.projectedFinishSeconds,
        currentSplitIndex: currentSplitIndex ?? this.currentSplitIndex,
        reliability: reliability ?? this.reliability,
        distanceGapM: distanceGapM ?? this.distanceGapM,
        paceGapSecPerKm: paceGapSecPerKm ?? this.paceGapSecPerKm,
      );
}

class GhostRaceFinishedData extends GhostRaceStateData {
  final GhostPace ghost;
  final DifficultyTier tier;
  final GhostRaceResult result;
  final int userElapsedMs;
  final List<SplitComparison> splitComparisons;

  const GhostRaceFinishedData({
    required this.ghost,
    required this.tier,
    required this.result,
    required this.userElapsedMs,
    required this.splitComparisons,
  });
}

final ghostRaceControllerProvider = NotifierProvider<GhostRaceController, GhostRaceStateData>(
  GhostRaceController.new,
);