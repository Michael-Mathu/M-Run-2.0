import 'package:flutter/material.dart';
import 'package:mwendo_app/core/gamification/gamification_state.dart';

Color tierColor(ChallengeTier t) => {
      ChallengeTier.bronze: const Color(0xFFCD7F32),
      ChallengeTier.silver: const Color(0xFFC0C6CC),
      ChallengeTier.gold: const Color(0xFFFFD15C),
      ChallengeTier.platinum: const Color(0xFF7FE7E0),
    }[t]!;

enum ChallengeCategory { starter, milestone, performance, fun, school, knowledge }

enum ChallengeTier { bronze, silver, gold, platinum }

enum ChallengeMetric { distanceKm, runs, streakDays, elevationM, paceMinPerKm, lessons, legendsBeaten }

class PerRunSnapshot {
  final double distanceM;
  final int durationMs;
  final double elevationGainM;
  final double avgPaceMinPerKm;

  const PerRunSnapshot({
    required this.distanceM,
    required this.durationMs,
    required this.elevationGainM,
    required this.avgPaceMinPerKm,
  });
}

/// A single challenge from the full Phase 2 library.
/// Progress is derived from the persistent [GamificationState].
class GamifiedChallenge {
  final String slug;
  final String title;
  final String description;
  final int xp;
  final String badgeId;
  final String badgeEmoji;
  final String badgeName;
  final IconData icon;
  final ChallengeTier tier;
  final ChallengeCategory category;
  final ChallengeMetric metric;
  final double target;
  final bool lowerIsBetter;
  final String goalLabel;

  const GamifiedChallenge({
    required this.slug,
    required this.title,
    required this.description,
    required this.xp,
    required this.badgeId,
    required this.badgeEmoji,
    required this.badgeName,
    required this.icon,
    required this.tier,
    required this.category,
    required this.metric,
    required this.target,
    this.lowerIsBetter = false,
    required this.goalLabel,
  });

  double value(GamificationState g, {PerRunSnapshot? run}) {
    switch (metric) {
      case ChallengeMetric.distanceKm:
        return (run != null ? run.distanceM : g.totalDistanceM) / 1000;
      case ChallengeMetric.runs:
        return g.totalRuns.toDouble();
      case ChallengeMetric.streakDays:
        return g.streakDays.toDouble();
      case ChallengeMetric.elevationM:
        return run != null ? run.elevationGainM : g.totalElevationM;
      case ChallengeMetric.paceMinPerKm:
        return run?.avgPaceMinPerKm ?? g.bestPaceMinPerKm;
      case ChallengeMetric.lessons:
        return g.completedLessons.length.toDouble();
      case ChallengeMetric.legendsBeaten:
        return g.beatenLegends.length.toDouble();
    }
  }

  double ratio(GamificationState g, {PerRunSnapshot? run}) {
    final v = value(g, run: run);
    if (target <= 0) return 0;
    if (lowerIsBetter) {
      if (v <= 0) return 0;
      return (target / v).clamp(0, 1);
    }
    return (v / target).clamp(0, 1);
  }

  bool isComplete(GamificationState g, {PerRunSnapshot? run}) =>
      ratio(g, run: run) >= 1;

  String progressText(GamificationState g) {
    final v = value(g);
    return '${lowerIsBetter ? v.toStringAsFixed(1) : _fmt(v)} / ${_fmt(target)} $goalLabel';
  }

  String _fmt(double v) => v >= 100 ? v.round().toString() : v.toStringAsFixed(1);
}

const Map<String, ({String emoji, String name})> specialBadges = {
  'scholar': (emoji: '🎓', name: 'Scholar'),
  'week-warrior': (emoji: '🔥', name: 'Week Warrior'),
  'month-marathoner': (emoji: '🌟', name: 'Month Marathoner'),
};

({String emoji, String name}) badgeMeta(String id) {
  for (final c in ChallengeEvaluator.allChallenges) {
    if (c.badgeId == id) {
      return (emoji: c.badgeEmoji, name: c.badgeName);
    }
  }
  return specialBadges[id] ?? (emoji: '🏅', name: id);
}

class ChallengeEvaluator {
  static const firstRun = GamifiedChallenge(
    slug: 'first-run',
    title: 'First Run',
    description: 'Complete any activity of at least 0.5 km.',
    xp: 50,
    badgeId: 'first-run',
    badgeEmoji: '🏃',
    badgeName: 'First Steps',
    icon: Icons.directions_run_rounded,
    tier: ChallengeTier.bronze,
    category: ChallengeCategory.starter,
    metric: ChallengeMetric.distanceKm,
    target: 0.5,
    goalLabel: 'km',
  );

  static const first5K = GamifiedChallenge(
    slug: 'first-5k',
    title: 'First 5K',
    description: 'Complete a single activity of 5 km or more.',
    xp: 200,
    badgeId: 'first-5k',
    badgeEmoji: '🎯',
    badgeName: '5K Finisher',
    icon: Icons.flag_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.starter,
    metric: ChallengeMetric.distanceKm,
    target: 5,
    goalLabel: 'km',
  );

