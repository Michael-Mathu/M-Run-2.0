import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppPermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  const AppPermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.r16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppTheme.r12),
            ),
            child: Icon(icon, color: AppTheme.brand, size: 24),
          ),
          const SizedBox(width: AppTheme.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                Text(description, style: text.bodySmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.brand),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
