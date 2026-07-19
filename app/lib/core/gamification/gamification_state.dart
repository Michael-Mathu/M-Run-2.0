/// Persistent gamification state — the heart of Phase 2's motivation system.
/// Kept free of UI/provider imports so it can be shared without cycles.
class GamificationState {
  final int xp;
  final int totalRuns;
  final double totalDistanceM;
  final int totalTimeMs;
  final double totalElevationM;
  final double bestPaceMinPerKm; // 0 = none yet, lower is better
  final int streakDays;
  final int longestStreak;
  final int? lastRunDay; // epoch days
  final int knowledgeStreakDays;
  final int? lastLessonDay;
  final Set<String> completedChallenges;
  final Set<String> completedLessons; // "$courseSlug:$index"
  final Set<String> earnedBadges;
  final Set<String> beatenLegends; // ghost ids the user has beaten
  final Set<String> racedLegends; // ghost ids the user has raced

  const GamificationState({
    this.xp = 0,
    this.totalRuns = 0,
    this.totalDistanceM = 0,
    this.totalTimeMs = 0,
    this.totalElevationM = 0,
    this.bestPaceMinPerKm = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastRunDay,
    this.knowledgeStreakDays = 0,
    this.lastLessonDay,
    this.completedChallenges = const {},
    this.completedLessons = const {},
    this.earnedBadges = const {},
    this.beatenLegends = const {},
    this.racedLegends = const {},
  });

  GamificationState copyWith({
    int? xp,
    int? totalRuns,
    double? totalDistanceM,
    int? totalTimeMs,
    double? totalElevationM,
    double? bestPaceMinPerKm,
    int? streakDays,
    int? longestStreak,
    int? lastRunDay,
    int? knowledgeStreakDays,
    int? lastLessonDay,
    Set<String>? completedChallenges,
    Set<String>? completedLessons,
    Set<String>? earnedBadges,
    Set<String>? beatenLegends,
    Set<String>? racedLegends,
  }) =>
      GamificationState(
        xp: xp ?? this.xp,
        totalRuns: totalRuns ?? this.totalRuns,
        totalDistanceM: totalDistanceM ?? this.totalDistanceM,
        totalTimeMs: totalTimeMs ?? this.totalTimeMs,
        totalElevationM: totalElevationM ?? this.totalElevationM,
        bestPaceMinPerKm: bestPaceMinPerKm ?? this.bestPaceMinPerKm,
        streakDays: streakDays ?? this.streakDays,
        longestStreak: longestStreak ?? this.longestStreak,
        lastRunDay: lastRunDay ?? this.lastRunDay,
        knowledgeStreakDays: knowledgeStreakDays ?? this.knowledgeStreakDays,
        lastLessonDay: lastLessonDay ?? this.lastLessonDay,
        completedChallenges: completedChallenges ?? this.completedChallenges,
        completedLessons: completedLessons ?? this.completedLessons,
        earnedBadges: earnedBadges ?? this.earnedBadges,
        beatenLegends: beatenLegends ?? this.beatenLegends,
        racedLegends: racedLegends ?? this.racedLegends,
      );

  int get level => levelForXp(xp);
  int get xpIntoLevel => xp - xpForLevel(level);
  int get xpForNextLevel => xpForLevel(level + 1) - xpForLevel(level);
  double get levelProgress =>
      xpForNextLevel == 0 ? 1 : (xpIntoLevel / xpForNextLevel).clamp(0, 1);

  String get title => titleForLevel(level);

  Set<String> get titles {
    final out = <String>{};
    for (final t in levelTitles) {
      if (level >= t.level) out.add(t.title);
    }
    return out;
  }

  int lessonsCompletedIn(String slug) =>
      completedLessons.where((k) => k.startsWith('$slug:')).length;

  bool isLessonDone(String slug, int index) =>
      completedLessons.contains('$slug:$index');

  factory GamificationState.fromJson(Map<String, dynamic> j) => GamificationState(
        xp: j['xp'] ?? 0,
        totalRuns: j['totalRuns'] ?? 0,
        totalDistanceM: (j['totalDistanceM'] ?? 0).toDouble(),
        totalTimeMs: j['totalTimeMs'] ?? 0,
        totalElevationM: (j['totalElevationM'] ?? 0).toDouble(),
        bestPaceMinPerKm: (j['bestPaceMinPerKm'] ?? 0).toDouble(),
        streakDays: j['streakDays'] ?? 0,
        longestStreak: j['longestStreak'] ?? 0,
        lastRunDay: j['lastRunDay'],
        knowledgeStreakDays: j['knowledgeStreakDays'] ?? 0,
        lastLessonDay: j['lastLessonDay'],
        completedChallenges: Set<String>.from(j['completedChallenges'] ?? []),
        completedLessons: Set<String>.from(j['completedLessons'] ?? []),
        earnedBadges: Set<String>.from(j['earnedBadges'] ?? []),
        beatenLegends: Set<String>.from(j['beatenLegends'] ?? []),
        racedLegends: Set<String>.from(j['racedLegends'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'totalRuns': totalRuns,
        'totalDistanceM': totalDistanceM,
        'totalTimeMs': totalTimeMs,
        'totalElevationM': totalElevationM,
        'bestPaceMinPerKm': bestPaceMinPerKm,
        'streakDays': streakDays,
        'longestStreak': longestStreak,
        'lastRunDay': lastRunDay,
        'knowledgeStreakDays': knowledgeStreakDays,
        'lastLessonDay': lastLessonDay,
        'completedChallenges': completedChallenges.toList(),
        'completedLessons': completedLessons.toList(),
        'earnedBadges': earnedBadges.toList(),
        'beatenLegends': beatenLegends.toList(),
        'racedLegends': racedLegends.toList(),
      };
}

/// Exponential level curve (level 1 = 0 XP). Soft early game, steep later.
int xpForLevel(int level) {
  if (level <= 1) return 0;
  return (60 * (level - 1) * (1 + (level - 1) * 0.12)).round();
}

  int levelForXp(int xp) {
    var l = 1;
    while (l < 100 && xpForLevel(l + 1) <= xp) {
      l++;
    }
    return l;
  }

class LevelTitle {
  final int level;
  final String title;
  const LevelTitle(this.level, this.title);
}

const List<LevelTitle> levelTitles = [
    LevelTitle(1, 'Mwendo Rookie'),
    LevelTitle(5, 'Road Runner'),
    LevelTitle(10, 'Trailblazer'),
    LevelTitle(20, 'Hill Repeater'),
    LevelTitle(35, 'Mountain Goat'),
    LevelTitle(50, 'Historian'),
    LevelTitle(75, '5K Master'),
    LevelTitle(100, 'Living Legend'),
];

String titleForLevel(int level) {
  var t = levelTitles.first.title;
  for (final lt in levelTitles) {
    if (level >= lt.level) t = lt.title;
  }
  return t;
}
