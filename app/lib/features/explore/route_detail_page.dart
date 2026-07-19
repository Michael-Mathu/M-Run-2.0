import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart' hide RouteData;
import 'package:latlong2/latlong.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/explore/explore_provider.dart';
import 'package:mwendo_app/widgets/route_map.dart' as map;

class RouteDetailPage extends ConsumerWidget {
  final String slug;

  const RouteDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final data = ref.watch(exploreProvider);
    final route = data.routes.where((r) => r.slug == slug).firstOrNull;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(title: Text(L10n.tr('explore_routes', locale))),
        body: Center(child: Text(L10n.tr('explore_no_routes', locale))),
      );
    }

    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: map.RouteMap(points: _sampleRoutePoints(route), zoom: 13),
          ),
          const SizedBox(height: AppTheme.s16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route.name, style: text.headlineSmall),
                const SizedBox(height: AppTheme.s8),
                Text(route.description, style: text.bodyMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: AppTheme.s16),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.straighten_rounded,
                      label: '${(route.distance / 1000).toStringAsFixed(1)} km',
                    ),
                    const SizedBox(width: AppTheme.s12),
                    _InfoChip(
                      icon: Icons.terrain_rounded,
                      label: '${route.elevationGain}m ↑',
                    ),
                    const SizedBox(width: AppTheme.s12),
                    _InfoChip(
                      icon: Icons.timer_rounded,
                      label: '${route.estimatedTime} min',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppTheme.s24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(L10n.tr('start_run', locale)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LatLng> _sampleRoutePoints(RouteData route) {
    if (route.slug == 'marathon-kenya-standard') {
      return const [
        LatLng(-1.2921, 36.8219),
        LatLng(-1.2850, 36.8300),
        LatLng(-1.2780, 36.8400),
        LatLng(-1.2700, 36.8500),
      ];
    }
    if (route.slug == 'half-marathon-nairobi') {
      return const [
        LatLng(-1.2921, 36.8219),
        LatLng(-1.2800, 36.8400),
        LatLng(-1.2700, 36.8500),
      ];
    }
    if (route.slug == '10k-eldoret') {
      return const [
        LatLng(-1.2921, 36.8219),
        LatLng(-1.2850, 36.8350),
        LatLng(-1.2780, 36.8450),
      ];
    }
    return const [LatLng(-1.2921, 36.8219)];
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: AppTheme.s4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}