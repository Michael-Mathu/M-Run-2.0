import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

class AppStreakRing extends StatelessWidget {
  final int streakDays;
  final double progress;
  final double size;

  const AppStreakRing({
    super.key,
    required this.streakDays,
    required this.progress,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(AppTheme.tierGold),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$streakDays', style: text.titleMedium!.copyWith(fontWeight: FontWeight.w800)),
              Text('day streak', style: text.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
