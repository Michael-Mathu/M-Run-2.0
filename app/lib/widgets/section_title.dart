import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Section header used across the app for visual consistency.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {this.actionLabel, this.onAction, super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.s8, bottom: AppTheme.s12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: text.titleLarge)),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: text.labelMedium!.copyWith(color: cs.primary),
              ),
            ),
        ],
      ),
    );
}
}
