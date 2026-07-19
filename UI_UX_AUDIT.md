# Mwendo App — Comprehensive UI/UX Audit

## Executive Summary

The codebase shows a **mature, intentional design system** with strong foundations: a 4pt spacing grid, a curated Kenyan-flag-inspired palette, typography via Google Fonts (Inter), `ThemeExtension` semantic tokens, and reusable components (`AppCard`, `MetricTile`, `SectionTitle`). However, several **consistency, contrast, and navigation gaps** remain. Most critically, the app is wired to a **single static brand color** (`AppTheme.brand`) in many widgets, making multi-color theming difficult without a refactor.

---

## 1. Visual Design Audit

### ✅ Strengths

| Area | Assessment |
|---|---|
| **Typography** | Inter via `GoogleFonts` with a deliberate type scale (`displayLarge` 56 → `labelSmall` 10). Metric numbers use tabular figures (`FontFeature.tabularFigures()`) — excellent for pacing/distance readability. |
| **Color palette** | Cohesive: kinetic orange brand (`#FF5A1F`), "K-Earth" greens, danger red, achievement gold. Dark surfaces are deep (`#0B0B0C` / `#161618`) for an athletic, premium feel. |
| **Spacing** | Consistent 4pt grid (`AppTheme.s2` → `s48`) applied almost everywhere. |
| **Radius** | Unified to 12, 16, 24 dp. Hero cards use 24 dp; buttons use 12 dp. |
| **Elevation** | Shadow tokens (`elevation0` → `elevation4`) exist and are used for depth. |
| **Iconography** | Filled/rounded Material icons with consistent 24 dp size and 600 weight. |
| **Motion** | Documented duration/curve tokens and haptic intent map. |
| **Design-system widget library** | `MetricTile` (one stat style everywhere), `AppCard`, `SectionTitle`, `AppSegmentedControl`, `AppEmptyState`, `AppCourseTile`, `AppLessonCard`, `AppLegendCard` — canonical components reduce cognitive load. |

### ⚠️ Weaknesses / Inconsistencies

1. **Explore page is visually disconnected**
   - `explore_page.dart:149-204` uses raw `Card` + `ListTile` with default Material styling, default icon sizes/colors, and no design-system components.
   - It breaks the athletic, high-contrast language used in Dashboard/Learn/Profile.
   - `_SegmentControl` in `explore_page.dart:98-147` uses hardcoded English labels (`'Routes'`, `'Segments'`, `'Leaderboards'`) instead of localized strings.

2. **Two bottom-nav implementations**
   - `app_router.dart:257-347` contains the active `ScaffoldWithNavBar`.
   - `design_system/app_bottom_nav.dart` is a near-duplicate with conflicting tab order (Track at index 1 vs Explore at index 2) and is **unused**.
   - **Risk:** dead code that can confuse future developers and drift out of sync.

3. **Overuse of `AppTheme.brand` instead of `ColorScheme`**
   - Found in `dashboard_page.dart`, `profile_page.dart`, `learn_page.dart`, `live_dashboard.dart`, `app_button.dart`, and many others.
   - Hardcoding `AppTheme.brand` prevents dynamic color switching and defeats Material 3's `ColorScheme`.

4. **Gradient overuse (partially addressed)**
   - Dashboard cards, first-run hint, start button, onboarding, learn hero all use the same orange gradient.
   - Post-audit dashboard refresh reduced this, but the issue persists on other pages.
   - Reduces visual hierarchy when every surface competes for attention.

5. **Card uniformity (partially addressed)**
   - Pre-audit: challenge cards, recent run tiles, learn row cards, all-done card, and empty activity containers all shared the exact same visual treatment — same radius, same surface color, same padding.
   - Dashboard was refreshed to fix this, but other pages (Activity list, Explore, Learn) remain.

6. **Border radius inconsistencies**
   - `AppCard` defaults to 16 dp, but `dashboard_page.dart`, `profile_page.dart`, `activity_detail_page.dart` still hand-build `Material`/`InkWell` cards with 16 dp instead of reusing `AppCard`.

---

## 2. Usability & UX Assessment

### ✅ Strengths

- **Canonical metric tile system** — one component for all stats, reducing cognitive load.
- **Clear navigation model** — 5-tab shell with slide/fade transitions; `branchRootFor` gives sane deep-link back behavior.
- **Haptic mapping** — consistent feedback for selection, start, stop, celebrate.
- **Onboarding** — clear value props, skippable, page indicators.
- **Run UX** — large start button, status pill, ghost race HUD, SOS button.
- **SOS countdown** — escalating urgency ring with amber→orange→red progression.

