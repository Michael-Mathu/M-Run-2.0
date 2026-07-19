import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppCoachBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const AppCoachBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppTheme.brand;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: bg),
          const SizedBox(width: AppTheme.s4),
          Text(label, style: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
