import 'package:flutter/material.dart';
import 'legends.dart';

/// A "ghost runner" — a legendary performance you can race against (Pillar 4).
/// [splits] are seconds-per-segment across [distanceKm]; the count is chosen so
/// each segment is roughly a kilometre (shorter races use finer segments).
class GhostPace {
  final String id;
  final String legendSlug;
  final String name;
  final String distanceLabel;
  final double distanceKm;
  final List<double> splits; // seconds per segment
  final int totalSeconds;
  final String description;
  final Color accent;
  final String splitStyle;

  const GhostPace({
    required this.id,
    required this.legendSlug,
    required this.name,
    required this.distanceLabel,
    required this.distanceKm,
    required this.splits,
    required this.totalSeconds,
    required this.description,
    required this.accent,
    required this.splitStyle,
  });

  double get avgPaceMinPerKm => totalSeconds / 60 / distanceKm;
  Legend get legend => legendForSlug(legendSlug);

  /// Returns a copy of this ghost scaled to a difficulty tier.
  GhostPace forTier(DifficultyTier tier) {
    final scaled = (totalSeconds * tier.factor).round();
    return GhostPace(
      id: id,
      legendSlug: legendSlug,
      name: name,
      distanceLabel: distanceLabel,
      distanceKm: distanceKm,
      splits: _buildSplits(distanceKm, scaled, splitStyle),
      totalSeconds: scaled,
      description: description,
      accent: accent,
      splitStyle: splitStyle,
    );
  }
}

/// Tiered difficulty for ghost races.
enum DifficultyTier {
  bronze,
  silver,
  gold,
  goat;

  double get factor {
    switch (this) {
      case DifficultyTier.bronze:
        return 1.25; // 125% of WR — achievable for intermediates
      case DifficultyTier.silver:
        return 1.10; // 110% — challenging
      case DifficultyTier.gold:
        return 1.02; // 102% — very hard
      case DifficultyTier.goat:
        return 1.00; // the actual WR — elite only
    }
  }

  String get label {
    switch (this) {
      case DifficultyTier.bronze:
        return 'Bronze';
      case DifficultyTier.silver:
        return 'Silver';
      case DifficultyTier.gold:
        return 'Gold';
      case DifficultyTier.goat:
        return 'G.O.A.T.';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyTier.bronze:
        return const Color(0xFFCD7F32);
      case DifficultyTier.silver:
        return const Color(0xFFC0C6CC);
      case DifficultyTier.gold:
        return const Color(0xFFFFD15C);
      case DifficultyTier.goat:
        return const Color(0xFFFF5A1F);
    }
  }

  String get badge {
    switch (this) {
      case DifficultyTier.bronze:
        return '🥉';
      case DifficultyTier.silver:
        return '🥈';
      case DifficultyTier.gold:
        return '🥇';
      case DifficultyTier.goat:
        return '👑';
    }
  }
}

List<double> _buildSplits(double distanceKm, int totalSeconds, String style) {
  final n = distanceKm >= 5 ? distanceKm.round() : (distanceKm * 2).round();
  final base = totalSeconds / n;
  final out = <double>[];
  for (int i = 0; i < n; i++) {
    final t = (i + 1) / n;
    double factor;
    switch (style) {
      case 'positive':
        factor = 0.9 + 0.2 * t;
        break;
      case 'negative':
        factor = 1.12 - 0.24 * t;
        break;
      default:
        factor = 1.0 + 0.02 * (i.isEven ? 1 : -1);
    }
    out.add(base * factor);
  }
  final sum = out.fold(0.0, (a, b) => a + b);
  return out.map((s) => s * totalSeconds / sum).toList();
}

GhostPace _ghost({
  required String id,
  required String legendSlug,
  required String name,
  required String distanceLabel,
  required double distanceKm,
  required int totalSeconds,
  required String splitStyle,
  required String description,
  required Color accent,
}) =>
    GhostPace(
      id: id,
      legendSlug: legendSlug,
      name: name,
      distanceLabel: distanceLabel,
      distanceKm: distanceKm,
      totalSeconds: totalSeconds,
      splitStyle: splitStyle,
      splits: _buildSplits(distanceKm, totalSeconds, splitStyle),
      description: description,
      accent: accent,
    );

