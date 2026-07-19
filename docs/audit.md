# Project Mwendo — UI & Functionality Audit

> Audited every file across `app/lib/`, `packages/`, and `backend/`.
> Classification: **✅ Functional** · **⚠️ Partial/Stubbed** · **❌ Non-functional or Missing**
>
> **Last refreshed: 2026-07-10** — supersedes the original pre-fix audit. The
> component verdicts below still hold; this refresh captures fixes and remaining
> issues found in the latest full systems audit (see "Post-audit fixes applied"
> and "Current known issues" below).

---

## 1. App Entry & Shell

| Component | File | Verdict |
|---|---|---|
| App bootstrap | [main.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/main.dart) | ✅ Clean — `ProviderScope`, `FlutterError.onError` |
| Root widget | [app.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/app.dart) | ✅ `MaterialApp.router`, dark mode default, Google Fonts |
| Router | [app_router.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/router/app_router.dart) | ✅ All 14 routes defined with `StatefulShellRoute` bottom nav |
| Bottom nav | `ScaffoldWithNavBar` in router | ✅ 5 tabs with a floating gradient "Run" icon |
| Theme system | [app_theme.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/theme/app_theme.dart) | ✅ Full design system: brand palette, spacing grid, motion tokens, HR zone ramp, challenge tier colours, `AppExtensions` on both light/dark |

**Notes:**
- ⚠️ `ThemeMode` is hardcoded to `ThemeMode.dark` in `app.dart`. The profile page has an "Appearance" setting tile (`_SettingTile`) but it does nothing — it doesn't toggle the theme. 
- ⚠️ The `_RunNavIcon` in the nav bar has a gradient glow but is not state-aware — it always shows a play arrow even when a run is actively recording. On a real device, users may not know they're still recording if they tab away.

---

## 2. Onboarding

| Screen | File | Verdict |
|---|---|---|
| 3-slide flow | [onboarding_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/onboarding/onboarding_page.dart) | ✅ Fully functional |

**What works:** PageView swipe + animated dot indicators + skip/next/get-started button. `SharedPreferences`-backed onboarding-done flag. Invalidates provider, navigates via `context.go('/')`.

**UI nits:**
- The body text colour is hardcoded `Colors.white70` — this will be wrong on light theme.
- No illustration/image on the slides — just a material icon inside a gradient circle. Adequate for MVP, but sparse compared to competitors.

---

## 3. Dashboard / Home

| Screen | File | Verdict |
|---|---|---|
| Dashboard | [dashboard_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/home/dashboard_page.dart) | ✅ Rich, well-composed |

**What works:**
- Top bar with streak flame + level badge.
- Weekly stats hero card (gradient, distance, runs, time, best pace) — all from gamification state.
- Active challenges shown via `ChallengeEvaluator.allChallenges` with real progress bars.
- "Continue learning" horizontal course carousel.
- "Recent activity" area with skeleton shimmer loading.

**Functional issues:**
- ⚠️ **Fake loading state** — `_loading` is just a `Future.delayed(700ms)` timer, not tied to any real data fetch. After 700ms it always shows `_EmptyActivity`. Even if `SampleActivity.all()` returns data, the dashboard ignores it.
- ⚠️ **"Start Run" button** is full-width but doesn't indicate GPS permission state. Will navigate to `/run` regardless.
- ⚠️ All weekly stats are `0` until the user completes a run through the gamification engine. There's no onboarding hint or animation to guide a first-time user.

---

## 4. Live Tracking / Run

| Screen | File | Verdict |
|---|---|---|
| Live dashboard | [live_dashboard.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/live_dashboard.dart) | ✅ Architecturally complete |
| Tracking controller | [tracking_controller.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/tracking_controller.dart) | ✅ Haversine, elevation gain, pace, calorie estimate |
| Metric tile | [metric_tile.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/tracking/widgets/metric_tile.dart) | ✅ |
| SOS countdown | `_SosButton` in live_dashboard | ✅ 3s countdown dialog |

**What works:**
- 58/42 split-screen: MapLibre map on top, 6-metric dashboard on bottom.
- Recording state pill (Ready / Recording / Paused / GPS…) with pulse glow.
- Start/Pause/Resume/Stop FAB cluster with haptic feedback.
- Live route line drawn on map (`_syncRoute` with LineOptions).
- km milestone haptic.
- Challenge completion confetti overlay on stop.
- Heart rate zone colouring (5-zone ramp) on the HR tile.
- Calorie estimate ~11 kcal/min.

