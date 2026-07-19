import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppLeaderboardRow extends StatelessWidget {
  final String name;
  final String value;
  final int rank;
  final bool isYou;

  const AppLeaderboardRow({
    super.key,
    required this.name,
    required this.value,
    required this.rank,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
      decoration: BoxDecoration(
        color: isYou ? AppTheme.brand.withValues(alpha: 0.14) : cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isYou ? AppTheme.brand.withValues(alpha: 0.2) : cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$rank', style: text.labelSmall!.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(child: Text(name, style: text.titleMedium)),
          Text(value, style: text.labelMedium!.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