List<GhostPace> get ghostPaces => [
      _ghost(
        id: 'kipchoge-marathon',
        legendSlug: 'eliud-kipchoge',
        name: 'Kipchoge — Berlin 2022',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7269, // 2:01:09
        splitStyle: 'positive',
        description:
            'The official marathon world record. A metronomic, slightly positive split — the model of controlled excellence.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'kiptum-marathon',
        legendSlug: 'kelvin-kiptum',
        name: 'Kiptum — Chicago 2023',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7235, // 2:00:35
        splitStyle: 'negative',
        description:
            'The fastest marathon ever run. An aggressive negative split that rewrote the limits of human endurance.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'tergat-10k',
        legendSlug: 'paul-tergat',
        name: 'Tergat — 10,000m',
        distanceLabel: '10K',
        distanceKm: 10,
        totalSeconds: 1588, // 26:27.85
        splitStyle: 'even',
        description:
            'Paul Tergat\'s iconic track 10,000m. Even, relentless, and historically dominant.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'kipyegon-1500',
        legendSlug: 'faith-kipyegon',
        name: 'Kipyegon — 1500m',
        distanceLabel: '1500m',
        distanceKm: 1.5,
        totalSeconds: 229, // 3:48.68
        splitStyle: 'even',
        description:
            'The queen of the mile at world-record pace. Two searing laps of the track.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'chebet-5000',
        legendSlug: 'beatrice-chebet',
        name: 'Chebet — 5000m',
        distanceLabel: '5000m',
        distanceKm: 5,
        totalSeconds: 845, // 14:05.20
        splitStyle: 'even',
        description:
            'The women\'s 5000m world record. Smooth, fast, and fearless from the gun.',
        accent: const Color(0xFFFF5A1F),
      ),

      // ---- New ghost paces (Step 7) ----
      _ghost(
        id: 'rudisha-800',
        legendSlug: 'david-rudisha',
        name: 'Rudisha — London 2012',
        distanceLabel: '800m',
        distanceKm: 0.8,
        totalSeconds: 101, // 1:40.91
        splitStyle: 'even',
        description:
            'The single greatest 800m ever run. Rudisha led from gun to tape in a world record 1:40.91.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'bekele-10000',
        legendSlug: 'kenenisa-bekele',
        name: 'Bekele — Beijing 2008',
        distanceLabel: '10,000m',
        distanceKm: 10,
        totalSeconds: 1621, // 27:01.17
        splitStyle: 'negative',
        description:
            'Bekele\'s Olympic 10,000m masterclass — a devastating negative split to seal the gold.',
        accent: const Color(0xFFFFD15C),
      ),
      _ghost(
        id: 'cheptegei-5000',
        legendSlug: 'joshua-cheptegei',
        name: 'Cheptegei — Monaco 2020',
        distanceLabel: '5000m',
        distanceKm: 5,
        totalSeconds: 755, // 12:35.36
        splitStyle: 'even',
        description:
            'The 5000m world record. Cheptegei\'s metronomic lap pace reset the event in Monaco.',
        accent: const Color(0xFF2BB673),
      ),
      _ghost(
        id: 'kosgei-marathon',
        legendSlug: 'brigid-kosgei',
        name: 'Kosgei — Chicago 2019',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 8044, // 2:14:04
        splitStyle: 'positive',
        description:
            'The women\'s marathon world record. Kosgei\'s patient, powerful run broke 2:15 for the first time.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'chepngetich-marathon',
        legendSlug: 'ruth-chepngetich',
        name: 'Chepngetich — Chicago 2024',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7796, // 2:09:56
        splitStyle: 'negative',
        description:
            'The first women\'s marathon under 2:10. A fearless, fast-starting negative split for the ages.',
        accent: const Color(0xFFFF5A1F),
      ),
      _ghost(
        id: 'gebrselassie-marathon',
        legendSlug: 'haile-gebrselassie',
        name: 'Gebrselassie — Berlin 2008',
        distanceLabel: 'Marathon',
        distanceKm: 42.195,
        totalSeconds: 7439, // 2:03:59
        splitStyle: 'even',
        description:
            'Haile\'s marathon world record at age 35 — smooth, even, and utterly dominant.',
        accent: const Color(0xFFFFD15C),
      ),
      _ghost(
        id: 'keino-1500',
        legendSlug: 'kipchoge-keino',
        name: 'Keino — Mexico 1968',
        distanceLabel: '1500m',
        distanceKm: 1.5,
        totalSeconds: 215, // 3:34.9
        splitStyle: 'even',
        description:
            'The race that launched East African dominance. Keino\'s front-running 1500m gold.',
        accent: const Color(0xFFFF5A1F),
      ),
    ];

Map<String, GhostPace>? _ghostById;

GhostPace ghostPaceForId(String id) {
  _ghostById ??= {for (final g in ghostPaces) g.id: g};
  return _ghostById![id] ?? ghostPaces.first;
}