**Functional issues:**
- ⚠️ **Map tile source is remote** — uses `basemaps.cartocdn.com` dark-matter style. No offline fallback; the run screen will show blank tiles without internet. The blueprint calls for offline MBTiles.
- ⚠️ **No GPS permission request** — `startRecording()` is called blindly. On Android 12+, the app will crash or silently get no points if location permissions haven't been granted. There's no runtime permission prompt anywhere in the app.
- ⚠️ **SOS dialog is visual only** — the countdown fires but `_confirmSos` never actually calls `SafetyService.sendSos()`. There's no emergency contact storage, so even if it did call the service, there's nothing to send to.
- ⚠️ **Tracking doesn't survive app tab-out** — the `TrackingModel` runs the GPS stream subscription in the widget lifecycle. If the user leaves the tab, the stream continues but there's no foreground service / notification keeping the process alive on Android. The OS can kill the location listener.
- ⚠️ **`_onStop` challenge evaluation bug** — `completeRun` is called with the model *before* `stop()` clears state, but `stop()` is `await`ed before reading the newly completed challenges. The read `m` captures the state correctly, but the `ref.read(gamificationProvider.notifier).completeRun()` uses a snapshot `m` — this is actually fine. However, the `next.earnedBadges.add(c.badgeId)` inside the gamification provider mutates a set that was created by `copyWith`, which is safe as long as `copyWith` creates new sets. Inspecting `copyWith`: it does `??` fallback, so it reuses the same set reference. **This is a mutation bug** — `earnedBadges` inside `next` is the same `Set` object as `state.earnedBadges` if not overridden, and `c.badgeId` modifies it in place.

---

## 5. Challenges

| Screen | File | Verdict |
|---|---|---|
| Library (grid) | [challenge_library_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_library_page.dart) | ✅ Rich UI with filters |
| Detail page | [challenge_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_detail_page.dart) | ✅ |
| Evaluator | [challenge_evaluator.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/challenges/challenge_evaluator.dart) | ✅ ~50 challenges |

**What works:**
- Level header with `LevelRing` + XP bar.
- 6 category filter chips (All / Starter / Milestones / Performance / Fun / School / Learn).
- Each challenge card: tier-coloured icon, progress bar, XP reward, description.
- Detail page: gradient hero, tier badge, info tiles (Reward, Badge, Goal), progress bar, CTA button ("Go for a run" or "Open the Academy").

**Functional issues:**
- ⚠️ **Challenge routes clash** — `/challenges/:slug` is registered as a *sibling* route under the same `StatefulShellBranch` as `/challenges`. GoRouter may not resolve nested navigation correctly in all cases because both are top-level routes in the branch.
- ⚠️ **No persistence for per-challenge progress** — progress bars rely entirely on in-memory `GamificationState`, which is restored from SharedPreferences JSON. This works, but there's no debouncing — every `completeRun` serializes the entire state to SharedPreferences synchronously. Fine for now, but worth noting.

---

## 6. Learn / Academy

| Screen | File | Verdict |
|---|---|---|
| Learn landing | [learn_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/learn_page.dart) | ✅ |
| Course detail | [course_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/course_detail_page.dart) | ✅ |
| Lesson reader | [lesson_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/lesson_page.dart) | ✅ |
| Course data | [courses.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/courses.dart) | ✅ |

**What works:**
- Hero banner with brand gradient.
- 3-section course grid (Science / Technique & Health / Heritage) with `GridView.count`.
- Progress bars per course based on completed lessons count.
- Course detail with lesson list → tappable rows.
- Lesson reader: full-text paragraphs, reading-time badge, "Mark complete" button awarding +15 XP with snackbar confirmation.
- Knowledge streak tracking in gamification provider.

**Functional issues:**
- ⚠️ **No quiz flow** — The blueprint specifies quizzes at the end of courses. The lesson page has a "Mark complete" button but no quiz widget.
- ⚠️ **Course slugs are hardcoded** — no CMS, no dynamic loading. Adding content requires code changes. Acceptable for MVP but noted.

---

## 7. Legends & Beat the Legends

| Screen | File | Verdict |
|---|---|---|
| Legends grid | [legends_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/legends_page.dart) | ✅ |
| Legend detail | [legend_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/legend_detail_page.dart) | ✅ |
| Legend data | [legends.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/legends.dart) | ✅ 30 legends seeded |
| Legend of the Day/Week | [legend_of_day.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/legend_of_day.dart) | ✅ |
| Beat the Legends | [beat_legends_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/beat/beat_legends_page.dart) | ⚠️ UI-only (tiers added) |
| Ghost pace data | [beat_legends.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/learn/data/beat_legends.dart) | ✅ 12 paces + tier system |

**What works:**
- Horizontal legend picker carousel with emoji avatars and accent borders.
- Search box plus filter chip rows: Country (Kenya / Ethiopia / Uganda), Discipline, and Era
  (1960s–70s → 2020s+); list filters by text AND active chips.
- Legend detail page with personal-bests grid, career timeline, records, Training Philosophy
  (with a link chip to the related education course), Rivalries chips, Notable Races cards,
  categorized quotes (Training / Racing / Life / Legacy), a Fun Fact card, and a Related Legends
  carousel.
- **How You Compare** — reads the user's logged runs from `activitiesProvider` and matches best
  times per distance (5K / 10K / half / marathon) against the legend's personal bests, showing
  the gap % and a progress bar.
