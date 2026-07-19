import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// One metric style across the whole app (dashboard, profile, activity
/// detail, live dashboard). Replaces the 4 divergent stat-tile treatments
/// so a "distance" reads identically everywhere.
enum MetricVariant { hero, card, inline }

class MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final MetricVariant variant;
  final Color? valueColor;
  final Color? labelColor;
  final TextAlign align;

  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    this.variant = MetricVariant.card,
    this.valueColor,
    this.labelColor,
    this.align = TextAlign.start,
  });

  TextStyle _valueStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = context.tokens.metricValue;
    switch (variant) {
      case MetricVariant.hero:
        return base.copyWith(
            fontSize: 32, color: valueColor ?? Colors.white);
      case MetricVariant.card:
        return base.copyWith(
            color: valueColor ?? cs.onSurface);
      case MetricVariant.inline:
        return Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? cs.onSurface,
            );
    }
  }

  TextStyle _labelStyle(BuildContext context) {
    final base = context.tokens.metricLabel;
    final color = labelColor ??
        (variant == MetricVariant.hero ? Colors.white70 : AppTheme.idle);
    return base.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(value, style: _valueStyle(context), textAlign: align),
        const SizedBox(height: AppTheme.s2),
        Text(label.toUpperCase(), style: _labelStyle(context), textAlign: align),
      ],
    );
  }
}
