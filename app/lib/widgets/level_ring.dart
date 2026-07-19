import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Circular level indicator with the level number in the middle and a brand
/// gradient progress arc.
class LevelRing extends ConsumerWidget {
  final int level;
  final double progress; // 0..1
  final double size;
  final Color color;

  const LevelRing({
    super.key,
    required this.level,
    required this.progress,
    this.size = 64,
    this.color = AppTheme.brand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final grad = tokens.brandGradient;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) => SweepGradient(
              colors: [grad.colors.first, tokens.flagGreen, grad.colors.last],
              startAngle: -math.pi / 2,
              endAngle: 3 * math.pi / 2,
            ).createShader(rect),
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 5,
              backgroundColor: cs.onSurface.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ref.tr('lv'),
                  style: text.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant, letterSpacing: 1)),
              Text(level.toString(),
                  style: text.titleLarge!.copyWith(
                      color: cs.onSurface, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal XP bar toward the next level.
class XpBar extends StatelessWidget {
  final int xpIntoLevel;
  final int xpForNextLevel;
  final double progress;
  final Color color;

  const XpBar({
    super.key,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.progress,
    this.color = AppTheme.brand,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.rFull),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: cs.onSurface.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: AppTheme.s6),
        Text(
          '$xpIntoLevel / $xpForNextLevel XP',
          style: text.labelSmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
