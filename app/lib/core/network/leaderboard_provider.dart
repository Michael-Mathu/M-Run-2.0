import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gamification/leaderboard_data.dart';
import '../../core/network/api_client.dart';

/// Remote leaderboard entry shape (mirrors backend `leaderboard.Entry`).
class RemoteEntry {
  final String userId;
  final String? displayName;
  final double score;
  final int rank;
  const RemoteEntry(
      {required this.userId, this.displayName, required this.score, required this.rank});

  factory RemoteEntry.fromJson(Map<String, dynamic> j) => RemoteEntry(
        userId: j['user_id'] ?? '',
        // Backend should emit a public display name; fall back to masking the
        // stored email (never show it in the clear — privacy leak).
        displayName: j['name'] as String? ?? j['display_name'] as String?,
        score: (j['score'] ?? 0).toDouble(),
        rank: j['rank'] ?? 0,
      );
}

/// Prefer the backend display name; otherwise mask an email user_id so the
/// address is never exposed on the public board.
String _displayName(RemoteEntry e) {
  final n = e.displayName?.trim();
  if (n != null && n.isNotEmpty) return n;
  final id = e.userId;
  if (!id.contains('@')) return id.isEmpty ? 'Runner' : id;
  final local = id.split('@')[0];
  final masked = local.length <= 2
      ? local
      : '${local[0]}${'•' * (local.length - 2)}${local[local.length - 1]}';
  return '$masked@${id.split('@')[1]}';
}

/// Fetches the leaderboard from the backend and merges the local user in,
/// falling back to the static board when the API is unreachable. This closes
/// the "backend is never called" gap flagged in the audit.
final remoteLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, int>((ref, userXp) async {
  try {
    final client = ref.watch(apiClientProvider);
    final res = await client.dio.get('/api/v1/leaderboard');
    final list = (res.data as List)
        .map((e) => RemoteEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final remote = list
        .map((e) => LeaderboardEntry(
              name: _displayName(e),
              xp: e.score.round(),
              flag: '🏃',
            ))
        .toList();
    final merged = [
      ...remote,
      LeaderboardEntry(name: 'You', xp: userXp, flag: '📍', you: true),
    ];
    merged.sort((a, b) => b.xp.compareTo(a.xp));
    return merged;
  } catch (_) {
    // offline-first: keep the app usable without a backend.
    return leaderboardWithUser(userXp);
  }
});
