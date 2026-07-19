import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/gamification/challenge_evaluator.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/learn/data/courses.dart';
import 'package:mwendo_app/features/learn/data/legend_of_day.dart';
import 'package:mwendo_app/widgets/metric_tile.dart';
import 'package:mwendo_app/widgets/section_title.dart';
import 'package:mwendo_app/widgets/skeleton.dart';
import 'package:mwendo_app/widgets/trailing_chevron.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _corruptionShown = false;

  @override
  void initState() {
    super.initState();
    _corruptionShown = false;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final g = ref.watch(gamificationProvider);
    final locale = ref.watch(localeProvider);
    final recent = ref.watch(activitiesProvider);

    final corrupted = ref.watch(gamificationCorruptedProvider);
    if (corrupted && !_corruptionShown) {
      _corruptionShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.tr('progress_reset', locale)),
              action: SnackBarAction(
                label: L10n.tr('ok', locale),
                onPressed: () {},
              ),
            ),
          );
        }
      });
    }

    final active = ChallengeEvaluator.allChallenges
        .where((c) => !g.completedChallenges.contains(c.slug))
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activitiesProvider);
            ref.invalidate(gamificationProvider);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TopBar(g: g, locale: locale),
                  const SizedBox(height: AppTheme.s24),
                  _WeeklyCard(g: g, recent: recent, text: text, locale: locale),
                  const SizedBox(height: AppTheme.s20),
                  _StartRunButton(),
                  if (g.totalRuns == 0) ...[
                    const SizedBox(height: AppTheme.s20),
                    _FirstRunHint(onTap: () => context.go('/run'), locale: locale),
                  ],
                  const SizedBox(height: AppTheme.s20),
                  const LegendOfDayCard(),
                  const SizedBox(height: AppTheme.s28),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SectionTitle(L10n.tr('active_challenges', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/challenges')),
                  const SizedBox(height: AppTheme.s4),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              sliver: SliverList.separated(
                separatorBuilder: (_, index) => const SizedBox(height: AppTheme.s12),
                itemCount: active.isEmpty ? 1 : active.length,
                itemBuilder: (_, i) {
                  if (active.isEmpty) {
                    return _AllDoneCard(cs: cs, text: text, onTap: () => context.go('/challenges'));
                  }
                  return _DashboardChallengeCard(ch: active[i], g: g, onTap: () => context.pushSafe('/challenges/${active[i].slug}'));
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s12, AppTheme.s24, AppTheme.s24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
SectionTitle(L10n.tr('continue_learning', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/learn')),
                  const SizedBox(height: AppTheme.s4),
                  _LearnRow(locale: locale),
                  const SizedBox(height: AppTheme.s12),
                  SectionTitle(L10n.tr('recent_activity', locale),
                      actionLabel: L10n.tr('see_all', locale),
                      onAction: () => context.go('/activity')),
                  const SizedBox(height: AppTheme.s4),
                  AnimatedSwitcher(
                    duration: AppTheme.dFast,
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: recent.when(
                      loading: () => const KeyedSubtree(
                        key: ValueKey('recent-loading'),
                        child: Column(
                          children: [SkeletonCard(height: 88), SizedBox(height: AppTheme.s12), SkeletonCard(height: 88)],
                        ),
                      ),
                      error: (_, _) => KeyedSubtree(
                        key: const ValueKey('recent-error'),
                        child: _EmptyActivity(
                            text: text, cs: cs, locale: locale, onWalkRun: () => context.go('/run'), onCourse: () => context.go('/learn/course/how-to-start-running')),
                      ),
                      data: (runs) => KeyedSubtree(
                        key: ValueKey('recent-data-\${runs.length}'),
                        child: runs.isEmpty
                            ? _EmptyActivity(
                                text: text, cs: cs, locale: locale, onWalkRun: () => context.go('/run'), onCourse: () => context.go('/learn/course/how-to-start-running'))
                            : Column(
                                children: [
                                  for (final r in runs.take(3))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: AppTheme.s12),
                                      child: _RecentRunTile(r: r),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s24),
                ]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _TopBar extends StatelessWidget {
  final GamificationState g;
  final AppLocale locale;
  const _TopBar({required this.g, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(AppTheme.r12),
          ),
          child: const Icon(Icons.directions_run_rounded, color: Colors.white),
        ),
        const SizedBox(width: AppTheme.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.tr('home', locale), style: text.labelMedium),
              Text('Mwendo', style: text.titleLarge),
            ],
          ),
        ),
        if (g.streakDays > 0)
          Semantics(
            label: '${L10n.tr('streak', locale)} ${g.streakDays}',
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.s8),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
              decoration: BoxDecoration(
                color: AppTheme.tierGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppTheme.rFull),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: AppTheme.tierGold, size: 16),
                  const SizedBox(width: AppTheme.s4),
                  Text('${g.streakDays}', style: text.labelMedium!.copyWith(color: AppTheme.tierGold)),
                ],
              ),
            ),
          ),
        Semantics(
          label: '${L10n.tr('level', locale)} ${g.level}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.rFull),
            ),
            child: Text('${L10n.tr('lv', locale)} ${g.level}', style: text.labelMedium!.copyWith(color: AppTheme.brand)),
          ),
        ),
      ],
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final GamificationState g;
  final AsyncValue<List<RunRecord>> recent;
  final TextTheme text;
  final AppLocale locale;
  const _WeeklyCard({required this.g, required this.recent, required this.text, required this.locale});

  @override
  Widget build(BuildContext context) {
    // Real "this week" aggregate: runs whose start is on/after the Monday of
    // the current week. Same 7-day window approach used in profile_page.dart.
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final runs = recent.value ?? const <RunRecord>[];
    final weekly = runs.where((r) => !r.startedAt.isBefore(weekStart)).toList();
    final wDist = weekly.fold(0.0, (s, r) => s + r.distanceM);
    final wTime = weekly.fold(0, (s, r) => s + r.durationMs);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.r24),
        boxShadow: [
          BoxShadow(color: AppTheme.brand.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.tr('this_week', locale), style: text.labelMedium!.copyWith(color: Colors.white70)),
          const SizedBox(height: AppTheme.s4),
          Text(formatDistance(wDist),
              style: text.displayMedium!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: AppTheme.s20),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  variant: MetricVariant.hero,
                  label: L10n.tr('runs', locale),
                  value: weekly.length.toString(),
                ),
              ),
              Expanded(
                child: MetricTile(
                  variant: MetricVariant.hero,
                  label: L10n.tr('time', locale),
                  value: formatDuration(wTime),
                ),
              ),
              Expanded(
                child: MetricTile(
                  variant: MetricVariant.hero,
                  label: L10n.tr('best', locale),
                  value: g.bestPaceMinPerKm > 0 ? formatPace(g.bestPaceMinPerKm) : '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartRunButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return FilledButton.icon(
      onPressed: () {
        Haptics.light();
        context.go('/run');
      },
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: Text(L10n.tr('start_run', ref.watch(localeProvider))),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
        textStyle: text.labelLarge!.copyWith(fontSize: 16),
      ),
    );
  }
}

