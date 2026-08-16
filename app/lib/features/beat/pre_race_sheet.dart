import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/router/app_router.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

/// Bottom sheet shown before starting a ghost race.
class PreRaceBottomSheet extends ConsumerWidget {
  final GhostPace ghost;
  final DifficultyTier tier;

  const PreRaceBottomSheet({super.key, required this.ghost, required this.tier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGhost = ghost.forTier(tier);
    final locale = ref.watch(localeProvider);
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
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
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppTheme.s24),
                children: [
                  // Ghost header
                  Container(
                    padding: const EdgeInsets.all(AppTheme.s20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [activeGhost.accent.withValues(alpha: 0.9), activeGhost.accent.withValues(alpha: 0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.r24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(activeGhost.legend.emoji, style: const TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(width: AppTheme.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activeGhost.name, style: text.titleLarge!.copyWith(color: Colors.white)),
                              const SizedBox(height: AppTheme.s4),
                              Text(
                                '${activeGhost.distanceLabel} · ${L10n.tr('target', locale)} ${formatDuration(activeGhost.totalSeconds)}',
                                style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                              ),
                              const SizedBox(height: AppTheme.s2),
                              Text(
                                '${L10n.tr('avg', locale)} ${formatPace(activeGhost.avgPaceMinPerKm)} /km',
                                style: text.labelMedium!.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                              ),
                            ],
                          ),
                        ),
                        // Tier badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s6),
                          decoration: BoxDecoration(
                            color: tier.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.rFull),
                            border: Border.all(color: tier.color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tier.badge, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: AppTheme.s6),
                              Text(tier.label, style: text.labelLarge!.copyWith(color: tier.color, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.s20),

                  // Split table preview
                  Text(L10n.tr('pace_per_segment', locale), style: text.titleMedium),
                  Text(L10n.tr('seconds_per_km', locale), style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
                  const SizedBox(height: AppTheme.s12),
                  _SplitTable(ghost: activeGhost, locale: locale),
                  const SizedBox(height: AppTheme.s20),

                  // Description
                  Text(activeGhost.description, style: text.bodyLarge!.copyWith(height: 1.6)),
                  const SizedBox(height: AppTheme.s24),

// Start button
                   SizedBox(
                     width: double.infinity,
                     child: FilledButton.icon(
                       onPressed: () {
                         Navigator.of(context).pop();
                         ref.read(ghostRaceControllerProvider.notifier).arm(ghost, tier);
                         // Navigate to run tab - ghost race starts when recording begins
                         final router = ref.read(appRouterProvider);
                         router.go('/run');
                       },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(L10n.tr('race_this_ghost', locale)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.brand,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s12),

                  // Change tier button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.swap_vert_rounded),
                      label: Text(L10n.tr('change_tier', locale)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppTheme.s14)),
                    ),
                  ),
                  const SizedBox(height: AppTheme.s12),

                  Text(
                    '${L10n.tr('during_a_run', locale)}${formatSeconds(activeGhost.totalSeconds.toDouble())}.',
                    style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.s32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitTable extends StatelessWidget {
  final GhostPace ghost;
  final AppLocale locale;
  const _SplitTable({required this.ghost, required this.locale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final splits = ghost.splits;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r16)),
            ),
            child: Row(
              children: [
                SizedBox(width: 48, child: Text('#', style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant))),
                Expanded(child: Text(L10n.tr('target_split', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
                Expanded(child: Text(L10n.tr('pace_per_km', locale), style: text.labelMedium!.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splits.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.1)),
            itemBuilder: (_, i) {
              final splitSec = splits[i];
              final paceMinPerKm = splitSec / 60 / (ghost.distanceKm / splits.length);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: AppTheme.s10),
                child: Row(
                  children: [
                    SizedBox(width: 48, child: Text('${i + 1}', style: text.bodyMedium, textAlign: TextAlign.center)),
                    Expanded(child: Text(formatSecondsAsMinSec(splitSec), style: text.bodyMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]), textAlign: TextAlign.center)),
                    Expanded(child: Text(formatPace(paceMinPerKm), style: text.bodyMedium!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]), textAlign: TextAlign.center)),
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

/// Helper to show the pre-race sheet.
Future<void> showPreRaceSheet(BuildContext context, WidgetRef ref, GhostPace ghost, DifficultyTier tier) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PreRaceBottomSheet(ghost: ghost, tier: tier),
  );
}