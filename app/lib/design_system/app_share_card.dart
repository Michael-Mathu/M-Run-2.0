import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppShareCard extends StatelessWidget {
  final String metricValue;
  final String metricLabel;
  final String? subtitle;

  const AppShareCard({
    super.key,
    required this.metricValue,
    required this.metricLabel,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.r24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metricValue, style: text.displayMedium!.copyWith(color: Colors.white)),
          Text(metricLabel.toUpperCase(), style: text.labelSmall!.copyWith(color: Colors.white70)),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.s8),
            Text(subtitle!, style: text.bodySmall!.copyWith(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}