class _FirstRunHint extends StatefulWidget {
  final VoidCallback onTap;
  final AppLocale locale;
  const _FirstRunHint({required this.onTap, required this.locale});

  @override
  State<_FirstRunHint> createState() => _FirstRunHintState();
}

class _FirstRunHintState extends State<_FirstRunHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.04).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: FilledButton(
        onPressed: widget.onTap,
        style: FilledButton.styleFrom(
          backgroundColor: cs.surface,
          foregroundColor: cs.onSurface,
          padding: const EdgeInsets.all(AppTheme.s20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r16)),
          side: BorderSide(color: AppTheme.brand, width: 4),
          elevation: 0,
          shadowColor: AppTheme.brand.withValues(alpha: 0.12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppTheme.r12),
              ),
              child: const Icon(Icons.directions_run_rounded, color: AppTheme.brand, size: 28),
            ),
            const SizedBox(width: AppTheme.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.tr('get_started', widget.locale), style: text.titleMedium),
                  const SizedBox(height: AppTheme.s4),
                  Text(L10n.tr('first_run_hint', widget.locale),
                      style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _DashboardChallengeCard extends StatelessWidget {
  final GamifiedChallenge ch;
  final GamificationState g;
  final VoidCallback onTap;
  const _DashboardChallengeCard({required this.ch, required this.g, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final ratio = ch.ratio(g);
    final accent = AppTheme.tierColors[ch.tier] ?? AppTheme.brand;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border(left: BorderSide(color: accent, width: 4)),
        boxShadow: AppTheme.elevation1,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: () {
          Haptics.light();
          onTap();
        },
        child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ch.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppTheme.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ch.title, style: text.titleMedium),
                      const SizedBox(height: AppTheme.s2),
                      Text(ch.description, style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppTheme.s8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.rFull),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: accent.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.s12),
                Column(
                  children: [
                    Text('+${ch.xp}', style: text.labelMedium!.copyWith(color: accent)),
                    Text('XP', style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _AllDoneCard extends ConsumerWidget {
  final ColorScheme cs;
  final TextTheme text;
  final VoidCallback onTap;
  const _AllDoneCard({required this.cs, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.surface, AppTheme.tierGold.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: AppTheme.tierGold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [BoxShadow(color: AppTheme.tierGold.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.r16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.tierGold, AppTheme.achievement],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppTheme.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L10n.tr('all_caught_up', locale), style: text.titleMedium),
                      const SizedBox(height: AppTheme.s2),
                      Text(L10n.tr('browse_more', locale),
                          style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.tierGold.withValues(alpha: 0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearnRow extends StatelessWidget {
  final AppLocale locale;
  const _LearnRow({required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final picks = courses.take(3).toList();
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: picks.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppTheme.s12),
        itemBuilder: (_, i) {
          final c = picks[i];
          final accent = c.category.accent;
          return SizedBox(
            width: 200,
            child: Material(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.r16),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.r16),
                onTap: () => context.go('/learn/course/${c.slug}'),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: accent.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(AppTheme.r12)),
                        child: Icon(c.category.icon, color: accent),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        child: Text(lt(c.title, locale), style: text.titleMedium!.copyWith(color: cs.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

({Color color, IconData icon}) _runTypeMeta(String type) {
  final lower = type.toLowerCase();
  if (lower.contains('walk')) return (color: AppTheme.flagGreen, icon: Icons.directions_walk_rounded);
  if (lower.contains('trail')) return (color: const Color(0xFF8B5E3C), icon: Icons.terrain_rounded);
  if (lower.contains('race') || lower.contains('interval')) return (color: AppTheme.recording, icon: Icons.speed_rounded);
  if (lower.contains('hike')) return (color: const Color(0xFF7B6B4F), icon: Icons.landscape_rounded);
  return (color: AppTheme.brand, icon: Icons.directions_run_rounded);
}

class _RecentRunTile extends StatelessWidget {
  final RunRecord r;
  const _RecentRunTile({required this.r});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final meta = _runTypeMeta(r.type);
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        boxShadow: [BoxShadow(color: meta.color.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.r16),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.r16),
          onTap: () => context.go('/activity/${r.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppTheme.r12),
                  ),
                  child: Icon(meta.icon, color: meta.color),
                ),
                const SizedBox(width: AppTheme.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.type, style: text.titleMedium),
                      const SizedBox(height: AppTheme.s2),
                      Text(
                        '${formatDistance(r.distanceM)} · ${formatDuration(r.durationMs)}',
                        style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                const TrailingChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final TextTheme text;
  final ColorScheme cs;
  final AppLocale locale;
  final VoidCallback? onWalkRun;
  final VoidCallback? onCourse;
  const _EmptyActivity({
    required this.text,
    required this.cs,
    required this.locale,
    this.onWalkRun,
    this.onCourse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.s32),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppTheme.r16),
            border: Border.all(color: AppTheme.success.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              const _RunIllustration(),
              const SizedBox(height: AppTheme.s12),
              Text(L10n.tr('no_runs_yet', locale), style: text.titleMedium),
              const SizedBox(height: AppTheme.s4),
              Text(L10n.tr('routes_will_show', locale),
                  style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.s12),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.r16),
            border: Border(left: BorderSide(color: AppTheme.brand, width: 4)),
            boxShadow: [BoxShadow(color: AppTheme.brand.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.r16),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.r16),
              onTap: () {
                Haptics.light();
                onCourse?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.s16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppTheme.r12),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppTheme.brand, size: 24),
                    ),
                    const SizedBox(width: AppTheme.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(L10n.tr('learn_to_run', locale), style: text.titleMedium),
                          const SizedBox(height: AppTheme.s2),
                          Text(L10n.tr('learn_to_run_hint', locale),
                              style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.s12),
        FilledButton.icon(
          onPressed: () {
            Haptics.light();
            onWalkRun?.call();
          },
          icon: const Icon(Icons.directions_run_rounded, size: 22),
          label: Text(L10n.tr('walk_run_now', locale)),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
          ),
        ),
      ],
    );
  }
}

/// Lightweight animated illustration for empty states: a bouncing runner on a
/// softly pulsing ring. Pure Flutter, no assets required.
class _RunIllustration extends StatefulWidget {
  const _RunIllustration();

  @override
  State<_RunIllustration> createState() => _RunIllustrationState();
}

class _RunIllustrationState extends State<_RunIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final Animation<double> _bob =
      Tween<double>(begin: -4, end: 4).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  late final Animation<double> _ring =
      Tween<double>(begin: 0.55, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Runner illustration',
      child: SizedBox(
        height: 72,
        width: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ring,
              builder: (_, _) => Container(
                width: 64 * _ring.value,
                height: 64 * _ring.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.brand.withValues(alpha: 0.12 * (1 - _ring.value + 0.4)),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _bob,
              builder: (_, _) => Transform.translate(
                offset: Offset(0, _bob.value),
                child: const Text('🏃', style: TextStyle(fontSize: 36)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}