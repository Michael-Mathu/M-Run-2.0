import 'package:flutter/material.dart';
import 'package:mwendo_app/core/gamification/gamification_state.dart';

class GamifiedChallenge {
  final String slug;
  final String title;
  final String description;
  final IconData icon;
  final int xp;
  final String tier;
  const GamifiedChallenge({
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
    required this.tier,
  });
  double ratio(GamificationState g) => 0.0;
}

class ChallengeEvaluator {
  static final allChallenges = const <GamifiedChallenge>[];
  static final beatALegend = GamifiedChallenge(
    slug: 'beat-a-legend',
    title: 'Beat a Legend',
    description: 'Challenge a legendary runner',
    icon: Icons.speed_rounded,
    xp: 100,
    tier: 'gold',
  );
}

Color tierColor(String tier) => const Color(0xFFFF5A1F);