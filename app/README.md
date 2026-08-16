# Mwendo Client Application (`app`)

Mwendo is a high-precision, offline-first GPS running application featuring East African heritage-driven virtual pacing ("Beat the Legends"), mathematical state-space telemetry filtering, and zero-loss crash recovery.

---

## 🏃 Key Features

### 1. Ghost Racing & Virtual Pacing (Pillar 4)
Race in real-time against mathematical models of iconic world-record performances across distances from 800m to Marathon, or race against your own local offline activities:

- **12 Legend Ghosts**: Eliud Kipchoge, Kelvin Kiptum, Paul Tergat, Faith Kipyegon, Beatrice Chebet, David Rudisha, Kenenisa Bekele, Joshua Cheptegei, Brigid Kosgei, Ruth Chepngetich, Haile Gebrselassie, Kipchoge Keino.
- **Offline Ghost Race**: Convert any previous local `RunRecord` into an offline ghost pace via `toGhostPace()` and race your past personal bests with zero network connectivity.
- **4 Difficulty Tiers**: Bronze (125% of WR) → Silver (110%) → Gold (102%) → G.O.A.T. (100% WR).
- **Live Map Visualization**: Ghost route (dashed polyline) + animated pulsing ghost marker at interpolated position along runner route.
- **Per-Split Comparison**: Swipe-up HUD drawer displaying split progress bar, target vs projected time, live delta ($\pm\text{mm:ss}$), and status icon.
- **Pre-Race Sheet**: Tier selector, split table preview, PB context, and personalized tier recommendation based on personal bests.
- **Post-Race Results & Reconciliation**: Full-screen hero with win/loss detection, route overlay, split comparison table, summary metrics, and rematch CTAs.

### 2. Core GPS Tracking & Multi-Stage Telemetry
- **Single Source of Truth**: All distance, pace, and split calculations are driven by the deterministic `gps_pipeline` (Kalman state-space filtered and stationary-suppressed points).
- **Live Signal Quality HUD**: Dynamic `StatusPill` displaying real-time GPS horizontal accuracy in metres, color-coded readiness warnings, and satellite telemetry.
- **Interactive Auto-Follow Affordance**: One-tap map auto-follow toggle (`_AutoFollowToggleButton`) allowing runners to easily lock/unlock map tracking or inspect route progress freely.
- **Auto-Pause Semantics Overlay**: Visual feedback card explaining stationary suppression thresholds and manual override options.
- **Post-Run OSRM Map Matching**: Asynchronous road snapping against OpenStreetMap pedestrian networks with automatic distance reconciliation.
- **Route Analysis Screen**: Deep diagnostic breakdown comparing raw vs filtered vs map-matched distance, GPS accuracy distribution, and rejection counts.

### 3. Resilience & Offline-First Storage
- **Drift SQLite Relational Database**: Fast on-device persistence via `AppDatabase` across `activities`, `activity_points`, `session_drafts`, and `session_points`.
- **Durable Session Drafts**: Real-time atomic journaling that enables instant recovery if the OS terminates the app during an active workout.
- **GPX Export**: Industry-standard GPX 1.1 workout track exports.

### 4. Bilingual Localization
- **English + Swahili (`sw`)**: In-app language switching for all screens, training courses, and heritage profiles.
- **Localized Content**: Legends and course prose use `LocalizedText` `(en, sw)` pairs rendered via the `lt()` resolver.

---

## 🏗️ Architecture

- **State Management**: Riverpod 2.5+ (`NotifierProvider` and code generation patterns).
- **Navigation**: GoRouter with `StatefulShellRoute` for bottom navigation tabs.
- **Mapping**: MapLibre GL with Carto dark basemap (free, keyless, offline-capable).
- **Database**: Pure Drift SQLite database (`ActivityRepository`).

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK: `^3.22.0` (Dart `^3.12.0`)

### Installation & Run
```bash
flutter pub get
flutter run
```

### Testing & Analysis
```bash
flutter analyze
flutter test
```