### ⚠️ Friction Points

1. **Dashboard auto-requests location in `initState`** (`dashboard_page.dart:33-41`)
   - Immediate runtime permission on first app open is aggressive and may hurt retention.
   - Consider requesting it contextually (after onboarding or first "Start Run" tap).

2. **Bottom nav label mismatch**
   - Router tabs: Home, **Track**, Explore, Learn, You.
   - Central nav icon label says **Run**, not Track. This mismatch can disorient users.

3. **Swipe-to-switch on the whole body** (`app_router.dart:271-280`)
   - `GestureDetector` wraps the entire shell body.
   - On pages with horizontal `ListView`s (Learn, Profile), this can cause gesture conflicts and accidental tab switches.
   - Mitigation: run tab is excluded, but not general enough.

4. **Duplicate controls in Profile** (`profile_page.dart:432-449` and `profile_page.dart:239-257`)
   - Language, units, and appearance toggles appear in both `_QuickSettings` chips **and** the settings list below.
   - Users may be unsure which one is authoritative.

5. **No pull-to-refresh**
   - Dashboard, Activity list, and Explore lack `RefreshIndicator`, leaving users without a manual refresh affordance.

6. **"See all" action labels are tiny** (`section_title.dart:20-31`)
   - `SectionTitle` uses a `TextButton` with `padding: EdgeInsets.zero`, `minimumSize: Size.zero`, and `MaterialTapTargetSize.shrinkWrap`.
   - **Touch target is far below the 48×48 dp recommendation.**

7. **Profile page is extremely long** (`profile_page.dart` — ~913 lines)
   - Achievements grid, legends, titles, leaderboard, account, settings all on one scroll.
   - No visual grouping beyond section titles; users can get lost.

8. **Explore content is under-designed** (`explore_page.dart`)
   - No search, filters, maps, images, or empty-state illustration.
   - Hardcoded English labels in segment control.

9. **Snackbar for background-location denial** (`live_dashboard.dart:342-351`)
   - Showing a `SnackBar` immediately after permission denial can be missed.
   - Use a persistent bottom sheet or inline education card.

10. **Random learning insight** (`activity_detail_page.dart:278-279`)
    - Uses `DateTime.now().day` to pick a legend — may change daily but is unrelated to the run.
    - Tie insight to run context (distance, pace) or remove randomness.

---

## 3. Accessibility Concerns (WCAG 2.1)

### ❌ Issues Requiring Attention

| Issue | Location | WCAG Criterion | Recommended Fix |
|---|---|---|---|
| **Tiny touch targets** | `section_title.dart:20-31` "See all" TextButton with `shrinkWrap` | 2.5.5 Target Size (Enhanced) | Min 48×48 dp tap target. |
| **Missing Semantics** | Most icon-only buttons (chevrons, share, settings icons) | 1.1.1 Non-text Content / 4.1.2 Name, Role, Value | Add `tooltip` and `Semantics` labels to all `IconButton`s. |
| **Emoji-only illustration** | `dashboard_page.dart:759` `_RunIllustration` uses 🏃 | 1.1.1 Non-text Content | Add `Semantics(label: 'runner illustration')` or replace SVG with text label. |
| **Low-contrast ghost text** | Various `bodySmall` at 55–60% opacity on `cs.surface` in dark mode may fall below 4.5:1 | 1.4.3 Contrast (Minimum) | Verify with a contrast checker; aim ≥ 4.5:1 for 14dp text. Raise opacity floor to ~0.65 in dark mode. |
| **Onboarding skip button** | `onboarding_page.dart:60-63` top-right `TextButton` with default padding | 2.5.5 Target Size | Wrap in `Padding` ≥ 48 dp or use `minimumSize`. |
| **No focus visibility** | Custom buttons (`_StartButton`, `_ControlBar`) use `GestureDetector`/`InkWell` without focus rings | 2.4.7 Focus Visible | Use `FocusableActionDetector` or Material buttons. |
| **Challenge progress indicator min-height** | `dashboard_page.dart:459` minHeight 6 dp | 1.4.11 Non-text Contrast | Consider 8 dp for better readability at arms length. |
| **Hardcoded `white70` opacity labels** | `_WeeklyCard` hero metrics use `Colors.white70` for labels on gradient | 1.4.3 Contrast | Ensure 70% white on orange gradient passes 3:1 minimum for large text; if not, use `Colors.white` at 85% or `Colors.white60` at larger font. |

