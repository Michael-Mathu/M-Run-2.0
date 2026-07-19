import 'package:flutter/material.dart';

/// Theme-aware trailing affordance. Replaces the ~7 hardcoded
/// `Icons.chevron_right_rounded, color: Colors.white38` occurrences that
/// break in light mode.
class TrailingChevron extends StatelessWidget {
  final double size;
  const TrailingChevron({this.size = 20, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Icon(
      Icons.chevron_right_rounded,
      size: size,
      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
    );
  }
}
