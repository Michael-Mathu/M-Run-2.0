import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';

class ChallengeDetailPage extends ConsumerWidget {
  final String slug;
  const ChallengeDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = ChallengeEvaluator.allChallenges.firstWhere((c) => c.slug == slug,
        orElse: () => ChallengeEvaluator.allChallenges.first);
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = tierColor(ch.tier);
    final ratio = ch.ratio(g);
    final done = ch.isComplete(g);

    final toAcademy = ch.category == ChallengeCategory.knowledge;
    final ctaLabel = done
        ? L10n.tr('completed', locale)
        : (toAcademy ? L10n.tr('open_academy', locale) : L10n.tr('go_for_a_run', locale));
    final ctaRoute = toAcademy ? '/learn' : '/run';

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ch.title),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(AppTheme.s24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.r24),
                  ),
                  child: Column(
                    children: [
                      Icon(ch.icon, color: Colors.white, size: 48),
                      const SizedBox(height: AppTheme.s12),
                      Text(ch.title,
                          style: text.headlineLarge!.copyWith(color: Colors.white),
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppTheme.s8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.rFull),
                        ),
                        child: Text(_tierName(ch.tier).toUpperCase(),
                            style: text.labelSmall!.copyWith(color: Colors.white, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.s20),
                Text(ch.description, style: text.bodyLarge!.copyWith(height: 1.6)),
                const SizedBox(height: AppTheme.s20),
                Row(
                  children: [
                    _InfoTile(label: L10n.tr('reward', locale), value: '+${ch.xp} XP'),
                    _InfoTile(label: L10n.tr('badge', locale), value: ch.badgeEmoji),
                    _InfoTile(label: L10n.tr('goal', locale), value: '${ch.target} ${ch.goalLabel}'),
                  ],
                ),
                const SizedBox(height: AppTheme.s20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.rFull),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
                Text(done ? L10n.tr('challenge_complete', locale) : ch.progressText(g),
                    style: text.bodyMedium!.copyWith(color: done ? color : cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: AppTheme.s28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: done ? null : () => context.go(ctaRoute),
                    icon: Icon(toAcademy ? Icons.school_rounded : Icons.play_arrow_rounded),
                    label: Text(ctaLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: done ? cs.surfaceContainerHighest : color,
                      foregroundColor: done ? cs.onSurface.withValues(alpha: 0.6) : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.s24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _tierName(ChallengeTier t) => {
        ChallengeTier.bronze: 'Bronze',
        ChallengeTier.silver: 'Silver',
        ChallengeTier.gold: 'Gold',
        ChallengeTier.platinum: 'Platinum',
      }[t]!;
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.s12),
        padding: const EdgeInsets.all(AppTheme.s16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.r12),
        ),
        child: Column(
          children: [
            Text(value, style: text.titleMedium),
            const SizedBox(height: AppTheme.s4),
            Text(label.toUpperCase(),
                style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }
}
