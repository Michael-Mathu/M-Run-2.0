# mwendo_app

A running app with ghost racing against legendary performances.

## Features

### Ghost Racing (Pillar 4)
Race against legendary runners across distances from 800m to Marathon.

- **12 Ghosts**: Kipchoge, Kiptum, Tergat, Kipyegon, Chebet, Rudisha, Bekele, Cheptegei, Kosgei, Chepngetich, Gebrselassie, Keino
- **4 Difficulty Tiers**: Bronze (125%) → Silver (110%) → Gold (102%) → G.O.A.T. (100% WR)
- **Live Map Visualization**: Ghost route (dashed polyline) + pulsing ghost marker at interpolated position
- **Per-Split Comparison**: Swipe-up drawer shows each split with progress bar, target vs projected time, delta (±mm:ss), status icon
- **Pre-Race Sheet**: Tier selector, split table preview, PB context, tier recommendation based on your PB
- **Post-Race Results**: Full-screen hero with win/loss, overlaid map, split comparison table, summary stats, rematch / try harder / share CTAs

### Core Tracking
- GPS tracking with offline-first local storage (activities.json)
- Live metrics: distance, pace, time, elevation, calories, heart rate, cadence
- Crash recovery via temp JSON snapshot
- Background location support

### Localization
- **Bilingual UI**: English + Swahili (`sw`) with in-app language switcher
- **Localized content**: Legends and course prose use `LocalizedText` en/sw pairs rendered via `lt()` resolver
- **UI catalog**: ~180+ keys in `app/lib/core/l10n/app_strings.dart` with `L10n.tr()` helper

### Architecture
- Riverpod state management (NotifierProvider pattern)
- GoRouter with StatefulShellRoute for bottom nav
- MapLibre GL with Carto dark basemap (no API key)
- Drift/SQLite ready (tables defined, currently using JSON file store)

## Design System

See [DESIGN_SYSTEM.md](../docs/DESIGN_SYSTEM.md) for canonical design tokens and components.

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.19+ and Dart 3.3+.
