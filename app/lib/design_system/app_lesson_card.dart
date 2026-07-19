import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppLessonCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final String? keyTakeaway;
  final double progress;
  final VoidCallback? onTap;

  const AppLessonCard({
    super.key,
    required this.title,
    required this.difficulty,
    this.keyTakeaway,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.s8, vertical: AppTheme.s2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.rFull),
                    ),
                    child: Text(difficulty, style: text.labelSmall!.copyWith(color: cs.primary)),
                  ),
                ],
              ),
              if (keyTakeaway != null) ...[
                const SizedBox(height: AppTheme.s4),
                Text(keyTakeaway!, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: AppTheme.s8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.rFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
