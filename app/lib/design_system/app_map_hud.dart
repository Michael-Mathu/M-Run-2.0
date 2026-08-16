import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

class AppMapHud extends ConsumerWidget {
  final double distanceKm;
  final double paceMinPerKm;
  final int elapsedMs;
  final int? heartRate;
  final AppEngineState state;

  const AppMapHud({
    super.key,
    required this.distanceKm,
    required this.paceMinPerKm,
    required this.elapsedMs,
    this.heartRate,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isIdle = state == AppEngineState.idle;
    if (isIdle) return const SizedBox.shrink();
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppTheme.s16,
      left: AppTheme.s16,
      right: AppTheme.s16,
      child: Row(
        children: [
          Expanded(
            child: _HudPill(
              value: distanceKm.toStringAsFixed(2),
              unit: L10n.tr('km', locale),
              color: AppTheme.brand,
            ),
          ),
          const SizedBox(width: AppTheme.s8),
          Expanded(
            child: _HudPill(
              value: formatPace(paceMinPerKm),
              unit: L10n.tr('per_km', locale),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppTheme.s8),
          Expanded(
            child: _HudPill(
              value: formatDuration(elapsedMs),
              unit: L10n.tr('time_label', locale),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (heartRate != null) ...[
            const SizedBox(width: AppTheme.s8),
            _HudPill(
              value: '$heartRate',
              unit: 'bpm',
              color: AppTheme.recording,
            ),
          ],
        ],
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;

  const _HudPill({required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Column(
        children: [
          Text(value, style: text.labelLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          Text(unit, style: text.labelSmall!.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
