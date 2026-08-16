# Mwendo Design System & UI Specification

The Mwendo design system is built to deliver a premium, high-contrast, dark-mode-first aesthetic inspired by elite athletic performance and East African running culture.

---

## 1. Color Tokens & Semantic Palettes

### Primary Brand Palette
* **Brand Primary (`AppTheme.brand`)**: `#FE2E4B` (Vibrant Crimson / Coral)
* **Brand Secondary (`AppTheme.brandSecondary`)**: `#FF5A1F` (Sunset Orange)
* **Brand Gradient**: `LinearGradient(colors: [Color(0xFFFE2E4B), Color(0xFFFF5A1F)])`

### Dark Mode Neutral Surfaces
* **Background (`AppTheme.darkBackground`)**: `#0B0B0C` (Deep Onyx)
* **Surface Card (`AppTheme.darkSurface`)**: `#16171A` (Charcoal Slate)
* **Elevated Surface (`AppTheme.darkSurfaceElevated`)**: `#1F2024`
* **Border Subdued (`AppTheme.darkBorder`)**: `#2C2D32`

### Accent & Functional Semantics
* **Success / GPS Accurate**: `#2BB673` (Emerald Green)
* **Warning / Minor Signal Gap**: `#FFD15C` (Amber Gold)
* **Error / GPS Outlier Rejected**: `#FE2E4B` (Crimson)
* **Info / Blue**: `#3B82F6`

### Legend Tier Accents
* **Bronze Tier**: `#CD7F32` (125% of WR)
* **Silver Tier**: `#C0C6CC` (110% of WR)
* **Gold Tier**: `#FFD15C` (102% of WR)
* **G.O.A.T. Tier**: `#FF5A1F` (World Record Pace)

---

## 2. Typography

The typography system uses Google Fonts with clean letter-spacing for athletic HUD displays:

* **Display Metric**: `TextStyle(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1.0)`
* **Headline / Section Title**: `TextStyle(fontSize: 22, fontWeight: FontWeight.w700)`
* **Body Regular**: `TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white70)`
* **Metric Unit Caption**: `TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white38)`

---

## 3. Glassmorphism & Elevation Tokens

* **HUD Glass Overlay**:
  * Backdrop Filter: `ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0)`
  * Background Color: `Theme.of(context).colorScheme.surface.withValues(alpha: 0.70)`
  * Border: `Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.0)`
* **Card Corner Radius**:
  * Standard Card: `BorderRadius.circular(16.0)`
  * Floating HUD Container: `BorderRadius.circular(24.0)`
  * Pill Badges / Controls: `BorderRadius.circular(999.0)`

---

## 4. Atomic Design Components (`app/lib/design_system`)

* **`AppMapHud`**: Floating glassmorphism dashboard overlay displaying split pace, delta vs ghost, and GPS lock indicator.
* **`AppLegendCard`**: Athlete profile showcase highlighting legendary achievements, PB stats, and background story.
* **`AppContinueBanner`**: Crash recovery callout alerting runners to interrupted sessions with single-tap resumption.
* **`AppSegmentedControl`**: Pill-shaped multi-choice selector for difficulty tiers and activity filtering.
* **`AppStreakRing`**: Circular SVG progress gauge visualizing weekly workout streaks and knowledge lesson progression.
