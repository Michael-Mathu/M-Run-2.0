import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwendo_app/core/gamification/gamification_state.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

export 'gamification_state.dart';

/// Set to true when the persisted save is detected as corrupt and reset. The
/// UI watches this to surface a one-time notice to the user.
class _CorruptionFlag extends Notifier<bool> {
  @override
  bool build() => false;
  void flag() => state = true;
  void clear() => state = false;
}

final gamificationCorruptedProvider = NotifierProvider<_CorruptionFlag, bool>(_CorruptionFlag.new);

/// Persistent gamification engine — XP, levels, streaks, badges and titles,
/// saved locally (offline-first). Phase 2's motivation system.
class Gamification extends Notifier<GamificationState> {
  static const _key = 'gamification_v1';
  Timer? _autosaveTimer;

  @override
  GamificationState build() {
    ref.onDispose(() => _autosaveTimer?.cancel());
    _load();
    _startAutosave();
    return const GamificationState();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(_key);
      if (raw != null) {
        state = GamificationState.fromJson(jsonDecode(raw));
      }
    } catch (_) {
      // Corrupt save — reset to a clean default instead of crashing.
      state = const GamificationState();
      ref.read(gamificationCorruptedProvider.notifier).flag();
      prefs.remove(_key);
    }
  }

  void _startAutosave() {
    // ponytail: periodic autosave (every 2 min) so a crash between mutating
    // state and the explicit _persist() can't lose more than a couple minutes.
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer.periodic(const Duration(minutes: 2), (_) => _persist());
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  int _epochDays(DateTime dt) => dt.difference(DateTime(2020, 1, 1)).inDays;

  /// Record a finished run and return any challenges newly unlocked.
  List<GamifiedChallenge> completeRun({
    required double distanceM,
    required int durationMs,
    required double elevationGainM,
    required double avgPaceMinPerKm,
  }) {
    final today = _epochDays(DateTime.now());
    int streak = state.streakDays;
    if (state.lastRunDay == today) {
      // same day, no streak change
    } else if (state.lastRunDay == today - 1) {
      streak += 1;
    } else {
      streak = 1;
    }
    final earned = <String>{...state.earnedBadges};
    if (streak >= 7) earned.add('week-warrior');
    if (streak >= 30) earned.add('month-marathoner');

    final gain = (distanceM / 1000 * 20).round() + (durationMs / 60000).round();
    final next = state.copyWith(
      xp: state.xp + gain,
      totalRuns: state.totalRuns + 1,
      totalDistanceM: state.totalDistanceM + distanceM,
      totalTimeMs: state.totalTimeMs + durationMs,
      totalElevationM: state.totalElevationM + elevationGainM,
      bestPaceMinPerKm: avgPaceMinPerKm > 0
          ? (state.bestPaceMinPerKm == 0
              ? avgPaceMinPerKm
              : [state.bestPaceMinPerKm, avgPaceMinPerKm].reduce((a, b) => a < b ? a : b))
          : state.bestPaceMinPerKm,
      streakDays: streak,
      longestStreak: streak > state.longestStreak ? streak : state.longestStreak,
      lastRunDay: today,
      earnedBadges: earned,
    );

    final newly = <GamifiedChallenge>[];
    final completed = <String>{...state.completedChallenges};
    final earnedNow = <String>{...next.earnedBadges};
    final snap = PerRunSnapshot(
      distanceM: distanceM,
      durationMs: durationMs,
      elevationGainM: elevationGainM,
      avgPaceMinPerKm: avgPaceMinPerKm,
    );
    for (final c in ChallengeEvaluator.allChallenges) {
      if (completed.contains(c.slug)) continue;
      if (c.isComplete(next, run: snap)) {
        completed.add(c.slug);
        earnedNow.add(c.badgeId);
        newly.add(c);
      }
    }
    state = next.copyWith(
      completedChallenges: completed,
      earnedBadges: earnedNow,
      xp: next.xp + newly.fold(0, (s, c) => s + c.xp),
    );
    _persist();
    return newly;
  }

  /// Mark a lesson read; returns true if it was not already complete.
  bool completeLesson(String courseSlug, int index) {
    final key = '$courseSlug:$index';
    if (state.completedLessons.contains(key)) return false;
    final today = _epochDays(DateTime.now());
    int kStreak = state.knowledgeStreakDays;
    if (state.lastLessonDay == today) {
      // already counted today
    } else if (state.lastLessonDay == today - 1) {
      kStreak += 1;
    } else {
      kStreak = 1;
    }
    state = state.copyWith(
      xp: state.xp + 15,
      completedLessons: {...state.completedLessons, key},
      earnedBadges: {...state.earnedBadges, 'scholar'},
      knowledgeStreakDays: kStreak,
      lastLessonDay: today,
    );
    _persist();
    return true;
  }

  bool isLessonDone(String courseSlug, int index) =>
      state.completedLessons.contains('$courseSlug:$index');

  int lessonsCompletedIn(String courseSlug) => state.completedLessons
      .where((k) => k.startsWith('$courseSlug:'))
      .length;

  /// Record a Beat-the-Legends attempt against [ghost]. Whether the user
  /// [beat] the ghost or not, racing earns the legend's participation badge;
  /// beating one also completes the "Beat a Legend" challenge and grants XP.
  /// Returns any challenges newly unlocked (for a celebration overlay).
  List<GamifiedChallenge> recordBeatLegend(GhostPace ghost, bool beat) {
    final raced = {...state.racedLegends, ghost.id};
    final badges = {...state.earnedBadges, 'legend-${ghost.id}'};
    final beaten = beat ? {...state.beatenLegends, ghost.id} : state.beatenLegends;
    final xp = state.xp + (beat ? 250 : 50);

    final next = state.copyWith(
      racedLegends: raced,
      earnedBadges: badges,
      beatenLegends: beaten,
      xp: xp,
    );

    final newly = <GamifiedChallenge>[];
    final completed = {...state.completedChallenges};
    if (beat && !completed.contains(ChallengeEvaluator.beatALegend.slug)) {
      for (final c in ChallengeEvaluator.allChallenges) {
        if (completed.contains(c.slug)) continue;
        if (c.isComplete(next)) {
          completed.add(c.slug);
          newly.add(c);
        }
      }
    }
    state = next.copyWith(
      completedChallenges: completed,
      xp: next.xp + newly.fold(0, (s, c) => s + c.xp),
    );
    _persist();
    return newly;
  }
}

final gamificationProvider =
    NotifierProvider<Gamification, GamificationState>(Gamification.new);
