import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/data/sample_activities.dart';
import 'package:mwendo_app/design_system/app_share_card.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';
import 'package:mwendo_app/widgets/metric_tile.dart';
import 'package:mwendo_app/widgets/route_map.dart';
import 'package:mwendo_app/widgets/skeleton.dart';
import 'package:mwendo_app/widgets/app_card.dart';

class ActivityDetailPage extends ConsumerWidget {
  final String id;
  const ActivityDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRun = ref.watch(activityByIdProvider(id));
    if (asyncRun.isLoading) {
      return const Scaffold(body: SafeArea(child: _DetailSkeleton()));
    }
    final run = asyncRun.value;
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    if (run == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(L10n.tr('activity', locale)),
        ),
        body: SafeArea(
          child: _ActivityNotFound(text: text, cs: cs, locale: locale),
        ),
      );
    }
    final a = run.toSampleActivity();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: L10n.tr('share', ref.read(localeProvider)),
            onPressed: () => SharePlus.instance.share(ShareParams(
              text: 'I just completed a ${a.type} — '
                  '${formatDistance(a.distanceM)} in ${formatDuration(a.durationMs)} '
                  'via Mwendo!',
            )),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: RouteMap(points: a.route.map((p) => latlong.LatLng(p.latitude, p.longitude)).toList()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(a.type, style: text.headlineLarge),
                const SizedBox(height: AppTheme.s4),
                Text(
                  '${a.startedAt.day}/${a.startedAt.month}/${a.startedAt.year}',
                  style: text.bodyMedium!
                      .copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: AppTheme.s20),
                _StatsGrid(a: a, locale: locale),
                const SizedBox(height: AppTheme.s28),
                _ChartCard(
                  title: L10n.tr('elevation', locale),
                  unit: 'm',
                  values: a.elevation,
                  color: context.tokens.flagGreen,
                ),
                const SizedBox(height: AppTheme.s16),
                _ChartCard(
                  title: L10n.tr('pace', locale),
                  unit: '/km',
                  values: a.pace,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: AppTheme.s24),

                // ---- Share Card ----
                Text(L10n.tr('share', locale), style: text.titleLarge),
                const SizedBox(height: AppTheme.s12),
                AppShareCard(
                  metricValue: formatDistance(a.distanceM),
                  metricLabel: L10n.tr('distance', locale),
                  subtitle: '${a.type} · ${formatDuration(a.durationMs)}',
                ),
                const SizedBox(height: AppTheme.s24),

                // ---- Post-run Learning Insight ----
                _LearningInsightCard(a: a, locale: locale),
                const SizedBox(height: AppTheme.s24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final SampleActivity a;
  final AppLocale locale;
  const _StatsGrid({required this.a, required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = <(String, String)>[
      (formatDistance(a.distanceM), L10n.tr('distance', locale)),
      (formatPace(a.avgPaceMinPerKm), L10n.tr('avg_pace', locale)),
      (formatDuration(a.durationMs), L10n.tr('time', locale)),
      (a.calories.toString(), L10n.tr('calories', locale)),
      (a.elevationGainM.toStringAsFixed(0), L10n.tr('elev_gain', locale)),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.s12,
      crossAxisSpacing: AppTheme.s12,
      childAspectRatio: 1.6,
      children: items
          .map((s) => Container(
                padding: const EdgeInsets.all(AppTheme.s12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppTheme.r12),
                ),
                child: Center(
                  child: MetricTile(
                    value: s.$1,
                    label: s.$2,
                    variant: MetricVariant.card,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final List<double> values;
  final Color color;

  const _ChartCard({
    required this.title,
    required this.unit,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final (min, max) = values.fold<(double, double)>(
      (double.infinity, double.negativeInfinity),
      ((double, double) acc, double v) => (math.min(acc.$1, v), math.max(acc.$2, v)),
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          Text('${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} $unit',
              style: text.bodySmall!
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
          const SizedBox(height: AppTheme.s12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i]),
                    ],
                    color: color,
                    dotData: FlDotData(show: false),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.14),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                minY: min,
                maxY: max,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 260, child: Skeleton(radius: 0)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Skeleton(height: 28, width: 160),
                const SizedBox(height: AppTheme.s12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppTheme.s12,
                  crossAxisSpacing: AppTheme.s12,
                  childAspectRatio: 1.6,
                  children: [for (int i = 0; i < 6; i++) const Skeleton(height: 56)],
                ),
                const SizedBox(height: AppTheme.s16),
                const SkeletonCard(height: 180),
                const SizedBox(height: AppTheme.s16),
                const SkeletonCard(height: 180),
              ]),
            ),
          ),
        ],
      );
}

class _LearningInsightCard extends StatelessWidget {
  final SampleActivity a;
  final AppLocale locale;
  const _LearningInsightCard({required this.a, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    // Pick a relevant legend based on run type and distance.
    // Long runs -> endurance legends (Kipchoge, Kipyegon)
    // Fast runs -> speed legends (Kipchoge, Kiplimo)
    // Trail -> terrain legends
    Legend legend;
    final isLongRun = a.distanceM >= 21097; // half marathon+
    final isFast = a.avgPaceMinPerKm < 5.0; // sub-5 min/km
    final isTrail = a.type.toLowerCase().contains('trail');

    if (isLongRun) {
      legend = legends.firstWhere((l) => l.slug == 'eliud-kipchoge',
          orElse: () => legends.first);
    } else if (isFast) {
      legend = legends.firstWhere((l) => l.slug == 'faith-kipyegon',
          orElse: () => legends.first);
    } else if (isTrail) {
      legend = legends.firstWhere((l) => l.slug == 'kilian-jornet',
          orElse: () => legends.first);
    } else {
      // Default: rotate by run ID hash for consistency
      final idx = a.id.hashCode.abs() % legends.length;
      legend = legends[idx];
    }
    final accent = legendAccent(legend);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10n.tr('learning_insight', locale), style: text.titleLarge),
        const SizedBox(height: AppTheme.s12),
        AppCard(
          onTap: () => context.go('/learn/legends/${legend.slug}'),
          useInkWell: true,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Text(legend.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(legend.name, style: text.titleMedium),
                    const SizedBox(height: AppTheme.s4),
                    Text(
                      legend.trainingPhilosophy != null
                          ? lt(legend.trainingPhilosophy!, AppLocale.english).split('.').first
                          : lt(legend.tagline, AppLocale.english),
                      style: text.bodySmall!.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityNotFound extends StatelessWidget {
  final TextTheme text;
  final ColorScheme cs;
  final AppLocale locale;
  const _ActivityNotFound({
    required this.text,
    required this.cs,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 44, color: cs.onSurface.withValues(alpha: 0.38)),
            ),
            const SizedBox(height: AppTheme.s16),
            Text(L10n.tr('activity_not_found', locale), style: text.titleMedium),
            const SizedBox(height: AppTheme.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
              child: Text(
                L10n.tr('activity_not_found_body', locale),
                style: text.bodySmall!
                    .copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
}
