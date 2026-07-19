import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Canonical button component with consistent styling across the app.
class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
  });

  factory AppButton.primary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) => AppButton(
        key: key,
        child: child,
        onPressed: onPressed,
        style: AppButtonStyle.primary,
        padding: padding,
        width: width,
        height: height,
      );

  factory AppButton.secondary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) => AppButton(
        key: key,
        child: child,
        onPressed: onPressed,
        style: AppButtonStyle.secondary,
        padding: padding,
        width: width,
        height: height,
      );

  factory AppButton.ghost({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) => AppButton(
        key: key,
        child: child,
        onPressed: onPressed,
        style: AppButtonStyle.ghost,
        padding: padding,
        width: width,
        height: height,
      );

  factory AppButton.destructive({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
  }) => AppButton(
        key: key,
        child: child,
        onPressed: onPressed,
        style: AppButtonStyle.destructive,
        padding: padding,
        width: width,
        height: height,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.r12);

    Color backgroundColor;
    Color foregroundColor;
    List<BoxShadow>? shadows;

    switch (style) {
      case AppButtonStyle.primary:
        backgroundColor = AppTheme.brand;
        foregroundColor = Colors.white;
        shadows = AppTheme.elevation2;
        break;
      case AppButtonStyle.secondary:
        backgroundColor = cs.surface;
        foregroundColor = AppTheme.brand;
        shadows = AppTheme.elevation1;
        break;
      case AppButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppTheme.brand;
        shadows = null;
        break;
      case AppButtonStyle.destructive:
        backgroundColor = AppTheme.sos;
        foregroundColor = Colors.white;
        shadows = AppTheme.elevation2;
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: radius,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: shadows,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.s24, vertical: AppTheme.s16),
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppButtonStyle { primary, secondary, ghost, destructive }