### ✅ Accessibility Strengths

- `Semantics` used for streak/level badges (`dashboard_page.dart:213, 231`) and the record button (`live_dashboard.dart:503, 568, 752`).
- `NavigationBar` labels always show, improving affordance.
- Status pills on the live map use white text on a dark translucent backdrop for strong contrast.
- Tabular figures for numbers help users compare metrics.
- SOS dialog uses a clear countdown ring with escalating color urgency.

---

## 4. Actionable Recommendations

### A. Design Improvements

1. **Unify card surfaces:** Replace hand-built `Material`/`InkWell` card wrappers with `AppCard` / `AppGradientCard` / `TierCard` across all pages.
2. **Reduce gradient noise:** Reserve orange gradients for the primary CTA and hero; use surface + accent tint cards elsewhere to restore hierarchy.
3. **Redesign Explore:**
   - Add route thumbnails or mini-maps.
   - Replace `ListTile` cards with `AppCard`-based route tiles.
   - Add search + filter chips.
   - Localize segment labels.
4. **Group Profile settings:**
   - Use cards/sections with headers: Preferences, Account, Safety, Data.
   - Remove redundant quick-settings chips or move them to the top as a compact control bar, not duplicated below.
5. **Add pull-to-refresh:** wrap scrollable bodies with `RefreshIndicator` and wire to provider invalidation.
6. **Apply dashboard pattern to other pages:** colored left-border stripes for category differentiation, per-type color coding for list items.

### B. Functional Fixes

1. **Delete `design_system/app_bottom_nav.dart`** or merge its logic into `app_router.dart`'s `ScaffoldWithNavBar`.
2. **Clarify tab naming:** label index 1 consistently as "Run" everywhere (router path `/run`, nav label, analytics).
3. **Wrap the shell body correctly:** use `PageView` with `NeverScrollableScrollPhysics` or restrict swipe switching to safe areas; disable on pages with horizontal scrolls.
4. **Defer location request:** move from `initState` to the first user intent to start a run (or a contextual coach mark).
5. **Localize Explore segments** (`explore_page.dart:107-111`).

### C. Layout Optimizations

1. **Increase touch targets:** minimum 48×48 dp for all icon buttons and inline actions.
2. **Padding/rhythm audit:** ensure horizontal padding is always 24 dp; avoid 16 dp in Explore mixed with 24 dp elsewhere.
3. **Reduce Profile scrolling burden:** consider tabbed layout (Stats, Achievements, Settings) once content grows further.
4. **Use `CustomScrollView` consistently:** Explore currently uses `Column` + `Expanded` + `ListView` instead of slivers.

### D. Accessibility Quick Wins

1. Add `tooltip` to all `IconButton`s.
2. Wrap emoji-only widgets with `Semantics`.
3. Enforce 48 dp touch targets on `SectionTitle` action and onboarding skip.
4. Audit all `bodySmall` muted text for contrast; increase opacity floor to ~0.65 in dark mode.
5. Use `FilledButton`/`TextButton` from Material rather than custom `GestureDetector` CTAs where possible.
6. Bump progress indicator min-height to 8 dp.

---

## 5. Theming Architecture Proposal

### Current State

- `AppTheme` contains static const colors.
- `ThemeData.light`/`dark` are built from `ColorScheme.fromSeed` but then overwrite `primary`, `secondary`, surfaces, etc.
- `AppExtensions` is a `ThemeExtension` carrying semantic tokens (recording, paused, achievement, brand gradient, metric styles).
- Many widgets bypass `Theme.of(context).colorScheme` and call `AppTheme.brand` directly.
- `themeModeProvider.dart` persists dark/light/system mode only, not palette.

### Goal

Allow users to switch between curated color themes (e.g., default Kinetic Orange, Kenyan Green, Midnight Blue, Berry, etc.) with:
- correct contrast,
- consistent visual hierarchy,
- minimal widget changes,
- dark/light support per theme.

### Proposed Architecture

#### 1. Define a `ColorPalette` data class

```dart
@immutable
class ColorPalette {
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color gradientEnd;
  final Color danger;
  final Color warning;
  final Color success;
  final Color achievement;
  final Color idle;
  // ...
}
```

Provide named constructors:

