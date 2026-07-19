import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Skeleton block used while content loads.
class Skeleton extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const Skeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = AppTheme.r12,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: base.withValues(alpha: 0.4),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 92});

  @override
  Widget build(BuildContext context) => Skeleton(height: height, radius: AppTheme.r16);
}