- **Legend of the Day / Week** — deterministic providers (by day / week of year) drive a card on
  the home dashboard with a fun fact and a "Read more" link.
- Ghost header card with gradient, name, distance, target time, avg pace.
- Per-segment splits chart via `fl_chart`.
- **Tier selector** (Bronze 125% / Silver 110% / Gold 102% / G.O.A.T. 100% of record time); the
  header, splits chart, description and race target all rescale with the selected tier.
- "Race this ghost" button navigates to `/run`.

**Functional issues:**
- ⚠️ **Ghost racing is still cosmetic** — pressing "Race this ghost" navigates to the standard run
  page. There is no ghost marker on the map, no real-time pace comparison, and no win/lose logic.
  The ghost splits and tier data exist but are not consumed during an actual run. This remains the
  single biggest gap in Pillar 4.

---

## 8. Activity History

| Screen | File | Verdict |
|---|---|---|
| Activity list | [activity_list_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/activity/activity_list_page.dart) | ✅ Now persists real runs |
| Activity detail | [activity_detail_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/activity/activity_detail_page.dart) | ✅ Displays real routes |
| Sample data | [sample_activities.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/sample_activities.dart) | ✅ Deterministic fake (fallback) |

**What works:**
- Activity list with skeleton shimmer loading.
- Activity detail: top map, stats grid (6 tiles), elevation chart, pace chart, share button.
- Share integration via `share_plus`.
- **Real runs now persist to `activities.json` via `ActivityRepository.save()`** — the save was previously async-without-await, causing runs to disappear. Fixed by awaiting save and invalidating all dependent providers.
- **RouteMap widget now respects user panning** — `_autoFollow` flag prevents recentering after manual interaction.

**Functional issues:**
- ⚠️ **No activity deletion, editing, or filtering.**

---

## 9. Profile

| Screen | File | Verdict |
|---|---|---|
| Profile page | [profile_page.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/profile/profile_page.dart) | ✅ Well-featured |
| Leaderboard data | [leaderboard_data.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/gamification/leaderboard_data.dart) | ⚠️ Static fake |

**What works:**
- User avatar, level, title, XP bar.
- 4-stat row (Distance, Runs, Time, Streak).
- Achievement badge grid (earned via challenges and lessons).
- Title chip wall.
- Leaderboard top-5 with country flags and "You" highlight.
- Language toggle (EN/SW) via `SegmentedButton` → `localeProvider`.
- Settings tiles (Units, Appearance, Emergency contacts, Export data).

**Functional issues:**
- ⚠️ **Leaderboard is entirely fake** — `leaderboard_data.dart` generates static entries with hardcoded names and XP values. The Go backend has a real Redis leaderboard, but the app never calls it.
- ⚠️ **Settings tiles are decorative** — tapping Units, Appearance, Emergency contacts, or Export data does nothing. No sheets, no navigation, no functionality.
- ⚠️ **Username is hardcoded** — `'Runner'` is always displayed. No account system is connected.
- ⚠️ **No profile photo** — uses a plain `CircleAvatar` with a person icon.

---

## 10. Safety

| Component | File | Verdict |
|---|---|---|
| Safety service | [safety_service.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/features/safety/safety_service.dart) | ⚠️ Implemented but disconnected |

**What exists:** `SafetyService.sendSos(contacts, lat, lng)` builds an SMS URL with a Google Maps link and launches it via `url_launcher`.

**Functional issues:**
- ❌ **Never called** — the SOS button's countdown dialog just closes when it reaches 0. It never invokes `SafetyService.sendSos`.
- ❌ **No contact storage** — `EmergencyContact` is defined but there is no UI to add/edit contacts and no persistence layer.

---

## 11. Localization (i18n)

| Component | File | Verdict |
|---|---|---|
| String table | [app_strings.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/l10n/app_strings.dart) | ⚠️ Partial |

**What works:** 30 keys translated EN/SW. `L10n.tr(key, locale)` with fallback to English. `SegmentedButton` toggle on profile page instantly switches visible keys.

**Functional issues:**
- ⚠️ **Only ~30% of strings are translated** — many screens use hardcoded English strings (e.g. "This week", "Start Run", "No runs yet", "All caught up!", challenge titles, lesson titles, legend bios). The i18n system exists but is not consistently used.
- ⚠️ **Not using Flutter's standard ARB/`intl` system** — the blueprint calls for ARB assets. The current approach is a manual `Map<String, Map<String, String>>`, which won't scale well and doesn't get compile-time checks.

---

## 12. Data Layer

| Component | File | Verdict |
|---|---|---|
| Drift database | [app_database.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/database/app_database.dart) | ❌ Stub |
| Drift tables | [tables.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/database/tables.dart) | ❌ Stub |
| Repositories | `data/repositories/` | ❌ Empty directory |
| GPX parser | [gpx_parser.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/data/datasources/gpx_parser.dart) | ✅ Pure Dart XML parse/generate |
| Data models | `activity.dart`, `trackpoint.dart` | ⚠️ Tiny stubs |