```dart
const ColorPalette.orange()   // current kinetic orange (#FF5A1F)
const ColorPalette.forest()   // Kenyan green (#1B8A5A)
const ColorPalette.ocean()    // blue (#4A90E2)
const ColorPalette.berry()    // purple/magenta
```

#### 2. Replace direct `AppTheme.brand` calls with theme tokens

Use `Theme.of(context).colorScheme.primary` and `context.tokens.brandGradient` instead of `AppTheme.brand`.

For any widget that needs brand color:

```dart
// Before
color: AppTheme.brand

// After
color: Theme.of(context).colorScheme.primary
// or
color: context.tokens.primary
```

This is the biggest refactor but is mandatory for multi-color support.

#### 3. Generate `ColorScheme` and `AppExtensions` from palette

```dart
ThemeData buildTheme(ColorPalette palette, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: palette.primary,
    brightness: brightness,
  ).copyWith(
    primary: palette.primary,
    secondary: palette.secondary,
    error: palette.danger,
    // surface colors derived from seed or palette...
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [AppExtensions.from(palette, brightness)],
    // ...
  );
}
```

`AppExtensions.from()` generates:
- semantic colors (recording, success, etc.),
- metric text styles tinted for the theme,
- brand gradient from palette,
- dark/light-aware flag green.

#### 4. Persist and expose palette selection

Create:

```dart
final paletteProvider = NotifierProvider<PaletteNotifier, ColorPalette>(...);
```

Persist chosen palette key in `SharedPreferences` alongside `themeModeProvider`.

Usage:

```dart
final palette = ref.watch(paletteProvider);
return MaterialApp.router(
  theme: buildTheme(palette, Brightness.light),
  darkTheme: buildTheme(palette, Brightness.dark),
  themeMode: ref.watch(themeModeProvider),
  // ...
);
```

#### 5. Build a theme picker UI

In Profile → Appearance:

```dart
SectionTitle('Color Theme'),
Wrap(
  spacing: 12,
  children: [
    _ThemeSwatch(palette: const ColorPalette.orange(), selected: ...),
    _ThemeSwatch(palette: const ColorPalette.forest(), selected: ...),
    // ...
  ],
)
```

Each swatch previews primary color + gradient end.

#### 6. Ensure contrast dynamically

- Use `ColorScheme.onPrimary` / `onSurface` for text instead of hardcoded white/black where possible.
- Keep the existing dark surfaces but **derive text contrast from palette** for the brand/CTA text.
- For gradients overlaid with white text, pre-flight palettes using `ThemeData.estimateBrightnessForColor` and reject or adjust low-contrast combinations.

#### 7. Migration Path (Minimal Risk)

1. Introduce `ColorPalette` and `AppExtensions.from()` without changing UI yet.
2. Add a lint/rule: no new `AppTheme.brand` usage.
3. Incrementally replace `AppTheme.brand` with `cs.primary` / `context.tokens.primary` widget by widget.
4. After refactor, enable the theme picker.
5. Remove `AppTheme.brand` const (or keep it only as the palette fallback).

### Benefits

- **One source of truth** for color (the theme tree).
- **No widget rebuilds** necessary when adding new palettes — the theme tree propagates changes.
- **Dark/light compatibility** out of the box.
- **Future-proof** for Material 3 dynamic color (Android wallpaper) by feeding generated seed colors into `ColorScheme.fromSeed`.

---

## Priority Matrix

| Priority | Item | Effort | Impact |
|---|---|---|---|
| **P0** | Delete/merge duplicate bottom nav (`app_bottom_nav.dart`) | Low | Eliminates confusion + dead code |
| **P0** | Enforce 48 dp touch targets on SectionTitle, onboarding skip | Low | Accessibility compliance |
| **P0** | Add `tooltip` to all `IconButton`s | Low | WCAG 1.1.1 / 4.1.2 |
| **P0** | **Fix Learn navigation: use `push()` for drill-down routes** | Low | Navigation now works correctly - back goes to parent page |
| **P1** | Remove/replace `AppTheme.brand` direct usage with theme tokens | Medium | Enables multi-color theming |
| **P1** | Redesign Explore page with design-system components | Medium | Visual consistency |
| **P1** | Defer location permission request | Low | Onboarding retention |
| **P1** | Clarify bottom-nav tab naming ("Track" → "Run") | Low | Navigation clarity |
| **P2** | Implement `ColorPalette` + theme picker | Medium | Feature differentiation vs. Strava/NRC |
| **P2** | Deduplicate Profile quick settings / settings tiles | Low | Simplifies profile page |
| **P2** | Add pull-to-refresh to dashboard/activity/explore | Low | User control + perceived performance |
| **P2** | Apply dashboard differentiation pattern to Learn, Activity pages | Medium | Consistent visual freshness across the app |
| **P3** | Add `Semantics` labels to all icon-only controls | Low | Accessibility |
| **P3** | Contrast audit and adjust muted text opacity floor to 0.65 | Low | WCAG 1.4.3 |
| **P3** | Use `AppCard` / design-system components consistently across all pages | Medium | Long-term maintainability |
| **P3** | Replace hardcoded English labels in Explore segment control | Low | i18n completeness |

