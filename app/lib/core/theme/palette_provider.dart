import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'shared_preferences_provider.dart';

class PaletteNotifier extends Notifier<ColorPalette> {
  static const _key = 'color_palette';

  @override
  ColorPalette build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_key);
    if (raw != null && ColorPalette.presetsByName.containsKey(raw)) {
      return ColorPalette.presetsByName[raw]!;
    }
    return const ColorPalette.orange();
  }

  Future<void> set(ColorPalette palette) async {
    state = palette;
    final prefs = ref.read(sharedPreferencesProvider);
    final key = ColorPalette.presetsByName.entries
        .firstWhere((e) => e.value == palette)
        .key;
    await prefs.setString(_key, key);
  }
}

final paletteProvider = NotifierProvider<PaletteNotifier, ColorPalette>(PaletteNotifier.new);