  static const streak7 = GamifiedChallenge(
    slug: 'streak-7',
    title: '7-Day Streak',
    description: 'Record an activity on 7 consecutive days.',
    xp: 500,
    badgeId: 'week-warrior',
    badgeEmoji: '🔥',
    badgeName: 'Week Warrior',
    icon: Icons.local_fire_department_rounded,
    tier: ChallengeTier.gold,
    category: ChallengeCategory.starter,
    metric: ChallengeMetric.streakDays,
    target: 7,
    goalLabel: 'days',
  );

  static const tenK = GamifiedChallenge(
    slug: 'ten-k',
    title: 'Ten Kay',
    description: 'Run 10 km in a single activity.',
    xp: 300,
    badgeId: 'ten-k',
    badgeEmoji: '🥈',
    badgeName: '10K',
    icon: Icons.straighten_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.milestone,
    metric: ChallengeMetric.distanceKm,
    target: 10,
    goalLabel: 'km',
  );

  static const halfMarathon = GamifiedChallenge(
    slug: 'half-marathon',
    title: 'Half Marathon',
    description: 'Cover 21.1 km in one activity.',
    xp: 800,
    badgeId: 'half-marathon',
    badgeEmoji: '🏅',
    badgeName: 'Half',
    icon: Icons.route_rounded,
    tier: ChallengeTier.gold,
    category: ChallengeCategory.milestone,
    metric: ChallengeMetric.distanceKm,
    target: 21.1,
    goalLabel: 'km',
  );

  static const marathon = GamifiedChallenge(
    slug: 'marathon',
    title: 'Marathon',
    description: 'Conquer the full 42.2 km.',
    xp: 1500,
    badgeId: 'marathon',
    badgeEmoji: '🏆',
    badgeName: 'Marathoner',
    icon: Icons.emoji_events_rounded,
    tier: ChallengeTier.platinum,
    category: ChallengeCategory.milestone,
    metric: ChallengeMetric.distanceKm,
    target: 42.2,
    goalLabel: 'km',
  );

  static const centuryClub = GamifiedChallenge(
    slug: 'century-club',
    title: 'Century Club',
    description: 'Log 100 km across all your runs.',
    xp: 1200,
    badgeId: 'century-club',
    badgeEmoji: '💯',
    badgeName: 'Century',
    icon: Icons.auto_graph_rounded,
    tier: ChallengeTier.platinum,
    category: ChallengeCategory.milestone,
    metric: ChallengeMetric.distanceKm,
    target: 100,
    goalLabel: 'km',
  );

  static const hillClimber = GamifiedChallenge(
    slug: 'hill-climber',
    title: 'Hill Climber',
    description: 'Climb 500 m of elevation in total.',
    xp: 400,
    badgeId: 'hill-climber',
    badgeEmoji: '⛰️',
    badgeName: 'Hill Climber',
    icon: Icons.terrain_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.milestone,
    metric: ChallengeMetric.elevationM,
    target: 500,
    goalLabel: 'm',
  );

  static const subSix = GamifiedChallenge(
    slug: 'sub-six',
    title: 'Sub-6 Pace',
    description: 'Hold a pace of 6:00 /km or faster.',
    xp: 600,
    badgeId: 'sub-six',
    badgeEmoji: '⚡',
    badgeName: 'Sub-6',
    icon: Icons.bolt_rounded,
    tier: ChallengeTier.gold,
    category: ChallengeCategory.performance,
    metric: ChallengeMetric.paceMinPerKm,
    target: 6.0,
    lowerIsBetter: true,
    goalLabel: '/km',
  );

  static const subFiveThirty = GamifiedChallenge(
    slug: 'sub-five-thirty',
    title: 'Sub-5:30',
    description: 'Hold a pace of 5:30 /km or faster.',
    xp: 900,
    badgeId: 'sub-five-thirty',
    badgeEmoji: '🔥',
    badgeName: 'Sub-5:30',
    icon: Icons.flash_on_rounded,
    tier: ChallengeTier.gold,
    category: ChallengeCategory.performance,
    metric: ChallengeMetric.paceMinPerKm,
    target: 5.5,
    lowerIsBetter: true,
    goalLabel: '/km',
  );

  static const subFive = GamifiedChallenge(
    slug: 'sub-five',
    title: 'Sub-5 Pace',
    description: 'Hold a pace of 5:00 /km or faster.',
    xp: 1200,
    badgeId: 'sub-five',
    badgeEmoji: '💨',
    badgeName: 'Sub-5',
    icon: Icons.rocket_launch_rounded,
    tier: ChallengeTier.platinum,
    category: ChallengeCategory.performance,
    metric: ChallengeMetric.paceMinPerKm,
    target: 5.0,
    lowerIsBetter: true,
    goalLabel: '/km',
  );

