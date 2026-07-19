import 'package:flutter/material.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppContinueBanner extends StatelessWidget {
  final IconData icon;
  final String courseName;
  final String? lessonName;
  final VoidCallback? onTap;
  final AppLocale locale;

  const AppContinueBanner({
    super.key,
    required this.icon,
    required this.courseName,
    this.lessonName,
    this.onTap,
    required this.locale,
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
                    Text(L10n.tr('continue_learning', locale), style: text.labelSmall!.copyWith(color: cs.onSurface.withValues(alpha: 0.65))),
                    Text(courseName, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (lessonName != null)
                      Text(lessonName!, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
