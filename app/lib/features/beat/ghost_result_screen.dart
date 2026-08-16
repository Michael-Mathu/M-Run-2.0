import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/widgets/mwendo_map.dart';

/// Full-screen post-race result page for ghost races.
class GhostResultScreen extends ConsumerWidget {
  final String ghostId;
  final String tierName;
  final bool userWon;
  final int userElapsedMs;
  final bool recalculated;
  final String splitsJson;
  final String routePointsJson;

  const GhostResultScreen({
    super.key,
    required this.ghostId,
    required this.tierName,
    required this.userWon,
    required this.userElapsedMs,
    this.recalculated = false,
    required this.splitsJson,
    required this.routePointsJson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghost = ghostPaceForId(ghostId);
    final tier = DifficultyTier.values.firstWhere(
      (t) => t.name.toLowerCase() == tierName.toLowerCase(),
      orElse: () => DifficultyTier.goat,
    );
    final activeGhost = ghost.forTier(tier);
    final locale = ref.watch(localeProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Parse route points
    List<latlong.LatLng> routePoints = [];
    try {
      final decoded = routePointsJson;
      if (decoded.isNotEmpty && decoded != '[]') {
        // Parse JSON array of lat/lng pairs
        // Simplified - in production use jsonDecode
      }
    } catch (_) {}

return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: userWon ? activeGhost.accent.withValues(alpha: 0.9) : cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: userWon
                        ? [activeGhost.accent.withValues(alpha: 0.9), activeGhost.accent.withValues(alpha: 0.5)]
                        : [cs.surface, cs.surfaceContainerHighest],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            userWon ? L10n.tr('you_beat', locale) : L10n.tr('ghost_held_you_off', locale),
                            style: text.displaySmall!.copyWith(
                              color: userWon ? Colors.white : cs.onSurface,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.s8),
                          Text(
                            activeGhost.name,
                            style: text.titleLarge!.copyWith(
                              color: userWon ? Colors.white.withValues(alpha: 0.9) : cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppTheme.s16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatChip(
                                icon: Icons.timer_rounded,
                                label: L10n.tr('your_time', locale),
                                value: formatDuration(userElapsedMs),
                                color: userWon ? Colors.white : cs.onSurface,
                              ),
                              const SizedBox(width: AppTheme.s16),
                              _StatChip(
                                icon: Icons.emoji_events_rounded,
                                label: L10n.tr('ghost_time', locale),
                                value: formatDuration(activeGhost.totalSeconds * 1000),
                                color: userWon ? Colors.white : cs.onSurface,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        tooltip: L10n.tr('close', ref.read(localeProvider)),
                        onPressed: () => context.go('/run'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map overlay
                  _ResultMap(ghost: activeGhost, routePoints: routePoints),
                  const SizedBox(height: AppTheme.s24),

                  if (recalculated) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.s16),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.r16),
                        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.warning),
                          const SizedBox(width: AppTheme.s16),
                          Expanded(
                            child: Text(
                              L10n.tr('ghost_recalculated', locale),
                              style: text.bodyMedium!.copyWith(color: cs.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.s24),
                  ],

                  // Split comparison table
                  _SplitComparisonTable(
                    ghost: activeGhost,
                    splitComparisons: const [],
                    userElapsedMs: userElapsedMs,
                    locale: locale,
                  ),
                  const SizedBox(height: AppTheme.s24),

                  // Summary stats
                  _SummaryStats(
                    ghost: activeGhost,
                    userElapsedMs: userElapsedMs,
                    splitComparisons: const [],
                    locale: locale,
                  ),
                  const SizedBox(height: AppTheme.s24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Rematch with same tier
                            context.push('/beat/$ghostId');
                          },
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(L10n.tr('rematch', locale)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppTheme.s16)),
                        ),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Try harder tier
                            final nextTier = _nextTier(tier);
                            if (nextTier != null) {
                              context.push('/beat/$ghostId');
                            }
                          },
                          icon: const Icon(Icons.trending_up_rounded),
                          label: Text(L10n.tr('try_harder_tier', locale)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.brand,
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s12),
                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement share image generation
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: Text(L10n.tr('share_result', locale)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppTheme.s14)),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DifficultyTier? _nextTier(DifficultyTier current) {
    final values = DifficultyTier.values;
    final idx = values.indexOf(current);
    if (idx < values.length - 1) return values[idx + 1];
    return null;
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.r16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppTheme.s4),
          Text(label, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: color)),
          Text(value, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: color, fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

class _ResultMap extends StatelessWidget {
  final GhostPace ghost;
  final List<latlong.LatLng> routePoints;

  const _ResultMap({required this.ghost, required this.routePoints});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: SizedBox(
        height: 220,
        child: MwendoMap(
          points: routePoints,
          mode: MapMode.replay,
          zoom: 12,
          ghost: ghost,
          userDistanceM: ghost.distanceKm * 1000,
        ),
      ),
    );
  }
}

