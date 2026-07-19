import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/widgets/level_ring.dart';

class ChallengesLibraryPage extends ConsumerStatefulWidget {
  const ChallengesLibraryPage({super.key});

  @override
  ConsumerState<ChallengesLibraryPage> createState() => _ChallengesLibraryPageState();
}

class _ChallengesLibraryPageState extends ConsumerState<ChallengesLibraryPage> {
  ChallengeCategory? _filter;
  final _cats = const [
    ChallengeCategory.starter,
    ChallengeCategory.milestone,
    ChallengeCategory.performance,
    ChallengeCategory.fun,
    ChallengeCategory.school,
    ChallengeCategory.knowledge,
  ];

  @override
  Widget build(BuildContext context) {
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);

    final items = ChallengeEvaluator.allChallenges
        .where((c) => _filter == null || c.category == _filter)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(L10n.tr('challenges', locale)), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _LevelHeader(),
                const SizedBox(height: AppTheme.s16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cats.length + 1,
                    separatorBuilder: (_, index) => const SizedBox(width: AppTheme.s8),
                    itemBuilder: (_, i) {
                       if (i == 0) {
                         return _FilterChip(
                           label: L10n.tr('all', locale),
                           active: _filter == null,
                           onTap: () => setState(() => _filter = null),
                         );
                       }
                       final c = _cats[i - 1];
                       return _FilterChip(
                         label: _catLabel(c, locale),
                         active: _filter == c,
                         onTap: () => setState(() => _filter = _filter == c ? null : c),
                       );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, 0, AppTheme.s24, AppTheme.s24),
            sliver: SliverList.separated(
              separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
              itemCount: items.length,
              itemBuilder: (_, i) => _ChallengeCard(ch: items[i], g: g, locale: locale),
            ),
          ),
        ],
      ),
    );
  }
}

String _catLabel(ChallengeCategory c, AppLocale locale) => {
      ChallengeCategory.starter: L10n.tr('cat_starter', locale),
      ChallengeCategory.milestone: L10n.tr('cat_milestone', locale),
      ChallengeCategory.performance: L10n.tr('cat_performance', locale),
      ChallengeCategory.fun: L10n.tr('cat_fun', locale),
      ChallengeCategory.school: L10n.tr('cat_school', locale),
      ChallengeCategory.knowledge: L10n.tr('cat_knowledge', locale),
    }[c]!;

class _LevelHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r24),
        border: Border.all(color: AppTheme.brand.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          LevelRing(level: g.level, progress: g.levelProgress, size: 60),
          const SizedBox(width: AppTheme.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${L10n.tr('level', locale)} ${g.level} · ${g.title}',
                    style: text.titleMedium),
                const SizedBox(height: AppTheme.s8),
                XpBar(
                  xpIntoLevel: g.xpIntoLevel,
                  xpForNextLevel: g.xpForNextLevel,
                  progress: g.levelProgress,
                ),
                const SizedBox(height: AppTheme.s8),
                Text('${g.xp} ${L10n.tr('total_xp', locale)} · ${g.completedChallenges.length} ${L10n.tr('challenges_done', locale)}',
                    style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s8),
        decoration: BoxDecoration(
          color: active ? AppTheme.brand.withValues(alpha: 0.18) : cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.rFull),
          border: active ? Border.all(color: AppTheme.brand) : null,
        ),
        child: Text(label,
            style: text.labelMedium!.copyWith(
                color: active ? AppTheme.brand : cs.onSurface.withValues(alpha: 0.7),
                fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }
}


class _ChallengeCard extends StatelessWidget {
  final GamifiedChallenge ch;
  final GamificationState g;
  final AppLocale locale;
  const _ChallengeCard({required this.ch, required this.g, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ratio = ch.ratio(g);
    final done = ch.isComplete(g);
    final color = tierColor(ch.tier);
    final progressColor = done ? context.tokens.flagGreen : color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surface, color.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.r16),
        boxShadow: done
            ? <BoxShadow>[BoxShadow(color: progressColor.withValues(alpha: 0.45), blurRadius: 16, spreadRadius: 1)]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () {
          Haptics.light();
          context.pushSafe('/challenges/${ch.slug}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(ch.icon, color: color, size: 28),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ch.title, style: text.titleMedium),
                    const SizedBox(height: AppTheme.s2),
                    Text(
                      ch.description,
                      style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.s8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.rFull),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(progressColor),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s6),
                    Text(
                      done ? L10n.tr('completed', locale) : ch.progressText(g),
                      style: text.labelSmall!.copyWith(color: done ? progressColor : cs.onSurface.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.s12),
              Column(
                children: [
                  Text('+${ch.xp}', style: text.labelMedium!.copyWith(color: color)),
                  Text('XP', style: text.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
