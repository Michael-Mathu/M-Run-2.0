import 'package:flutter/material.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppCourseTile extends StatelessWidget {
  final String title;
  final int lessonCount;
  final double progress;
  final Color accent;
  final VoidCallback? onTap;
  final AppLocale locale;

  const AppCourseTile({
    super.key,
    required this.title,
    required this.lessonCount,
    required this.progress,
    required this.accent,
    this.onTap,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppTheme.s4),
              Text('$lessonCount ${L10n.tr('lessons', locale)}', style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.rFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
