import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppLegendCard extends StatelessWidget {
  final String name;
  final String emoji;
  final Color accent;
  final String? bio;
  final VoidCallback? onTap;

  const AppLegendCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.accent,
    this.bio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.r16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.r16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: AppTheme.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleMedium),
                    if (bio != null)
                      Text(
                        bio!,
                        style: text.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: text.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
