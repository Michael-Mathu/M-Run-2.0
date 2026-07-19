/// Static leaderboard used by the motivation hub. The local user is merged in
/// at read time so the board always reflects the runner on this device.
class LeaderboardEntry {
  final String name;
  final int xp;
  final String flag;
  final bool you;

  const LeaderboardEntry({
    required this.name,
    required this.xp,
    required this.flag,
    this.you = false,
  });
}

const List<LeaderboardEntry> _sampleLeaderboard = [
  LeaderboardEntry(name: 'Asha Mwangi', xp: 4820, flag: '🇰🇪'),
  LeaderboardEntry(name: 'Tariq Omondi', xp: 3910, flag: '🇰🇪'),
  LeaderboardEntry(name: 'Nadia Hassan', xp: 3540, flag: '🇹🇿'),
  LeaderboardEntry(name: 'Joel Kiptoo', xp: 2980, flag: '🇺🇬'),
  LeaderboardEntry(name: 'Grace Achieng', xp: 2510, flag: '🇰🇪'),
  LeaderboardEntry(name: 'Brian Ssempijja', xp: 1990, flag: '🇺🇬'),
  LeaderboardEntry(name: 'Lydia Chebet', xp: 1640, flag: '🇰🇪'),
  LeaderboardEntry(name: 'Omar Said', xp: 1210, flag: '🇹🇿'),
];

List<LeaderboardEntry> leaderboardWithUser(int userXp) {
  final merged = [
    ..._sampleLeaderboard,
    const LeaderboardEntry(name: 'You', xp: 0, flag: '📍', you: true),
  ];
  merged.last = LeaderboardEntry(name: 'You', xp: userXp, flag: '📍', you: true);
  merged.sort((a, b) => b.xp.compareTo(a.xp));
  return merged;
}

int userRank(int userXp) =>
    leaderboardWithUser(userXp).indexWhere((e) => e.you) + 1;