---

## Files Referenced

| File | Key Role |
|---|---|
| `app/lib/core/theme/app_theme.dart:1-465` | Design tokens, color palette, ThemeData, AppExtensions |
| `app/lib/core/theme/theme_mode_provider.dart:1-44` | Dark/light/system mode persistence |
| `app/lib/features/home/dashboard_page.dart:1-824` | Primary home screen — main audit target |
| `app/lib/features/profile/profile_page.dart:1-913` | User profile, stats, settings, leaderboard |
| `app/lib/features/explore/explore_page.dart:1-204` | Routes/segments/leaderboards — under-designed |
| `app/lib/features/learn/learn_page.dart:1-408` | Learning hub — lessons, courses, legends |
| `app/lib/features/activity/activity_detail_page.dart:1-377` | Post-run detail with charts |
| `app/lib/features/onboarding/onboarding_page.dart:1-192` | First-run value prop flow |
| `app/lib/features/tracking/live_dashboard.dart:1-933` | Live run screen with map, stats, controls |
| `app/lib/core/router/app_router.dart:1-421` | GoRouter config, ScaffoldWithNavBar, bottom nav |
| `app/lib/core/navigation/navigation.dart:1-107` | Back behavior, branch root mapping |
| `app/lib/design_system/app_bottom_nav.dart:1-84` | **Unused** duplicate bottom-nav — delete or merge |
| `app/lib/widgets/metric_tile.dart:1-67` | Canonical metric display component |
| `app/lib/widgets/section_title.dart:1-36` | Section header with "see all" action |
| `app/lib/widgets/app_card.dart:1-153` | Canonical card components (AppCard, AppGradientCard, TierCard) |
| `app/lib/widgets/app_button.dart:1-162` | Canonical button styles |
| `app/lib/design_system/app_course_tile.dart:1-54` | Course grid tile |
| `app/lib/design_system/app_lesson_card.dart:1-70` | Horizontal lesson card |
| `app/lib/design_system/app_legend_card.dart:1-68` | Legend row card |
| `app/lib/design_system/app_empty_state.dart:1-45` | Reusable empty state |
| `app/lib/design_system/app_segmented_control.dart:1-75` | Reusable segmented control |
| `app/lib/core/gamification/challenge_evaluator.dart:1-36` | Challenge definitions + tier mapping |
| `app/lib/features/learn/data/courses.dart:1-346` | Course/lesson data with category accent colors |
| `app/lib/features/learn/data/legend_of_day.dart:1-102` | Daily legend card on dashboard |
| `app/lib/core/l10n/app_strings.dart:1-320` | Localization catalog (en/sw) + `LocalizedText` + `lt()` helper |
| `app/lib/features/learn/data/legends.dart:1-398` | Legends data — migrated to `LocalizedText` (en/sw prose) |
| `app/lib/features/learn/legend_detail_page.dart:1-250` | Legend detail renderer — uses `lt()` for all prose |
| `app/lib/features/learn/learn_page.dart:1-408` | Learning hub — uses `lt()` for course/legend titles |
| `app/lib/features/home/dashboard_page.dart:1-824` | Dashboard — uses `lt()` for learn row course titles |

---

*Audit performed 2026-07-11. Dashboard page was refreshed with differentiated card treatments following this audit. Remaining pages (Explore, Profile, Learn, Activity detail) still need the same differentiation pass.*

*Localization progress (2026-07-12): Added `LocalizedText` + `lt()` to `app_strings.dart`. Migrated `legends.dart` and `courses.dart` to bilingual en/sw pairs. Updated renderers in `learn_page.dart`, `legend_detail_page.dart`, `dashboard_page.dart`, `activity_detail_page.dart`. Added ~62 missing `L10n.tr()` keys (P0). release APK rebuilt as v1.0.2+1.*
