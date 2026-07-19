import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';

/// Canonical avatar component with consistent sizing across the app.
class AppAvatar extends StatelessWidget {
  final String? imagePath;
  final String? initials;
  final IconData? icon;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const AppAvatar({
    super.key,
    this.imagePath,
    this.initials,
    this.icon,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.border,
  });

  factory AppAvatar.xs({
    String? imagePath,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    VoidCallback? onTap,
    BoxBorder? border,
  }) =>
      AppAvatar(
        imagePath: imagePath,
        initials: initials,
        icon: icon,
        size: AppTheme.avatarXs,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
        border: border,
      );

  factory AppAvatar.sm({
    String? imagePath,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    VoidCallback? onTap,
    BoxBorder? border,
  }) =>
      AppAvatar(
        imagePath: imagePath,
        initials: initials,
        icon: icon,
        size: AppTheme.avatarSm,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
        border: border,
      );

  factory AppAvatar.md({
    String? imagePath,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    VoidCallback? onTap,
    BoxBorder? border,
  }) =>
      AppAvatar(
        imagePath: imagePath,
        initials: initials,
        icon: icon,
        size: AppTheme.avatarMd,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
        border: border,
      );

  factory AppAvatar.lg({
    String? imagePath,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    VoidCallback? onTap,
    BoxBorder? border,
  }) =>
      AppAvatar(
        imagePath: imagePath,
        initials: initials,
        icon: icon,
        size: AppTheme.avatarLg,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
        border: border,
      );

  factory AppAvatar.xl({
    String? imagePath,
    String? initials,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    VoidCallback? onTap,
    BoxBorder? border,
  }) =>
      AppAvatar(
        imagePath: imagePath,
        initials: initials,
        icon: icon,
        size: AppTheme.avatarXl,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        onTap: onTap,
        border: border,
      );

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.brand;
    final fgColor = foregroundColor ?? Colors.white;

    Widget avatar;
    if (imagePath != null) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        backgroundImage: FileImage(File(imagePath!)),
      );
    } else if (initials != null) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Text(
          initials!,
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Icon(icon ?? Icons.person_rounded, color: fgColor, size: size * 0.5),
      );
    }

    if (border != null) {
      avatar = Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: border),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}