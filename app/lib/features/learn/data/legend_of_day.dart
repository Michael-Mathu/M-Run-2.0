import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/learn/data/legends.dart';

/// Deterministic "Legend of the Day" — same legend for everyone on a given day,
/// rotating through the list by day-of-year.
final legendOfDayProvider = Provider<Legend>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, 1, 1);
  final dayOfYear = now.difference(start).inDays;
  return legends[dayOfYear % legends.length];
});

/// "Legend of the Week" — rotates weekly.
final legendOfWeekProvider = Provider<Legend>((ref) {
  final now = DateTime.now();
  final weekOfYear = (now.difference(DateTime(now.year, 1, 1)).inDays / 7).floor();
  return legends[weekOfYear % legends.length];
});

class LegendOfDayCard extends ConsumerWidget {
  final bool weekly;
  const LegendOfDayCard({super.key, this.weekly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legend = weekly ? ref.watch(legendOfWeekProvider) : ref.watch(legendOfDayProvider);
    final accent = legendAccent(legend);
    final text = Theme.of(context).textTheme;
    final locale = ref.read(localeProvider);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.95), accent.withValues(alpha: 0.6)],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.rFull),
                ),
                child: Text(weekly ? L10n.tr('legend_of_week', locale) : L10n.tr('did_you_know', locale),
                    style: text.labelSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(legend.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: AppTheme.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(legend.name,
                        style: text.titleLarge!.copyWith(color: Colors.white)),
                    const SizedBox(height: AppTheme.s2),
                    Text(legend.flag,
                        style: text.bodySmall!.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          Text(
            lt(legend.funFact ?? legend.tagline, locale),
            style: text.bodyMedium!.copyWith(color: Colors.white.withValues(alpha: 0.95), height: 1.5),
          ),
          const SizedBox(height: AppTheme.s12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.go('/learn/legends/${legend.slug}'),
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              label: Text(L10n.tr('read_more', locale), style: const TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}