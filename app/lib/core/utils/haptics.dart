import 'package:flutter/services.dart';

class Haptics {
  const Haptics._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();

  /// Celebratory burst for level-ups / big unlocks: a quick success tick
  /// followed by a heavy impact.
  static void celebrate() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 90), HapticFeedback.heavyImpact);
  }
}