  static const sunriseSprint = GamifiedChallenge(
    slug: 'sunrise-sprint',
    title: 'Sunrise Sprint',
    description: 'Get out for your very first run.',
    xp: 30,
    badgeId: 'sunrise-sprint',
    badgeEmoji: '🌅',
    badgeName: 'First Light',
    icon: Icons.wb_sunny_rounded,
    tier: ChallengeTier.bronze,
    category: ChallengeCategory.fun,
    metric: ChallengeMetric.runs,
    target: 1,
    goalLabel: 'runs',
  );

  static const riftValleyBound = GamifiedChallenge(
    slug: 'rift-valley-bound',
    title: 'Rift Valley Bound',
    description: 'Run 10 km, the heart of champion country.',
    xp: 350,
    badgeId: 'rift-valley-bound',
    badgeEmoji: '🏔️',
    badgeName: 'Rift Bound',
    icon: Icons.landscape_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.fun,
    metric: ChallengeMetric.distanceKm,
    target: 10,
    goalLabel: 'km',
  );

  static const rainyStreak = GamifiedChallenge(
    slug: 'rainy-season-streak',
    title: 'Rainy Season Streak',
    description: 'Run 5 days in a row, rain or shine.',
    xp: 250,
    badgeId: 'rainy-season-streak',
    badgeEmoji: '🌧️',
    badgeName: 'Rainy Streak',
    icon: Icons.umbrella_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.fun,
    metric: ChallengeMetric.streakDays,
    target: 5,
    goalLabel: 'days',
  );

  static const hillRepeat = GamifiedChallenge(
    slug: 'hill-repeat',
    title: 'Hill Repeater',
    description: 'Climb 300 m of elevation in total.',
    xp: 200,
    badgeId: 'hill-repeat',
    badgeEmoji: '🔁',
    badgeName: 'Repeater',
    icon: Icons.repeat_rounded,
    tier: ChallengeTier.bronze,
    category: ChallengeCategory.fun,
    metric: ChallengeMetric.elevationM,
    target: 300,
    goalLabel: 'm',
  );

  static const houseWarmup = GamifiedChallenge(
    slug: 'house-warmup',
    title: 'House Warm-up',
    description: 'Earn your first house points with a 1 km run.',
    xp: 60,
    badgeId: 'house-warmup',
    badgeEmoji: '🏫',
    badgeName: 'House Points',
    icon: Icons.school_rounded,
    tier: ChallengeTier.bronze,
    category: ChallengeCategory.school,
    metric: ChallengeMetric.distanceKm,
    target: 1,
    goalLabel: 'km',
  );

  static const interSchool5k = GamifiedChallenge(
    slug: 'inter-school-5k',
    title: 'Inter-School 5K',
    description: 'Represent your school with a 5 km effort.',
    xp: 250,
    badgeId: 'inter-school-5k',
    badgeEmoji: '🎓',
    badgeName: 'Inter-School',
    icon: Icons.groups_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.school,
    metric: ChallengeMetric.distanceKm,
    target: 5,
    goalLabel: 'km',
  );

  static const bookworm = GamifiedChallenge(
    slug: 'bookworm',
    title: 'Bookworm',
    description: 'Complete 5 academy lessons.',
    xp: 200,
    badgeId: 'scholar',
    badgeEmoji: '📚',
    badgeName: 'Bookworm',
    icon: Icons.menu_book_rounded,
    tier: ChallengeTier.silver,
    category: ChallengeCategory.knowledge,
    metric: ChallengeMetric.lessons,
    target: 5,
    goalLabel: 'lessons',
  );

  static const beatALegend = GamifiedChallenge(
    slug: 'beat-a-legend',
    title: 'Beat a Legend',
    description: 'Racing a ghost counts — beat any East African legend to earn the Legend Slayer badge.',
    xp: 1000,
    badgeId: 'legend-slayer',
    badgeEmoji: '👑',
    badgeName: 'Legend Slayer',
    icon: Icons.workspace_premium_rounded,
    tier: ChallengeTier.platinum,
    category: ChallengeCategory.performance,
    metric: ChallengeMetric.legendsBeaten,
    target: 1,
    goalLabel: 'legends',
  );

  static const List<GamifiedChallenge> allChallenges = [
    firstRun,
    first5K,
    streak7,
    tenK,
    halfMarathon,
    marathon,
    centuryClub,
    hillClimber,
    subSix,
    subFiveThirty,
    subFive,
    sunriseSprint,
    riftValleyBound,
    rainyStreak,
    hillRepeat,
    houseWarmup,
    interSchool5k,
    bookworm,
    beatALegend,
  ];

  static List<GamifiedChallenge> byCategory(ChallengeCategory c) =>
      allChallenges.where((e) => e.category == c).toList();
}
