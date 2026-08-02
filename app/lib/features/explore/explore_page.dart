import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/explore/explore_provider.dart';
import 'package:mwendo_app/design_system/app_segmented_control.dart';
import 'package:mwendo_app/widgets/app_card.dart';
import 'package:mwendo_app/design_system/app_empty_state.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final data = ref.watch(exploreProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(exploreProvider);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppTheme.s16, AppTheme.s16, AppTheme.s16, 0),
                sliver: SliverToBoxAdapter(
                  child: AppSegmentedControl(
                    selectedIndex: data.segmentIndex,
                    onChanged: (i) => ref.read(exploreProvider.notifier).setSegmentByIndex(i),
                    labels: [
                      L10n.tr('explore_routes', locale),
                      L10n.tr('explore_segments', locale),
                      L10n.tr('explore_leaderboards', locale),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16),
                sliver: _buildContent(data, locale),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ExploreData data, AppLocale locale) {
    switch (data.segmentIndex) {
      case 0: // Routes
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final r = data.routes[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s12),
                child: AppCard(
                  onTap: () => context.go('/explore/${r.slug}'),
                  useInkWell: true,
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppTheme.r12),
                        ),
                        child: Icon(
                          Icons.map_rounded,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppTheme.s4),
                            Text(
                              r.description,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.s4),
                            Row(
                              children: [
                                Icon(Icons.straighten_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                const SizedBox(width: AppTheme.s4),
                                Text(
                                  '${(r.distance / 1000).toStringAsFixed(1)} km',
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.s12),
                                Icon(Icons.terrain_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                const SizedBox(width: AppTheme.s4),
                                Text(
                                  '${r.elevationGain}m ↑',
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              );
            },
            childCount: data.routes.length,
          ),
        );
      case 1: // Segments
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final s = data.segments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s12),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppTheme.r12),
                        ),
                        child: Icon(
                          Icons.segment_rounded,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppTheme.s4),
                            Text(
                              s.description,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.s4),
                            Row(
                              children: [
                                Icon(Icons.straighten_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                const SizedBox(width: AppTheme.s4),
                                Text(
                                  '${(s.distance / 1000).toStringAsFixed(1)} km',
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.s12),
                                Icon(Icons.terrain_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                const SizedBox(width: AppTheme.s4),
                                Text(
                                  '${s.elevationGain}m ↑',
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: data.segments.length,
          ),
        );
      case 2: // Leaderboards
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final row = data.leaderboards[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.s8),
                child: AppCard(
                  padding: const EdgeInsets.all(AppTheme.s12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: row.badge != null
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${row.rank}',
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: row.badge != null
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(row.name, style: Theme.of(context).textTheme.titleMedium),
                            if (row.badge != null)
                              Text(
                                L10n.tr('leaderboard_badge_${row.badge}', locale),
                                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(row.value, style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      )),
                    ],
                  ),
                ),
              );
            },
            childCount: data.leaderboards.length,
          ),
        );
      default:
        return SliverFillRemaining(
          child: AppEmptyState(
            icon: Icons.explore_outlined,
            message: L10n.tr('explore_empty_body', locale),
          ),
        );
    }
  }
}