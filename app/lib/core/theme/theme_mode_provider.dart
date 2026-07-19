import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_preferences_provider.dart';

/// Persisted app appearance (dark by default, matching the brand).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode_v1';

  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_key);
    if (raw != null) {
      return ThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => ThemeMode.dark,
      );
    }
    return ThemeMode.dark;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, mode.name);
  }

  Future<void> cycle() async {
    const order = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    final next = order[(order.indexOf(state) + 1) % order.length];
    await set(next);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);