**Analysis:**
- The entire offline data layer is missing. `AppDatabase` is an empty singleton. `tables.dart` defines `Users` and `Activities` columns but `build_runner` has never been run — no generated `.g.dart` files exist. The `repositories/` directory is empty.
- The app runs entirely on in-memory state (`GamificationState` in SharedPreferences JSON, `SampleActivity` fakes). Completed runs are counted in XP but never stored as discrete activity records.
- GPX parser is fully functional: parses `<trkpt>` with lat/lon/ele/time and generates GPX XML output. But nothing in the app calls it.

---

## 13. Packages

### mwendo_gps_engine

| Component | Verdict |
|---|---|
| Dart API surface | ✅ `startRecording()`, `pause()`, `resume()`, `stop()`, `state` stream |
| Platform interface | ✅ Abstract class with method channel default |
| Android Kotlin plugin | ⚠️ Method channel skeleton, basic location polling |
| iOS Swift plugin | ❌ Empty template |

**Functional issues:**
- ⚠️ **No foreground service** — location dies when app backgrounds on Android.
- ⚠️ **No speed hysteresis** — the blueprint calls for dynamically switching GPS interval based on running speed (walking = 3s, running = 1s, sprinting = 0.5s). Not implemented.
- ⚠️ **No Kalman filter in the engine** — raw GPS fixes are still emitted as-is (the
  true Kalman/RDP smoother remains on the blueprint roadmap). **Mitigated at the
  app layer:** `TrackingModel` now feeds the live map polyline a separate
  EMA-smoothed, noise-culled view (`_addDisplayPoint` — accuracy-driven alpha +
  5m cull), while raw points remain the source of truth for the DB, distance,
  pace, and SOS. So the stored route is still raw; only the on-screen line is
  smoothed.

### mwendo_fit_parser

| Component | Verdict |
|---|---|
| Dart FFI wrapper | ⚠️ Skeleton with hardcoded path strings |
| Rust crate | ⚠️ Returns mock JSON `{"status": "scaffolded"}` |
| Bindings `.dart` | ⚠️ Referenced but likely not generated |

**Functional issues:**
- ❌ **Cannot parse FIT files** — `_parseJson` returns `{}`. `parseBytes` allocates memory but the Rust side just returns a canned string. 
- ❌ **Cannot compile locally** — Windows lacks MSVC linker for Rust; must be built via CI or cross-compilation.

---

## 14. Backend API

| Component | File | Verdict |
|---|---|---|
| HTTP router | [main.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/cmd/api/main.go) | ✅ |
| Auth handler | `internal/auth/handler.go` + `store.go` | ✅ bcrypt + JWT |
| Activity store | [store.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/activity/store.go) | ✅ PostGIS spatial |
| Leaderboard | [leaderboard.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/leaderboard/leaderboard.go) | ✅ Redis + fallback |
| Migrations | [0001_init.sql](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/internal/db/migrations/0001_init.sql) | ✅ |
| Integration tests | [main_test.go](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/cmd/api/main_test.go) | ✅ All passing |
| Dockerfile | [Dockerfile](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/backend/Dockerfile) | ✅ Multi-stage Alpine |

**Functional issues:**
- ⚠️ **Backend is never called from the Flutter app** — there is no HTTP client, no `dio` interceptor configured, no auth token storage, no API base URL configuration anywhere in the app code. The `dio` package is in `pubspec.yaml` but never imported.
- ⚠️ **Dockerfile copies `go.mod` but not `go.sum`** — `RUN go mod download` will fail without `go.sum`. Should be `COPY go.mod go.sum ./`.
- ⚠️ **No CORS** — if a web client were ever added, the backend doesn't set CORS headers.

---

## 15. Shared Widgets

| Widget | File | Verdict |
|---|---|---|
| CelebrationOverlay | [celebration_overlay.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/celebration_overlay.dart) | ✅ Confetti + trophy |
| LevelRing + XpBar | [level_ring.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/level_ring.dart) | ✅ |
| RouteMap | [route_map.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/route_map.dart) | ✅ Thin wrapper over shared `MwendoMap` (replay mode) |
| SectionTitle | [section_title.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/section_title.dart) | ✅ |
| SkeletonCard | [skeleton.dart](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/widgets/skeleton.dart) | ✅ Shimmer |

---

## 16. Bug Summary (Post-Audit Fixes)

