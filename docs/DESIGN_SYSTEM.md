# Mwendo Design System

This document describes the canonical design tokens and components introduced to unify the UI across all screens.

**App Version:** 1.0.1+2

## Design Tokens (in `AppTheme`)

### Spacing Scale (4pt grid)
```dart
AppTheme.s2  // 2
AppTheme.s4  // 4
AppTheme.s6  // 6
AppTheme.s8  // 8
AppTheme.s10 // 10
AppTheme.s12 // 12
AppTheme.s16 // 16
AppTheme.s20 // 20
AppTheme.s24 // 24
AppTheme.s28 // 28
AppTheme.s32 // 32
AppTheme.s48 // 48
```

### Radius Scale
```dart
AppTheme.r8   // 8
AppTheme.r12  // 12
AppTheme.r16  // 16
AppTheme.r24  // 24
AppTheme.rFull // 999 (pill)
```

### Motion Tokens
```dart
AppTheme.dFast      // 150ms — micro-interactions, ticks
AppTheme.dMed       // 300ms — state changes, content fades
AppTheme.dSlow      // 520ms — entrance/staggered reveals
AppTheme.curveSnappy // Curves.easeOutCubic — UI state changes
AppTheme.curveSpring // Curves.elasticOut — playful/overshoot
```

### Elevation / Shadow Tokens
```dart
AppTheme.elevation0 // [] — flat
AppTheme.elevation1 // Subtle card shadow
AppTheme.elevation2 // Standard card shadow
AppTheme.elevation3 // Elevated card / modal
AppTheme.elevation4 // FAB / primary action
```

### Icon Container Sizes
```dart
AppTheme.iconContainerSm // 40
AppTheme.iconContainerMd // 48
AppTheme.iconContainerLg // 56
AppTheme.iconContainerXl // 64
```

### Avatar Sizes
```dart
AppTheme.avatarSm // 32
AppTheme.avatarMd // 40
AppTheme.avatarLg // 56
AppTheme.avatarXl // 68
```

### Navigation Bar
```dart
AppTheme.navBarHeight // 72
```

---

## Canonical Components

### AppCard (`lib/widgets/app_card.dart`)

Base card with consistent padding, radius, shadow, and optional tap handling.

```dart
AppCard(
  padding: EdgeInsets.all(AppTheme.s16),
  shadows: AppTheme.elevation1,
  onTap: () {},
  child: YourContent(),
)
```

**Variants:**
- `AppCard` — solid surface color, configurable shadows
- `AppGradientCard` — gradient background
- `TierCard` — challenge/achievement tier card with subtle gradient and completion glow

### AppButton (`lib/widgets/app_button.dart`)

Four style variants with consistent padding, radius, and shadows.

```dart
AppButton.primary(
  child: Text('Start Run'),
  onPressed: () {},
)

AppButton.secondary(
  child: Text('Cancel'),
  onPressed: () {},
)

AppButton.ghost(
  child: Text('Skip'),
  onPressed: () {},
)

AppButton.destructive(
  child: Text('Delete'),
  onPressed: () {},
)
```

### AppAvatar (`lib/widgets/app_avatar.dart`)

Consistent avatar sizes with image, initials, or icon fallback.

```dart
AppAvatar.md(imagePath: path)                    // 40px
AppAvatar.lg(initials: 'JD')                     // 56px
AppAvatar.sm(icon: Icons.person)                 // 32px
AppAvatar.xl(imagePath: path, onTap: () {})      // 68px, tappable
```

**Sizes:** `xs` (24), `sm` (32), `md` (40), `lg` (56), `xl` (68)

### MetricTile (`lib/widgets/metric_tile.dart`)

Single metric display used across dashboard, live tracking, profile, and activity detail.

```dart
MetricTile(
  variant: MetricVariant.hero,   // Large, for primary metrics
  value: '5.42',
  label: 'Distance',
  valueColor: AppTheme.brand,
)

MetricTile(
  variant: MetricVariant.card,   // Standard card metric
  value: '123',
  label: 'Runs',
)

MetricTile(
  variant: MetricVariant.inline, // Compact, for secondary rows
  value: '4:32',
  label: '/km',
  align: TextAlign.end,
)
```

---

## Usage Guidelines

### ✅ Do
- Use `AppTheme` tokens for all spacing, radius, motion, and sizing
- Use `AppCard` instead of raw `Container` + `BoxDecoration`
- Use `AppButton` variants instead of `FilledButton.styleFrom`
- Use `AppAvatar` factory constructors for consistent sizing
- Use `MetricTile` for all metric displays
- Access semantic colors via `context.tokens` (e.g., `context.tokens.recording`)

### ❌ Don't
- Hardcode pixel values (e.g., `Container(width: 48, height: 48)`)
- Create ad-hoc `BoxDecoration` with custom shadows
- Use `CircleAvatar` with hardcoded radii
- Duplicate button styling in multiple screens
- Use `Colors.white38` or other hardcoded colors (use `cs.onSurfaceVariant`)

---

## Migration Status

| Pattern | Before | After |
|---------|--------|-------|
| Metric tiles | 2 implementations | `MetricTile` (canonical) |
| Cards | 15+ ad-hoc patterns | `AppCard` / `TierCard` |
| Buttons | `FilledButton.styleFrom` repeated | `AppButton` variants |
| Avatars | `CircleAvatar(radius: N)` everywhere | `AppAvatar.md/lg/xl` |
| Shadows | Custom `BoxShadow` per screen | `AppTheme.elevation1-4` |
| Icon containers | Hardcoded 40/48/56/64 | `AppTheme.iconContainer*` |
| Nav bar height | Hardcoded 72 | `AppTheme.navBarHeight` |

---

## Extending the System

When adding new tokens or components:
1. Add tokens to `AppTheme` (keep 4pt grid for spacing, consistent naming)
2. Create canonical component in `lib/widgets/`
3. Update this document
4. Migrate 1-2 screens to validate the API
5. Roll out incrementally

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.1 | 2026-07-10 | Fixed back navigation (Legends → Learn), fixed all Dart compilation errors (LatLng type mismatches, pattern matching, missing imports), bumped version to 1.0.1+2 |
| 1.0.0 | 2026-07-09 | Initial design system extracted and documented |