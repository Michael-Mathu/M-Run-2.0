import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

/// Swipe-up drawer showing live split-by-split comparison during a ghost race.
class GhostDrawer extends ConsumerWidget {
  const GhostDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ghostRaceControllerProvider);
    final locale = ref.watch(localeProvider);

    return state.maybeWhen(
      idle: () => const SizedBox.shrink(),
      armed: (ghost, tier) => const SizedBox.shrink(),
      racing: (racing) => DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.2,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              _DrawerHeader(ghost: racing.ghost, tier: racing.tier, deltaSeconds: racing.deltaSeconds, locale: locale),
              // Split list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
                  itemCount: racing.splitComparisons.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppTheme.s8),
                  itemBuilder: (context, index) {
                    final split = racing.splitComparisons[index];
                    final isCurrent = split.progressInSplit > 0 && split.progressInSplit < 1 && index == racing.currentSplitIndex;
                    return _SplitTile(split: split, isCurrent: isCurrent, locale: locale);
                  },
                ),
              ),
              // Projected finish footer
              _ProjectedFooter(ghost: racing.ghost, projectedFinishSeconds: racing.projectedFinishSeconds, locale: locale),
            ],
          ),
        ),
      ),
      finished: (finished) => const SizedBox.shrink(),
    ) ?? const SizedBox.shrink();
  }
}

class _DrawerHeader extends StatelessWidget {
  final GhostPace ghost;
  final DifficultyTier tier;
  final double deltaSeconds;
  final AppLocale locale;

  const _DrawerHeader({required this.ghost, required this.tier, required this.deltaSeconds, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isAhead = deltaSeconds < 0;
    final color = isAhead ? AppTheme.recording : AppTheme.idle;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.s16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ghost.accent.withValues(alpha: 0.2),
            child: Text(ghost.legend.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ghost.name, style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${ghost.distanceLabel} · ${tier.badge} ${tier.label}',
                  style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Overall delta badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.rFull),
              border: Border.all(color: color),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAhead ? L10n.tr('ahead', locale) : L10n.tr('behind', locale),
                  style: text.labelSmall!.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${isAhead ? '-' : '+'}${formatSeconds(deltaSeconds.abs())}',
                  style: text.titleMedium!.copyWith(color: color, fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitTile extends StatelessWidget {
  final SplitComparison split;
  final bool isCurrent;
  final AppLocale locale;

  const _SplitTile({required this.split, required this.isCurrent, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
            width: 56,
            child: Row(
              children: [
                Text(
                  '${split.splitNumber}',
                  style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                const SizedBox(width: AppTheme.s8),
                Text(_statusIcon(split), style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // Progress bar + targets
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
                      style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.s4),
Row(
                      children: [
                        Text(
                          '${L10n.tr('target', locale)}: ${formatSecondsAsMinSec(split.ghostSplitTime)}',
                          style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                        const SizedBox(width: AppTheme.s12),
                        Text(
                          '${L10n.tr('proj', locale)}: ${formatSeconds(split.userProjectedSplitTime)}',
                          style: text.labelSmall!.copyWith(
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
            _formatDelta(split.deltaSeconds),
            style: text.labelMedium!.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _statusIcon(SplitComparison s) {
    if (s.progressInSplit >= 1) return s.isAhead ? '✅' : '❌';
    if (s.progressInSplit > 0) return s.isAhead ? '🟢' : '🔴';
    return '⏳';
  }

  String _formatDelta(double delta) {
    final sign = delta < 0 ? '-' : '+';
    return '$sign${formatSeconds(delta.abs())}';
  }
}

class _ProjectedFooter extends StatelessWidget {
  final GhostPace ghost;
  final double projectedFinishSeconds;
  final AppLocale locale;

  const _ProjectedFooter({required this.ghost, required this.projectedFinishSeconds, required this.locale});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r16)),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, color: cs.onSurfaceVariant, size: 20),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  L10n.tr('projected_finish', locale),
                  style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  formatSeconds(projectedFinishSeconds),
                  style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(L10n.tr('ghost_finish', locale), style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant)),
              Text(
                formatSeconds(ghost.totalSeconds.toDouble()),
                style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}