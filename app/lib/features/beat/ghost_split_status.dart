import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';

/// Compact widget showing current split delta vs ghost.
class GhostSplitStatus extends ConsumerWidget {
  const GhostSplitStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ghostRaceControllerProvider);
    final locale = ref.watch(localeProvider);

    return switch (state) {
      GhostRaceRacingData racing => _SplitStatusContent(
          currentSplit: _getCurrentSplit(racing),
          deltaSeconds: racing.deltaSeconds,
          projectedFinish: racing.projectedFinishSeconds,
          locale: locale,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  SplitComparison? _getCurrentSplit(GhostRaceRacingData racing) {
    try {
      return racing.splitComparisons.firstWhere((s) => s.progressInSplit > 0 && s.progressInSplit < 1);
    } catch (_) {
      return null;
    }
  }
}

class _SplitStatusContent extends StatelessWidget {
  final SplitComparison? currentSplit;
  final double deltaSeconds;
  final double projectedFinish;
  final AppLocale locale;

  const _SplitStatusContent({
    required this.currentSplit,
    required this.deltaSeconds,
    required this.projectedFinish,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAhead = deltaSeconds < 0;
    final color = isAhead ? AppTheme.recording : AppTheme.idle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAhead ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppTheme.s6),
          Text(
            currentSplit != null
                ? '${L10n.tr('split_label', locale)} ${currentSplit!.splitNumber}: ${currentSplit!.deltaFormatted}'
                : '${L10n.tr('overall', locale)}: ${deltaSeconds < 0 ? '-' : '+'}${formatSeconds(deltaSeconds.abs())}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppTheme.s8),
          Container(
            width: 1,
            height: 16,
            color: cs.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppTheme.s8),
          Text(
            '${L10n.tr('proj', locale)} ${formatSeconds(projectedFinish)}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.8),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

/// Detailed drawer showing split-by-split comparison.
class GhostDrawer extends ConsumerWidget {
  const GhostDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ghostRaceControllerProvider);
    final locale = ref.watch(localeProvider);
    final cs = Theme.of(context).colorScheme;

    return switch (state) {
      GhostRaceRacingData racing => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.s12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: racing.ghost.accent.withValues(alpha: 0.2),
                        child: Text(racing.ghost.legend.emoji, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(racing.ghost.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                            Text(
                              '${racing.ghost.distanceLabel} · ${racing.tier.badge} ${racing.tier.label}',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Overall delta badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
                        decoration: BoxDecoration(
                          color: (racing.deltaSeconds < 0 ? AppTheme.recording : AppTheme.idle).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.rFull),
                          border: Border.all(color: racing.deltaSeconds < 0 ? AppTheme.recording : AppTheme.idle),
                        ),
                        child: Text(
                          '${racing.deltaSeconds < 0 ? '-' : '+'}${formatSeconds(racing.deltaSeconds.abs())}',
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                color: racing.deltaSeconds < 0 ? AppTheme.recording : AppTheme.idle,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Split list
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
                    itemCount: racing.splitComparisons.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppTheme.s8),
                    itemBuilder: (context, index) {
                      final split = racing.splitComparisons[index];
                      return _SplitTile(split: split, isCurrent: split.progressInSplit > 0 && split.progressInSplit < 1, locale: locale);
                    },
                  ),
                ),
                // Projected finish
                Padding(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  child: Row(
                    children: [
                      Icon(Icons.flag_rounded, color: cs.onSurfaceVariant, size: 20),
                      const SizedBox(width: AppTheme.s12),
                      Text(
                        '${L10n.tr('projected_finish', locale)}: ${formatSeconds(racing.projectedFinishSeconds)}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${L10n.tr('ghost_finish', locale)}: ${formatSeconds(racing.ghost.totalSeconds.toDouble())}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SplitTile extends StatelessWidget {
  final SplitComparison split;
  final bool isCurrent;
  final AppLocale locale;

  const _SplitTile({required this.split, required this.isCurrent, required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = split.isAhead ? AppTheme.recording : (split.deltaSeconds.abs() < 5 ? AppTheme.warning : AppTheme.idle);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s12),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.1) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.r12),
        border: isCurrent ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          // Split number + status icon
          SizedBox(
            width: 48,
            child: Row(
              children: [
                Text(
                  '${split.splitNumber}',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
                const SizedBox(width: AppTheme.s8),
                Text(split.statusIcon, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // Progress bar for current split
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: split.progressInSplit,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(width: AppTheme.s8),
                    Text(
                      '${(split.progressInSplit * 100).round()}%',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.s4),
                Row(
                  children: [
                    Text(
                      '${L10n.tr('target', locale)}: ${formatSeconds(split.ghostSplitTime)}',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: cs.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    const SizedBox(width: AppTheme.s12),
                    Text(
                      '${L10n.tr('proj', locale)}: ${formatSeconds(split.userProjectedSplitTime)}',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: split.isAhead ? AppTheme.recording : AppTheme.idle,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delta
          Text(
            split.deltaFormatted,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}