class _SplitComparisonTable extends StatelessWidget {
  final GhostPace ghost;
  final List<SplitComparison> splitComparisons;
  final int userElapsedMs;
  final AppLocale locale;

  const _SplitComparisonTable({
    required this.ghost,
    required this.splitComparisons,
    required this.userElapsedMs,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Text(L10n.tr('split_comparison', locale), style: text.titleMedium),
          ),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r16)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant))),
                Expanded(child: Text(L10n.tr('you', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
                Expanded(child: Text(L10n.tr('ghost', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
                Expanded(child: Text(L10n.tr('delta', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
                SizedBox(width: 40, child: Text(L10n.tr('status', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splitComparisons.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.1)),
            itemBuilder: (context, index) {
              final split = splitComparisons[index];
              final userSplitTime = split.userProjectedSplitTime;
              final isAhead = split.isAhead;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s10),
                color: isAhead ? AppTheme.recording.withValues(alpha: 0.05) : (split.deltaSeconds.abs() < 5 ? AppTheme.warning.withValues(alpha: 0.05) : AppTheme.idle.withValues(alpha: 0.05)),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('${index + 1}', style: text.bodyMedium, textAlign: TextAlign.center)),
                    Expanded(child: Text(formatSecondsAsMinSec(userSplitTime), style: text.bodyMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]), textAlign: TextAlign.center)),
                    Expanded(child: Text(formatSecondsAsMinSec(split.ghostSplitTime), style: text.bodyMedium!.copyWith(color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]), textAlign: TextAlign.center)),
                    Expanded(
                      child: Text(
                        '${split.isAhead ? "-" : "+"}${formatSeconds(split.deltaSeconds.abs())}',
                        style: text.bodyMedium!.copyWith(
                          color: isAhead ? AppTheme.recording : (split.deltaSeconds.abs() < 5 ? AppTheme.warning : AppTheme.idle),
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 40, child: Text(split.isAhead ? '🟢' : (split.deltaSeconds.abs() < 5 ? '🟡' : '🔴'), textAlign: TextAlign.center)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryStats extends StatelessWidget {
  final GhostPace ghost;
  final int userElapsedMs;
  final List<SplitComparison> splitComparisons;
  final AppLocale locale;

  const _SummaryStats({
    required this.ghost,
    required this.userElapsedMs,
    required this.splitComparisons,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(L10n.tr('race_summary', locale), style: text.titleMedium),
          const SizedBox(height: AppTheme.s12),
          Row(
            children: [
              Expanded(
child: _SummaryTile(
                  icon: Icons.timer_rounded,
                  label: L10n.tr('your_time', locale),
                  value: formatDuration(userElapsedMs),
                  color: AppTheme.brand,
                ),
              ),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.emoji_events_rounded,
                  label: L10n.tr('ghost_time', locale),
                  value: formatDuration(ghost.totalSeconds * 1000),
                  color: ghost.accent,
                ),
              ),
              Expanded(
                child: _SummaryTile(
                  icon: Icons.speed_rounded,
                  label: L10n.tr('avg_pace', locale),
                  value: userElapsedMs > 0 && ghost.distanceKm > 0 ? formatPace((userElapsedMs / 60000) / ghost.distanceKm) : '--:--',
                  color: AppTheme.recording,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppTheme.s8),
        Text(label, style: text.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppTheme.s4),
        Text(value, style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    );
  }
}