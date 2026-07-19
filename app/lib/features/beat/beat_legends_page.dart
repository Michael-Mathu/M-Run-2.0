import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/features/beat/pre_race_sheet.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';

class BeatLegendsPage extends ConsumerStatefulWidget {
  final String? id;
  const BeatLegendsPage({super.key, this.id});

  @override
  ConsumerState<BeatLegendsPage> createState() => _BeatLegendsPageState();
}

class _BeatLegendsPageState extends ConsumerState<BeatLegendsPage> {
  late GhostPace _selected;
  DifficultyTier _tier = DifficultyTier.goat;
  String _filter = 'all'; // 'all' or distance label

  @override
  void initState() {
    super.initState();
    _selected = widget.id != null ? ghostPaceForId(widget.id!) : ghostPaces.first;
  }

  List<GhostPace> get _filteredGhosts {
    if (_filter == 'all') return ghostPaces;
    return ghostPaces.where((g) => g.distanceLabel == _filter).toList();
  }

  List<String> get _distanceLabels {
    final labels = ghostPaces.map((g) => g.distanceLabel).toSet().toList();
    labels.sort((a, b) => _distanceOrder(a).compareTo(_distanceOrder(b)));
    return labels;
  }

  int _distanceOrder(String label) {
    switch (label) {
      case '800m': return 0;
      case '1500m': return 1;
      case '5000m': return 2;
      case '10,000m': return 3;
      case '10K': return 4;
      case 'Marathon': return 5;
      default: return 99;
    }
  }

  GhostPace get _active => _selected.forTier(_tier);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final activities = ref.watch(activitiesProvider);