| # | Severity | Location | Description | Status |
|---|---|---|---|---|
| 1 | 🔴 High | [gamification_provider.dart:85](file:///c:/Users/micha/.gemini/antigravity/scratch/RUN/mwendo/app/lib/core/gamification/gamification_provider.dart#L85) | **Set mutation bug** — `next.earnedBadges.add(c.badgeId)` mutates the set in-place. If `copyWith` didn't override `earnedBadges`, `next.earnedBadges` is the same object as the old state's set. | ⚠️ Unchanged |
| 2 | 🔴 High | live_dashboard.dart | **No GPS permission request** — app will fail silently or crash on first run on a fresh install. | ✅ Fixed (run-sequence pass) |
| 3 | 🟡 Medium | live_dashboard.dart | **SOS countdown never sends** — `_confirmSos` timer fires but doesn't call `SafetyService.sendSos`. | ⚠️ Unchanged |
| 4 | 🟡 Medium | Dockerfile L3 | **Missing `go.sum`** — `COPY go.mod ./` should include `go.sum`. | ⚠️ Unchanged |
| 5 | 🟡 Medium | tracking_controller | **No persistence** — completed runs update XP but the activity is discarded. | ✅ Fixed |
| 6 | 🟡 Medium | All screens | **No backend integration** — `dio` is declared but never used. | ⚠️ Unchanged |
| 7 | 🟢 Low | onboarding_page.dart L137 | **Hardcoded `Colors.white70`** — breaks on light theme. | ⚠️ Unchanged |
| 8 | 🟢 Low | dashboard_page.dart L26 | **Fake 700ms loading** — shimmer is cosmetic, not tied to real data loading. | ⚠️ Unchanged |
| 9 | 🔴 High | mwendo_map.dart:187 | **Run-sequence crash (C1)** — live map forced `MyLocationTrackingMode.trackingCompass`, handing the camera to the SDK (and to a not-yet-enabled location layer) → `PlatformException` on the first recording frame. | ✅ Fixed (now north-up `tracking`) |
| 10 | 🔴 High | MwendoTrackingService.kt:163 | **Foreground-service crash (C2)** — `startForeground` failure was swallowed, leaving a broken foreground service that Android killed with `RemoteServiceException`. | ✅ Fixed (`stopSelf` + error to Dart) |
| 11 | 🔴 High | mwendo_map.dart | **Manual zoom non-functional (Z1)** — while tracking, the SDK re-centred/re-rotated every fix so pinch-zoom was overridden; no zoom affordance existed. | ✅ Fixed (north-up tracking + `+/−` zoom FABs) |
| 12 | 🟡 Medium | tracking_controller.dart:187 | **Stuck recovered run (C3)** — `restoreInterrupted` loaded points but never started the engine/ticker, so a recovered run never logged. (A prior fix auto-started the engine from `initState`, which crashed before permission; now load-only + started via the permission-gated path.) | ✅ Fixed |
| 13 | 🟡 Medium | tracking_controller.dart:230 | **Double start (C4)** — recover branch called both `_engine.resume()` and `_engine.startRecording()`, spawning a second subscription/foreground start. | ✅ Fixed (single start via `restoreInterrupted`) |

### Fixes Applied (2026-07-09)

1. **Fixed save/invalidate race condition** (`live_dashboard.dart:475-487`) — Runs now save to JSON file and the activity list refreshes correctly. Invalidate all three providers: repository + list + byId.

2. **Added `avgCadence` and `movingTimeMs` to RunRecord** (`run_record.dart`) — Previously discarded metrics are now persisted. Cadence averaged from trackpoints; moving time tracked via speed threshold.

3. **Fixed MapLibre controller disposal crash** (`live_dashboard.dart:1037`, `route_map.dart:164`) — Removed manual `dispose()` calls; MapLibre handles internally.

4. **Fixed map auto-follow on detail page** (`route_map.dart`) — Added `_autoFollow` flag so saved activity maps can be panned without recentering.

5. **Improved recovery file error handling** (`tracking_controller.dart:157-165`) — Added logging context for stale recovery file issues.

6. **Fixed gamification provider async flicker** (`gamification_provider.dart:37-52`) — Changed fire-and-forget `.then()` to async/await pattern.

7. **Consolidated the two map implementations & removed the offline tile server** (`mwendo_map.dart`, `route_map.dart`, `live_dashboard.dart`) — The live map (`_MapView`) and the detail map (`RouteMap`) were merged into a single shared `MwendoMap` widget with a `live`/`replay` mode enum. The custom loopback MBTiles/PMTiles tile server (`offline_map_provider.dart`, ~430 lines) was deleted along with `MapSource`/the toggle button, eliminating its UI-thread I/O, offline-by-default, and mid-run widget-destruction crash vectors. The app now uses the online Carto dark style everywhere; offline maps move to the roadmap (MapLibre's built-in offline regions API). The live map uses native `MyLocationTrackingMode.trackingCompass` while recording with an explicit re-center button (no more auto-snap-back on every GPS fix); the replay map sets its camera once and redraws via `updateLine` in a new `didUpdateWidget`. Supersedes the earlier `_autoFollow`-based fixes (#3, #4 above).

### Fixes Applied — Run-sequence crash & map zoom (2026-07-09, second pass)

> Full diagnosis in `docs/diagnostic_report.md`. All changes verified with
> `flutter analyze` (clean) and the GPS engine package tests (pass).

8. **Live map no longer forces compass tracking (C1/Z1)** (`mwendo_map.dart:187`) — `_trackingMode` now returns north-up `MyLocationTrackingMode.tracking` instead of `trackingCompass`, so the SDK no longer spins/owns the camera on every fix. This removes the camera-lock that made manual zoom non-functional and the tracking-while-location-disabled throw path.

9. **Explicit zoom controls (Z1)** (`mwendo_map.dart`) — added `_ZoomControls` (`+/−` FABs calling `CameraUpdate.zoomIn()/zoomOut()`) overlaid on both live and replay maps, plus the existing re-center button. `onCameraTrackingDismissed` is now wired for both modes, and `_autoFollow` resets on run restart via `didUpdateWidget`.

10. **Location permission enabled before `start()` (C1)** (`live_dashboard.dart:404`) — `_hasLocationPermission` is set synchronously once all location permissions are granted, so the map's location layer is enabled before the first recording frame requests tracking mode.

11. **Foreground-service failure surfaced, not swallowed (C2)** (`MwendoTrackingService.kt`, `MwendoGpsEnginePlugin.kt`) — `startInForeground()` returns a `Boolean`; `onStartCommand` `stopSelf()`s if it fails (preventing the Android `RemoteServiceException` crash) and the plugin reports `FOREGROUND_FAILED` to Dart. The Dart `MethodChannelMwendoGpsEngine` now logs event-stream errors instead of crashing.

12. **Recovered runs record via the permission-gated path (C3)** (`tracking_controller.dart`) — `restoreInterrupted()` is now **load-only** (loads points/state into `recovering`); the engine + ticker are started by `_start()`/`resume()`, which are only reached through the permission-gated Start flow. This fixes the original "stuck in `recovering`" bug **without** auto-starting GPS from `initState`.

13. **No double start on recover (C4)** (`tracking_controller.dart`) — the `_start()` recover branch starts the engine once (`_engine.startRecording().listen` + `_startTicker`); `resume()` also starts the engine via `_start()` when no subscription exists, so a recovered run never double-subscribes.

14. **Fixed crash regression on run-page open (follow-up to C3)** (`tracking_controller.dart`, `live_dashboard.dart`) — the previous C3 fix made `restoreInterrupted()` start the foreground GPS service from `initState`. Because `mwendo_recovery.json` persists across sessions, this started a foreground service + `requestLocationUpdates` *before location permission was granted* → `SecurityException` crash (and GPS hogging the UI on page open). Reverted to load-only and routed recovery through the permission-gated Start/Resume CTA; a recovered run now shows the primary Start button (`showStart = idle || recovering`).

15. **Map load feedback (perceived slow load)** (`mwendo_map.dart`) — added a `_styleLoaded` flag + `CircularProgressIndicator` overlay shown until the remote Carto style finishes loading, and applied the zoom/recenter overlay to replay maps too. The map still depends on the online style (offline regions remain roadmap), but it no longer looks frozen/blank with no feedback.

16. **Fixed Moving Time stopwatch leak** (`tracking_controller.dart`) — The internal `_movingStart` timer now correctly resets to `null` and commits its delta to `_accumulatedMovingMs` when speed drops below `0.3 m/s` (stops moving). Previously, the clock kept ticking behind the scenes. When the runner resumed, the accumulated idle time was incorrectly added to their moving time, distorting average pace.

### Fixes Applied — Infrastructure & Stability (v0.15 Hotfixes)

17. **Added INTERNET Permission** (`app/android/app/src/main/AndroidManifest.xml`) — After removing the offline map server, MapLibre required internet access to fetch the Carto Dark style JSON. The missing `android.permission.INTERNET` caused an immediate `SecurityException` and native SIGABRT crash when location was granted, followed by black maps on subsequent launches. This is now fixed.
18. **Automated GitHub Release CI** (`.github/workflows/release.yml`) — Added a GitHub Actions workflow using Java 21 to automatically compile `app-debug.apk` and attach it to GitHub Releases whenever a `v*` tag is pushed.

### Fixes Applied — Navigation & Compilation (2026-07-10)

19. **Fixed back navigation from Beat Legends to Learn tab** (`ghost_result_screen.dart`) — Changed `context.go('/beat/$ghostId')` to `context.push('/beat/$ghostId')` for "Rematch" and "Try harder tier" buttons. This preserves the Learn branch navigator's history so the system back button / `AppBackButton` correctly returns to the Learn tab instead of breaking navigation.

20. **Fixed all Dart compilation errors** — Resolved type mismatches between `latlong2.LatLng` and `maplibre_gl.LatLng` across `mwendo_map.dart`, `route_map.dart`, `activity_detail_page.dart`, `beat_legends_page.dart`, `ghost_race_controller.dart`, `ghost_drawer.dart`, `pre_race_sheet.dart`, `ghost_result_screen.dart`. Added conversion helpers and fixed pattern matching in `maybeWhen` with explicit casts. Added missing `appRouterProvider` import and `locale` parameter passing. Bumped version to 1.0.1+2.

---

## 17. Feature Completeness Scorecard (Post-Audit)

| Feature (Blueprint) | UI | Logic | Backend | Data Layer | Score |
|---|---|---|---|---|---|
| GPS Tracking | ✅ | ✅ | n/a | ⚠️ JSON persist | 90% |
| Activity History | ✅ | ✅ | ✅ | ✅ JSON | 85% |
| Challenges + XP | ✅ | ✅ | n/a | ✅ SharedPrefs | 85% |
| Learn Academy | ✅ | ✅ | n/a | ✅ SharedPrefs | 80% |
| Legends | ✅ | ✅ | n/a | ✅ static | 95% |
| Beat the Legends | ✅ | ❌ ghost logic | n/a | ✅ 12 paces + tiers | 60% |
| Safety/SOS | ⚠️ | ❌ disconnected | n/a | ❌ no contacts | 15% |
| Leaderboard | ✅ | ❌ fake data | ✅ Redis | ❌ no API call | 35% |
| Auth | ❌ no UI | ❌ | ✅ bcrypt/JWT | ❌ no client | 25% |
| Offline Maps | ❌ | ❌ | n/a | n/a | 0% |
| FIT Import | ❌ | ❌ | n/a | ❌ stub | 5% |
| i18n EN/SW | ⚠️ partial | ✅ toggle | n/a | ✅ | 50% |
| Profile/Settings | ✅ | ⚠️ decorative | n/a | ⚠️ | 40% |

**Overall Phase 1+2 completion: ~60%** — Moving time and tracking accuracy improvements bumped the score to 60%.

---

## 18. Full Systems Audit — 2026-07-10

A fresh end-to-end read of `app/lib` + `packages/mwendo_gps_engine` (the
previous audit sections above remain valid). Findings and the fixes applied in
this pass:

### Fixes applied (this pass)
- **HR / cadence UI removed.** The native engine never emitted `hr`/`cadence`,
  so the live HR-zone + cadence tiles and the activity-detail cadence stat were
  always `--`. Removed from `live_dashboard.dart` and `activity_detail_page.dart`
  (the dead `dart:math` import went with it). Data-model fields kept.
- **Leaderboard no longer leaks the email.** `leaderboard_provider.dart` mapped
  `user_id` (which is the stored email) straight into the public board name; it
  now prefers a backend `name`/`display_name` and masks any email fallback.
- **`submitRun` sends real moving time.** `session_provider.dart` posted total
  `durationMs` as `moving_time_ms`; it now takes and sends `movingTimeMs`.
- **GPX export round-trips time + speed.** `gpxFromRunRecord` now emits
  `<time>` (from new per-point `RunRecord.times`) and `<speed>` (derived from
  pace); `pointsFromGpx` parses them back. `RunRecord`/`SampleActivity` gained a
  `times` list.
- **Engine moving-time bugs fixed (Kotlin + Swift).** Both engines used a
  `lastLat != 0` sentinel (skips a legitimate (0,0) fix) and summed
  `location.time - lastTime` with no guard (out-of-order fixes / clock jitter /
  paused gaps inflated moving time). Replaced with a `hasLast` flag, a
  `0 < gap < 60s` sanity clamp, and a `lastTime`/`hasLast` reset on `resume()`.
- **Dead `_stopTicker({bool isPaused})` param removed** (never read).
- **Tab swipe no longer fights the map.** `app_router.dart` now skips the
  swipe-to-switch-tab gesture on the Run tab (index 2) so horizontal map pans
  work.
- **`RunRecord` parallel-array desync documented + guarded.** Fields carry a
  `ponytail:` note on the index-alignment invariant; `runRecordFromSession`
  asserts the four arrays stay equal length.

### Current known issues (carried from audit; not yet fixed)
- 🔴 **SOS still sends only the last contact** and **falls back to Nairobi** when
  not actively recording (out of scope this pass — explicitly excluded).
- 🔴 **No GPS outlier / big-jump filter** — a single multipath fix still
  inflates distance/pace (raw points remain the source of truth by design).
- 🟡 `release.yml` builds a **debug** APK (can't ship to Play).
- 🟡 Partial i18n — many hardcoded literals remain (celebration strings, empty
  states, all challenge/legend *content*).
- ⚪ `AppDatabase`/Drift tables are **stubs** by design (JSON-file persistence,
  no migrations) — intentional MVP choice, left as-is.
- ⚪ Thin test coverage on the run/safety math (only `back_navigation_test`).

> **Navigation fixes applied (2026-07-10):**
> - Fixed Legends → Learn back navigation loop: `branchRootFor('/learn/legends/*')` now returns `/learn` instead of `/learn/legends` (itself).
> - Fixed app crash on system back from deep-linked detail pages: `onAppBack` now properly pops branch navigator first via `router.canPop()` before falling back to parent route.
> - Test updated: `branchRootFor('/learn/legends/foo')` expects `/learn`.

 > **GPS Engine & Map Tracking fixes (2026-07-12):**
 > - **Reduced map line jaggedness and improved path accuracy** (`tracking_controller.dart`):
 >   - Raised `_cullMeters` from `5.0` to `10.0` so valid GPS fixes aren't dropped as noise, eliminating unrealistic gaps/gaps that looked like jagged disconnected segments.
 >   - Increased `_alphaForAccuracy` values across the board (e.g. accuracy `≤5 m`: `0.4 → 0.7`, accuracy `≤10 m`: `0.3 → 0.5`, worst-case `≤20 m`: `0.2 → 0.35`). Lower alphas were over-smoothing, causing the polyline to lag and form sharp corners at heading changes; the new values react faster while still suppressing jitter.
 >   - Added `onError` handlers on both `startRecording().listen(...)` subscriptions so native `SecurityException`s or platform stream errors are logged instead of crashing the app.
 > - **Fixed first-launch crash after granting permissions** (`live_dashboard.dart`, `tracking_controller.dart`):
 >   - `TrackingModel.start()` changed from `void` to `Future<void>` so the permission-gated start path can `await` it inside a `try/catch`. Previously, if the GPS engine threw while permissions were still propagating, the error was an unhandled `Future` that killed the process.
 >   - `_requestAndStart` now awaits `start()` and surfaces engine-start failures as a SnackBar (`gps_error_start`), keeping the app alive and showing the user a recoverable error.
 >   - Added localization key `gps_error_start` (EN/SW) for the new error message.
> - **Main App Test Suite Fixes**:
>   - Resolved `UnimplementedError` in `widget_test.dart` and `back_navigation_test.dart` by properly mocking and overriding the required `sharedPreferencesProvider` in `ProviderScope`.
>   - Resolved a bottom RenderFlex layout overflow (16 pixels) in `AppLessonCard` by increasing the lesson carousels container height constraint from `92` to `120` in `learn_page.dart`.
> - **Fit Parser Package Fixes**:
>   - Fixed compilation errors in `mwendo_fit_parser_bindings.dart` by providing the required string symbol names (`'parse_fit_data'`, `'free_string'`) to `DynamicLibrary.lookup()`.
>   - Fixed memory leak and runtime stability in `mwendo_fit_parser.dart` by properly casting the returned `Pointer<Char>` from Rust to `Pointer<Utf8>`, reading it via `toDartString()`, and correctly calling `freeString()` on the native pointer.
>   - Fixed compilation error in `mwendo_fit_parser_test.dart` by removing template references to a non-existent `Calculator` class.
> - **Location Permission & Foreground Service Crash Fixes**:
>   - Wrapped `ContextCompat.startForegroundService` in a try-catch block in `MwendoGpsEnginePlugin.kt` to catch `ForegroundServiceStartNotAllowedException` and forward it back to Dart via `Result.error` instead of crashing.
>   - Added `.catchError` in `mwendo_gps_engine_method_channel.dart` during `startRecording` to prevent uncaught async platform exceptions.
>   - Re-architected permission flow in `live_dashboard.dart` to strictly sequence Foreground Location, Notifications, and Background Location.
>   - Made the Background Location bottom sheet awaitable and added a "Continue without" option. If the user opts to open settings, execution returns immediately so the app can be killed/restarted safely by the OS without crashing mid-run.
>   - Delayed enabling `MapLibre`'s location component (`_hasLocationPermission = true`) until 600ms after permission returns, preventing native `SecurityException`s caused by MapLibre attempting to access location before the Android OS fully flushed the granted permission to the active process.
>   - **Recreate Map Widget on Permission Change**: Assigned a dynamic `ValueKey` to the `MapLibreMap` widget based on `widget.locationEnabled`. This forces the map to destroy and recreate itself when location permission is newly granted, ensuring it initializes with the location component active from the start (which is crash-free) rather than attempting a dynamic toggle that triggers native race conditions and crashes.
>   - **Service Start Fallback**: Implemented standard `startForeground()` fallback in `MwendoTrackingService.kt` inside the `startInForeground` catch block. If fine location tracking fails to start (due to permission sync delays), the service still calls standard `startForeground` without a location type to satisfy Android's 10-second requirement, preventing `RemoteServiceException` crashes.
>   - **Activity Detail Navigation**: Added an `onTap` listener and enabled `useInkWell` in the history list's `_ActivityTile` (inside `activity_list_page.dart`) to enable drilling down into run details.
>   - **Robust Run Saving**:
>     - Made `RunRecord.fromJson` null-safe for optional array fields (`route`, `elevation`, `pace`, `times`) so the app handles legacy/partially corrupted data files cleanly.
>     - Wrapped `submitRun` inside `session_provider.dart` with a generic catch block to ensure any local network or type issues during cloud sync never block the local saving process.
>     - Added a dedicated test suite (`activity_repository_test.dart`) verifying serialization, persistence, deletion, and robust null-safety for older or corrupted data.
>
> All test suites (App, Fit Parser, GPS Engine, and Go Backend) and builds are now verified as **fully passing**.