    // Compute user's PB for each distance
    final pbMap = activities.maybeWhen(
      data: (list) => _computePBs(list),
      orElse: () => <String, int>{},
    );

    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(),
        title: Text(L10n.tr('beat_the_legends', locale)),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Distance filter tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
              child: _DistanceFilterTabs(
                labels: ['all', ..._distanceLabels],
                selected: _filter,
                onChanged: (v) => setState(() {
                  _filter = v;
                  if (!_filteredGhosts.any((g) => g.id == _selected.id)) {
                    _selected = _filteredGhosts.first;
                  }
                }),
                locale: locale,
                pbMap: pbMap,
                selectedGhost: _selected,
              ),
            ),
          ),
          // Ghost selector
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppTheme.s24, AppTheme.s16, AppTheme.s24, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredGhosts.length,
                    separatorBuilder: (_, index) => const SizedBox(width: AppTheme.s12),
                    itemBuilder: (_, i) {
                      final g = _filteredGhosts[i];
                      final active = g.id == _selected.id;
                      final accent = legendAccent(g.legend);
                      final userPb = pbMap[g.distanceLabel];
                      final pbText = userPb != null
                          ? '${L10n.tr('your_pb', locale)}: ${formatDuration(userPb)}'
                          : null;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = g),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: active ? accent.withValues(alpha: 0.2) : cs.surface,
                            borderRadius: BorderRadius.circular(AppTheme.r16),
                            border: active ? Border.all(color: accent, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(g.legend.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: AppTheme.s4),
                              Text(g.legend.name.split(' ').first,
                                  style: text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (pbText != null) ...[
                                const SizedBox(height: AppTheme.s2),
                                Text(pbText, style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
                _TierSelector(
                  tier: _tier,
                  onChanged: (t) => setState(() => _tier = t),
                  activeGhost: _selected,
                  recommendedTier: _recommendTier(_selected, pbMap),
                ),
                const SizedBox(height: AppTheme.s20),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GhostHeader(g: _active, locale: locale, pbMap: pbMap),
                const SizedBox(height: AppTheme.s16),
                Container(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppTheme.r16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(L10n.tr('pace_per_segment', locale), style: text.titleMedium),
Text(L10n.tr('seconds_per_km', locale),
                           style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
                      const SizedBox(height: AppTheme.s12),
                      SizedBox(height: 160, child: _SplitsChart(g: _active)),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
                Text(_active.description, style: text.bodyLarge!.copyWith(height: 1.6)),
                const SizedBox(height: AppTheme.s20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showPreRaceSheet(context, ref, _selected, _tier),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(L10n.tr('race_this_ghost', locale)),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.brand, padding: const EdgeInsets.symmetric(vertical: AppTheme.s16)),
                  ),
                ),
                const SizedBox(height: AppTheme.s12),
                Text(
                  '${L10n.tr('during_a_run', locale)}${formatDuration(_active.totalSeconds)}.',
                  style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.s32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _computePBs(List<RunRecord> activities) {
    final pbs = <String, int>{};
    for (final a in activities) {
      final distLabel = _distanceLabelFromKm(a.distanceM / 1000);
      final timeSec = a.durationMs ~/ 1000;
      if (!pbs.containsKey(distLabel) || timeSec < pbs[distLabel]!) {
        pbs[distLabel] = timeSec;
      }
    }
    return pbs;
  }

  String _distanceLabelFromKm(double km) {
    if (km < 1) return '800m';
    if (km < 2) return '1500m';
    if (km < 6) return '5000m';
    if (km < 15) return '10K';
    return 'Marathon';
  }

  DifficultyTier? _recommendTier(GhostPace ghost, Map<String, int> pbMap) {
    final userPb = pbMap[ghost.distanceLabel];
    if (userPb == null) return null;

    // Find the hardest tier the user could realistically beat
    for (final tier in DifficultyTier.values.reversed) {
      final scaled = (ghost.totalSeconds * tier.factor).round();
      if (userPb <= scaled) {
        return tier == DifficultyTier.goat ? null : DifficultyTier.values[tier.index + 1];
      }
    }
    return DifficultyTier.bronze;
  }
}

class _DistanceFilterTabs extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;
  final AppLocale locale;
  final Map<String, int> pbMap;
  final GhostPace selectedGhost;

  const _DistanceFilterTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.locale,
    required this.pbMap,
    required this.selectedGhost,
  });

  DifficultyTier? get _recommendedTier {
    final userPb = pbMap[selectedGhost.distanceLabel];
    if (userPb == null) return null;
    for (final tier in DifficultyTier.values.reversed) {
      final scaled = (selectedGhost.totalSeconds * tier.factor).round();
      if (userPb <= scaled) {
        return tier == DifficultyTier.goat ? null : DifficultyTier.values[tier.index + 1];
      }
    }
    return DifficultyTier.bronze;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final recommendedTier = _recommendedTier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recommendedTier != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.s12),
            decoration: BoxDecoration(
              color: recommendedTier.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.r12),
              border: Border.all(color: recommendedTier.color.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: recommendedTier.color, size: 20),
                const SizedBox(width: AppTheme.s8),
                Expanded(
                  child: Text(
                    '${L10n.tr('tier_recommendation', locale)} ${recommendedTier.badge} ${recommendedTier.label} — ${L10n.tr('based_on_your_pb', locale)}',
                    style: text.bodySmall!.copyWith(color: recommendedTier.color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.s12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.r12),
          ),
          child: Row(
            children: [
              for (final label in labels) ...[
                if (label != labels.first) const SizedBox(width: AppTheme.s4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.s10),
                      decoration: BoxDecoration(
                        color: label == selected ? AppTheme.brand.withValues(alpha: 0.22) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.r8),
                        border: label == selected ? Border.all(color: AppTheme.brand) : null,
                      ),
                      child: Text(
                        label == 'all' ? L10n.tr('all_distances', locale) : label,
                        textAlign: TextAlign.center,
                        style: text.labelSmall!.copyWith(
                          color: label == selected ? AppTheme.brand : cs.onSurface.withValues(alpha: 0.6),
                          fontWeight: label == selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TierSelector extends StatelessWidget {
  final DifficultyTier tier;
  final ValueChanged<DifficultyTier> onChanged;
  final GhostPace activeGhost;
  final DifficultyTier? recommendedTier;

  const _TierSelector({
    required this.tier,
    required this.onChanged,
    required this.activeGhost,
    this.recommendedTier,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s4, vertical: AppTheme.s4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.r12),
      ),
      child: Row(
        children: [
          for (final t in DifficultyTier.values) ...[
            if (t != DifficultyTier.values.first)
              const SizedBox(width: AppTheme.s4),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.s10),
                  decoration: BoxDecoration(
                    color: t == tier ? t.color.withValues(alpha: 0.22) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.r8),
                    border: t == tier ? Border.all(color: t.color) : null,
                  ),
                  child: Column(
                    children: [
                      Text(t.badge, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: AppTheme.s2),
                      Text(t.label,
                          style: text.labelSmall!.copyWith(
                            color: t == tier ? t.color : cs.onSurface.withValues(alpha: 0.6),
                            fontWeight: t == tier ? FontWeight.w700 : FontWeight.w600,
                          )),
                      if (t == recommendedTier)
                        Text('★', style: TextStyle(fontSize: 10, color: t.color)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GhostHeader extends StatelessWidget {
  final GhostPace g;
  final AppLocale locale;
  final Map<String, int> pbMap;

  const _GhostHeader({required this.g, required this.locale, required this.pbMap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = legendAccent(g.legend);
    final userPb = pbMap[g.distanceLabel];
    final pbComparison = userPb != null
        ? ((g.totalSeconds - userPb) / userPb * 100).round()
        : null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.r24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: Colors.white.withValues(alpha: 0.2), child: Text(g.legend.emoji, style: const TextStyle(fontSize: 30))),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: text.titleLarge!.copyWith(color: Colors.white)),
                    const SizedBox(height: AppTheme.s4),
                    Text('${g.distanceLabel} · ${L10n.tr('target', locale)} ${formatDuration(g.totalSeconds)}',
                        style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92))),
                    const SizedBox(height: AppTheme.s2),
                    Text('${L10n.tr('avg', locale)} ${formatPace(g.avgPaceMinPerKm)} /km',
                        style: text.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92))),
                  ],
                ),
              ),
            ],
          ),
          if (userPb != null) ...[
            const SizedBox(height: AppTheme.s16),
            Container(
              padding: const EdgeInsets.all(AppTheme.s12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.r12),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: AppTheme.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${L10n.tr('your_pb', locale)}: ${formatDuration(userPb)}',
                          style: text.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          pbComparison != null
                              ? (pbComparison > 0
                                  ? '+$pbComparison% ${L10n.tr('slower_than_ghost', locale)}'
                                  : '${pbComparison.abs()}% ${L10n.tr('faster_than_ghost', locale)}')
                              : L10n.tr('no_pb_yet', locale),
                          style: text.labelSmall!.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SplitsChart extends StatelessWidget {
  final GhostPace g;
  const _SplitsChart({required this.g});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = legendAccent(g.legend);
    final axisText = TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 10);
    final (min, max) = g.splits.fold<(double, double)>(
      (double.infinity, double.negativeInfinity),
      ((double, double) acc, double v) => (math.min(acc.$1, v), math.max(acc.$2, v)),
    );
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [for (int i = 0; i < g.splits.length; i++) FlSpot(i.toDouble(), g.splits[i])],
            color: accent,
            dotData: FlDotData(show: false),
            isCurved: true,
            curveSmoothness: 0.3,
            belowBarData: BarAreaData(show: true, color: accent.withValues(alpha: 0.14)),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.toInt() + 1}', style: axisText),
              interval: (g.splits.length / 6).ceilToDouble().clamp(1, 999),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text('${v.toInt()}s', style: axisText),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: cs.onSurfaceVariant.withValues(alpha: 0.12))),
        borderData: FlBorderData(show: false),
        minY: min * 0.95,
        maxY: max * 1.05,
      ),
    );
  }
}