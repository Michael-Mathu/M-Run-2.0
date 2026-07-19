# Project Mwendo — Implementation Plan

> **Scope:** This plan covers Phase 1 (Core Activity Tracker, Months 1–4) and Phase 2 (Education, Heritage & Full Motivation, Months 5–8) in work-item-level detail. Phases 3–5 are outlined at milestone level only, as they are gated on success criteria.

---

## Verified Toolchain

| Tool | Version | Status |
|---|---|---|
| Flutter | 3.44.4 (stable, channel stable) | ✅ Confirmed |
| Dart | 3.12.2 | ✅ Confirmed |
| Go | 1.26.4 (windows/amd64) | ✅ Confirmed |
| Rust | 1.94.1 | ✅ Confirmed |
| Cargo | 1.94.1 | ✅ Confirmed |
| Git | 2.53.0 | ✅ Confirmed |

> [!TIP]
> All toolchain prerequisites are installed and ready. No additional setup needed.
>
> **App Version: 1.0.1+2** (tagged `v1.0.1` — includes navigation fix, compilation fixes, LatLng type unification)

---

## User Review Required

> [!IMPORTANT]
> **Monorepo location:** The plan bootstraps the monorepo at `c:\Users\micha\.gemini\antigravity\scratch\RUN\mwendo\`. Confirm this is the desired project root, or specify an alternative.

> [!IMPORTANT]
> **Backend hosting (Phase 1):** The plan uses Go for the backend API. For MVP, a single-binary deploy (fly.io, Railway, or a VPS) is cheapest. Confirm preferred hosting, or if this should be deferred entirely (pure local-first MVP with backend built but only run locally via Docker Compose).

> [!WARNING]
> **Content licensing:** The Legends data (athlete photos, video highlights) requires rights clearance. The plan builds the data model and content pipeline first; actual licensed media is a parallel non-engineering workstream. Placeholder content will be used during development.

> [!IMPORTANT]
> **Sabastian Sawe 1:59:30 London 2026:** This record must be verified against World Athletics ratification before publishing. It is flagged in the data model as `verification_status: PENDING`.

## Open Questions

> [!IMPORTANT]
> 1. **Play Store / TestFlight accounts:** Do you already have Apple Developer ($99/yr) and Google Play Console ($25 one-time) accounts, or should the plan include setting these up?
> 2. **Map tile source:** For offline East Africa tiles, should we use OpenMapTiles, Protomaps, or a custom extract from planet.osm? Each has different size/quality trade-offs.
> 3. **Content authoring:** Do you prefer Git-based Markdown (developer-friendly, version-controlled) or Strapi CMS (non-coder-friendly, web UI) for education content?
> 4. **Swahili translation:** Do you have a translator, or should the plan include i18n infrastructure with English-only at launch and Swahili deferred to Phase 2?

---

## Phase 1 — Core Activity Tracker (Months 1–4)

### Month 1: Foundation (Weeks 1–4)

---

#### 1.1 Monorepo Scaffold

##### [NEW] Repository structure

```
mwendo/
├── app/                          # Flutter application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/                 # Shared utilities, theme, DI
│   │   │   ├── theme/
│   │   │   ├── di/
│   │   │   ├── router/
│   │   │   └── l10n/             # Localisation (arb files)
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── tracking/
│   │   │   ├── activity/
│   │   │   ├── challenges/
│   │   │   ├── education/
│   │   │   ├── legends/          # Phase 2
│   │   │   ├── gamification/     # Phase 2
│   │   │   ├── safety/
│   │   │   └── settings/
│   │   └── data/
│   │       ├── models/
│   │       ├── repositories/
│   │       ├── datasources/
│   │       └── database/         # drift schemas
│   ├── android/
│   ├── ios/
│   ├── test/
│   ├── integration_test/
│   └── pubspec.yaml
├── packages/
│   ├── mwendo_gps_engine/        # Native Flutter plugin (Kotlin/Swift)
│   │   ├── android/src/main/kotlin/
│   │   ├── ios/Classes/
│   │   ├── lib/                  # Dart API surface
│   │   └── pubspec.yaml
│   └── mwendo_fit_parser/        # Dart FFI wrapper around Rust fitparser
│       ├── rust/                 # Rust crate (MIT)
│       ├── lib/                  # Dart FFI bindings
│       └── pubspec.yaml
├── backend/
│   ├── cmd/api/                  # Go main entry point
│   ├── internal/
│   │   ├── auth/
│   │   ├── activity/
│   │   ├── challenge/
│   │   ├── user/
│   │   ├── spatial/
│   │   └── middleware/
│   ├── migrations/               # SQL migrations (golang-migrate)
│   ├── go.mod
│   └── Dockerfile
├── docs/
│   ├── blueprint.md              # → symlink to canonical blueprint
│   ├── CONTRIBUTING.md
│   ├── architecture.md
│   └── content/                  # Education markdown content
│       └── courses/
│           └── how-to-start-running/
├── tools/
│   ├── tile-extract/             # Script to cut MBTiles for East Africa
│   └── legend-data/              # Legend profile YAML/JSON seed data
├── .github/
│   └── workflows/
│       ├── ci-flutter.yml
│       ├── ci-backend.yml
│       └── ci-gps-plugin.yml
├── LICENSE-MIT
├── LICENSE-APACHE
├── LICENSE-AGPL
└── README.md
```

**Key decisions:**
- Feature-first folder structure in the Flutter app (not layer-first) — each feature owns its UI, state, and data layer.
- GPS engine is a separate `packages/` plugin so it can be tested and released independently.
- FIT parser uses Dart FFI → Rust, keeping the Rust crate as a thin dependency.
- Backend is a single Go binary with internal packages — no microservices for MVP.

##### [NEW] CI/CD

- GitHub Actions: lint + test on every PR for Flutter, Go, and the GPS plugin
- GitHub Actions: automated release build (`release.yml`) compiles debug APK and attaches to GitHub Releases on `v*` tag push
- Fastlane (or manual) for Play Store / TestFlight deploys in Phase 1

---

#### 1.2 Local Database Schema (drift / SQLite)

##### [NEW] `app/lib/data/database/`

Core tables:

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│   users      │     │   activities      │     │  trackpoints  │
├─────────────┤     ├──────────────────┤     ├──────────────┤
│ id (UUID)    │────<│ id (UUID)         │────<│ id (int, PK)  │
│ email?       │     │ user_id           │     │ activity_id   │
│ display_name │     │ type (run/walk)   │     │ lat           │
│ created_at   │     │ started_at        │     │ lng           │
│ settings_json│     │ ended_at          │     │ elevation     │
└─────────────┘     │ distance_m        │     │ timestamp     │
                    │ duration_ms       │     │ speed_mps     │
                    │ moving_time_ms    │     │ heart_rate?   │
                    │ elevation_gain_m  │     │ cadence?      │
                    │ elevation_loss_m  │     │ accuracy      │
                    │ avg_pace_spm      │     │ state (idle/  │
                    │ avg_speed_mps     │     │  walk/run)    │
                    │ max_speed_mps     │     └──────────────┘
                    │ calories          │
                    │ gpx_blob?         │     ┌──────────────┐
                    │ status (active/   │     │   laps        │
                    │  paused/complete/ │     ├──────────────┤
                    │  crashed)         │     │ id            │
                    │ recovery_data?    │────<│ activity_id   │
                    └──────────────────┘     │ lap_number    │
                                            │ distance_m    │
┌───────────────┐    ┌───────────────┐      │ duration_ms   │
│ personal_     │    │  challenges   │      │ avg_pace      │
│ records       │    ├───────────────┤      │ avg_hr?       │
├───────────────┤    │ id            │      └──────────────┘
│ id            │    │ slug          │
│ user_id       │    │ title         │      ┌──────────────┐
│ distance_type │    │ description   │      │ emergency_   │
│ (1k/5k/10k/  │    │ type          │      │ contacts     │
│  half/full/   │    │ target_value  │      ├──────────────┤
│  longest)     │    │ target_unit   │      │ id           │
│ time_ms       │    │ xp_reward     │      │ user_id      │
│ activity_id   │    │ badge_slug    │      │ name         │
│ achieved_at   │    └───────────────┘      │ phone        │
└───────────────┘                           │ relationship │
                    ┌───────────────┐       └──────────────┘
                    │ challenge_    │
                    │ progress      │       ┌──────────────┐
                    ├───────────────┤       │ medical_     │
                    │ id            │       │ profile      │
                    │ user_id       │       ├──────────────┤
                    │ challenge_id  │       │ user_id (PK) │
                    │ current_value │       │ blood_type   │
                    │ completed     │       │ allergies    │
                    │ completed_at  │       │ medications  │
                    └───────────────┘       └──────────────┘
```

**Key decisions:**
- `trackpoints` table: raw GPS points with state classification — this is the crash-recovery buffer. Points are written synchronously during recording.
- `activities.status = 'crashed'` — detected on next launch when the previous session wasn't cleanly closed.
- `personal_records` are computed locally on activity save and updated if beaten.
- All timestamps are UTC milliseconds (int64).

---

#### 1.3 Authentication

##### [NEW] `app/lib/features/auth/`
##### [NEW] `backend/internal/auth/`

**MVP auth flow:**
1. Email + password registration (bcrypt hash, server-side)
2. Login returns JWT access token (15 min) + refresh token (30 days, stored in `httpOnly` cookie or secure local storage)
3. Anonymous mode: user can record runs without any account; data is local-only. If they later create an account, local data is associated.
4. No OAuth/OIDC in Phase 1 — deferred to Phase 2 or later based on demand.

**Endpoints:**
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

---

#### 1.4 GPS Engine Plugin

##### [NEW] `packages/mwendo_gps_engine/`

This is the most technically complex component. It is a **native Flutter plugin** — Dart API surface backed by Kotlin (Android) and Swift (iOS) platform code.

**Dart API surface:**

```dart
abstract class MwendoGpsEngine {
  /// Start recording. Returns a stream of [TrackPoint].
  Stream<TrackPoint> startRecording({BatteryProfile profile});

  /// Pause recording (auto-pause or manual).
  Future<void> pause();

  /// Resume recording.
  Future<void> resume();

  /// Stop and finalise the activity.
  Future<RecordingSummary> stop();

  /// Current engine state.
  ValueListenable<EngineState> get state;
  // EngineState: idle | recording | paused | recovering
}
```

**Android implementation (Kotlin):**

1. **Foreground Service** with persistent notification ("Mwendo is recording your run")
2. **FusedLocationProviderClient** with adaptive `LocationRequest`:
   - Idle: `PRIORITY_LOW_POWER`, interval 45s
   - Walk: `PRIORITY_BALANCED_POWER_ACCURACY`, interval 12s
   - Run: `PRIORITY_HIGH_ACCURACY`, interval 5s
3. **State machine** with hysteresis (from Dev Research table):
   - Speed < 0.8 m/s → Idle (requires 15–30 consecutive samples to downgrade)
   - 0.8–5.0 m/s → Walk/Jog (requires 2–5 consecutive samples to upgrade)
   - \> 5.0 m/s → Running (requires 2–5 consecutive samples to upgrade)
4. **Watchdog timer:** if no location update received within 2× the expected interval, force a direct `getCurrentLocation()` pull.
5. **Big-jump filter:** if the distance between consecutive points exceeds `speed × elapsed_time × 3`, discard the point as multipath interference.
6. **Kalman filter** for real-time smoothing (applied before emitting each `TrackPoint`).
7. **Crash recovery:** every `TrackPoint` is written to SQLite via drift immediately. On next `startRecording()` call, check for `activities` with `status = 'crashed'` — offer to recover or discard.
8. **Serial operation queue:** start/stop/pause/resume commands are serialised via a Kotlin `Mutex` to prevent race conditions.

**iOS implementation (Swift):**

1. **CLLocationManager** with `allowsBackgroundLocationUpdates = true`, `pausesLocationUpdatesAutomatically = false`
2. `desiredAccuracy` and `distanceFilter` adjusted per state (same thresholds)
3. Core Location background mode in `Info.plist`
4. Same state machine, watchdog, big-jump filter, Kalman filter logic
5. Crash recovery via the same SQLite path

**Testing strategy:**
- Unit tests for the state machine (pure Dart/Kotlin/Swift — no GPS hardware needed)
- Integration tests with mock location providers on both platforms
- Real-device field test: 5 km route in Nairobi with known distance, verify accuracy within ±2%

---

#### 1.5 Offline Maps

##### [MODIFY] `app/lib/features/tracking/`

**Implementation:**
1. Add `maplibre_gl` Flutter package
2. Custom `MBTilesTileProvider`:
   - Opens MBTiles file via `sqlite3`
   - Queries `SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?`
   - Applies TMS → XYZ Y-axis flip: `tmsRow = (1 << zoom) - 1 - xyzRow`
3. Bundle a small default MBTiles extract for Nairobi + Rift Valley (~50 MB)
4. In-app "Download Region" UI: user selects a bounding box, app downloads MBTiles archive from MinIO/S3
5. JSON style sheet for MapLibre: customised for running (trail visibility, elevation shading, high-contrast mode for accessibility)

**PMTiles (online streaming):**
- For users with connectivity, use PMTiles on MinIO with HTTP Range Requests — no tile server needed
- Seamless fallback: try PMTiles online → fall back to local MBTiles cache

---

### Month 2: Core Recording & Dashboard (Weeks 5–8)

---

#### 1.6 Live Dashboard UI

##### [NEW] `app/lib/features/tracking/ui/`

**Screen: Active Run**

Layout (portrait):
```
┌─────────────────────────────┐
│         MAP (60%)           │
│   [breadcrumb trail]        │
│   [current position dot]    │
│   [km markers]              │
├─────────────────────────────┤
│  Distance    │  Elapsed     │
│  12.4 km     │  1:02:33     │
├──────────────┼──────────────┤
│  Pace        │  Avg Pace    │
│  5:12 /km    │  5:03 /km    │
├──────────────┼──────────────┤
│  Heart Rate  │  Cadence     │
│  156 bpm     │  178 spm     │
├──────────────┼──────────────┤
│  Elevation ↑ │  Calories    │
│  +187 m      │  847 kcal    │
├─────────────────────────────┤
│  [PAUSE]          [LAP]     │
└─────────────────────────────┘
```

- Map auto-centres on current position (toggle to manual pan)
- Swipe up on the metrics panel to expand to full-screen stats
- Metrics panel scrollable for additional data (speed, moving time, elevation loss)
- Lock screen prevents accidental taps
- GPS quality indicator (green/yellow/red dot) in status bar

**Voice announcements:**
- Pre-recorded audio files (English + Swahili) for:
  - "One kilometre", "Two kilometres", ..., "Forty-two kilometres"
  - "New personal best!"
  - "Challenge milestone reached!"
- Triggered on each km split and on PR detection
- User-configurable: on/off, interval (every 1 km, every 5 km)

---

#### 1.7 Activity History & PR Detection

##### [NEW] `app/lib/features/activity/`

**Activity list:** reverse-chronological feed of completed runs, each showing:
- Date, distance, duration, pace, route thumbnail (static map image)

**Activity detail:** full run view with:
- Route on map (replay animation optional)
- Pace/elevation/HR graphs (line charts via `fl_chart`)
- Lap splits table
- GPX/FIT/TCX export buttons

**PR detection algorithm:**
On activity save, scan the trackpoints for the best contiguous segment matching each standard distance (1K, 1 mile, 5K, 10K, half, full marathon). Compare against `personal_records` table. If beaten, update the record and trigger a celebration UI + voice announcement.

**Implementation:**
- Sliding-window scan over trackpoints by cumulative distance
- For each window matching the target distance (±10 m tolerance), compute elapsed time
- O(n) per distance per activity — acceptable for on-device computation

---

#### 1.8 Route Import/Export

##### [NEW] `packages/mwendo_fit_parser/`
##### [MODIFY] `app/lib/features/activity/`

- **GPX:** Parse/generate XML via `xml` Dart package. Standard `<trk>/<trkseg>/<trkpt>` structure.
- **TCX:** Parse/generate XML. Standard `<Activity>/<Lap>/<Track>/<Trackpoint>` structure.
- **FIT:** Rust `fitparser` crate (MIT) compiled to a shared library, accessed via `dart:ffi`. The Rust crate decodes the binary FIT protocol; Dart FFI wrapper exposes a `parseFitFile(Uint8List bytes) → Activity` function.

**Import flow:** user picks file → detect format by extension/magic bytes → parse → create `Activity` + `TrackPoint` records in drift → appear in history.

**Export flow:** user taps export on any activity → select format → generate file → share via system share sheet.

---

### Month 3: Safety, Challenges & Education Intro (Weeks 9–12)

---

#### 1.9 Safety Module

##### [NEW] `app/lib/features/safety/`

**Emergency SOS:**
1. User configures emergency contacts (name, phone number, relationship)
2. During a run, "SOS" button is always accessible (floating, red, on the map screen)
3. One tap → sends SMS with GPS coordinates to all emergency contacts
4. Uses `url_launcher` for SMS; if platform supports it, also initiates a phone call to the primary contact

**Live location sharing:**
1. User opts in before starting a run → generates a shareable link
2. Link opens a web page showing the runner's real-time position on a map
3. Backend: WebSocket endpoint (`/api/v1/live/{session_id}`) broadcasting position updates from the app every 5 seconds
4. Web page: simple HTML/JS with MapLibre GL, connecting to the same WebSocket
5. Auto-expires when the run ends

**Medical profile:**
- Stored locally in drift; optionally synced to backend
- Accessible from the app's lock-screen widget (Android) / iOS widget

**Incident detection (basic — full version in Phase 3):**
- Not in Phase 1 MVP scope; deferred to Phase 3 for the accelerometer fusion
- Phase 1 includes the SOS button and live sharing only

---

#### 1.10 Starter Challenges

##### [NEW] `app/lib/features/challenges/`

Three starter challenges, hardcoded in the app (no backend dependency):

| Challenge | Condition | XP | Badge |
|---|---|---|---|
| First Run | Complete any activity ≥ 0.5 km | 50 | 🏃 "First Steps" |
| First 5K | Complete a single activity ≥ 5.0 km | 200 | 🎯 "5K Finisher" |
| 7-Day Streak | Record an activity on 7 consecutive days | 500 | 🔥 "Week Warrior" |

**Implementation:**
- `ChallengeEvaluator` service runs after each activity save
- Checks each challenge's condition against `activities` and `challenge_progress` tables
- On completion: update `challenge_progress.completed = true`, show celebration dialog, award XP badge

---

#### 1.11 Education Module: "How to Start Running"

##### [NEW] `docs/content/courses/how-to-start-running/`
##### [NEW] `app/lib/features/education/`

**Content (Markdown → bundled as app asset):**

```
how-to-start-running/
├── meta.yaml           # title, description, order, badge_slug
├── 01-why-run.md
├── 02-gear-you-need.md
├── 03-walk-run-method.md
├── 04-warming-up.md
├── 05-breathing.md
├── 06-your-first-5k-plan.md  # manual plan, not AI-generated
├── 07-staying-motivated.md
├── quiz.yaml           # 10 multiple-choice questions
└── assets/
    └── images/
```

**App UI:**
- Course overview screen with progress bar
- Individual lesson screen: rendered Markdown with images
- Quiz screen at the end; passing unlocks "Scholar" badge
- All content bundled in the APK/IPA for offline access

---

### Month 4: Polish, Testing & Beta Launch (Weeks 13–16)

---

#### 1.12 Backend API (Go)

##### [NEW] `backend/`

**Endpoints for Phase 1:**

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/v1/auth/register` | Create account |
| POST | `/api/v1/auth/login` | Login, return JWT |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| POST | `/api/v1/activities` | Sync an activity to cloud |
| GET | `/api/v1/activities` | List user's activities |
| GET | `/api/v1/activities/:id` | Get activity detail |
| GET | `/api/v1/profile` | Get user profile |
| PUT | `/api/v1/profile` | Update profile |
| WS | `/api/v1/live/:session` | WebSocket for live location sharing |

**Architecture:**
- Single binary, `net/http` + `chi` router (zero-dependency router)
- PostgreSQL via `pgx` (connection pool)
- PostGIS for spatial storage
- Redis for live session pub/sub and leaderboard caches
- `golang-migrate` for schema migrations
- Structured logging via `slog`
- Docker Compose for local dev: Go API + PostgreSQL + PostGIS + Redis + MinIO

**PostGIS schema (server-side):**

```sql
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    distance_m DOUBLE PRECISION,
    duration_ms BIGINT,
    moving_time_ms BIGINT,
    elevation_gain_m DOUBLE PRECISION,
    -- ... (mirrors client schema)
    track GEOGRAPHY(LINESTRINGM, 4326),  -- spheroidal, M = unix timestamp
    simplified_track GEOGRAPHY(LINESTRINGM, 4326),  -- Douglas-Peucker reduced
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_activities_user ON activities(user_id);
CREATE INDEX idx_activities_track ON activities USING GIST(track);
```

---

#### 1.13 Cloud Sync (Offline-First)

**Strategy:**
1. App works fully offline. All data is in local SQLite (drift).
2. When the user has an account AND connectivity, activities sync to the backend.
3. Sync is **push-only** in Phase 1: app → server. No server → app sync (no multi-device yet).
4. Each activity has a `sync_status` field: `local | syncing | synced | failed`.
5. Background sync via a periodic Dart isolate (every 15 minutes when connected).
6. Conflict resolution: last-write-wins (acceptable for Phase 1 single-device model).

---

#### 1.14 Testing & Quality

**Automated:**
- Unit tests: GPS state machine, PR detection algorithm, challenge evaluator, auth token handling
- Widget tests: key UI screens (dashboard, activity detail, challenge list)
- Integration tests: full recording flow with mock GPS provider
- Backend: Go table tests for all endpoints
- CI: all tests run on every PR

**Manual:**
- Field test protocol: 5 km known route, 3 devices (low-end Android, mid-range Android, iPhone), verify distance accuracy ±2%, battery usage < 5% per hour
- Accessibility audit: TalkBack (Android) + VoiceOver (iOS) on all screens
- Offline test: airplane mode for entire recording + education + challenge flow

---

#### 1.15 Beta Launch

- Android: Play Store internal/open testing track
- iOS: TestFlight
- Landing page: simple static site (GitHub Pages) with app links, Discord invite, GitHub repo link
- First open-source release on GitHub with MIT/Apache 2.0 + AGPLv3 licences
- CONTRIBUTING.md, CODE_OF_CONDUCT.md, issue templates

---

## Phase 2 — Education, Heritage & Full Motivation (Months 5–8)

> **Trigger:** Phase 1 success gates met (3,000 MAU, median 8 runs/user/month over 90 days).

### Month 5–6: Content Platform & Legends

---

#### 2.1 Education Content Platform

##### [MODIFY] `app/lib/features/education/`
##### [NEW] `docs/content/courses/`

**Courses to author:**

| Course | Lessons | Badge |
|---|---|---|
| How to Start Running | 7 (already done) | Scholar |
| Running Science 101 | 10 (HR zones, VO₂ max, lactate threshold, energy systems) | Scientist |
| Technique Masterclass | 8 (posture, cadence, foot strike, breathing, drills) | Technician |
| Training Types | 6 (long run, tempo, intervals, hills, recovery, fartlek) | Coach's Eye |
| Health & Recovery | 8 (warm-up, stretching, strength, nutrition, injury awareness) | Medic |
| Children & Youth | 6 | Rising Star |
| Women in Running | 5 | Trailblazer |
| Kenyan Running Heritage | 12 (pre-colonial → modern era, camps, culture, diet, economics) | Heritage Keeper |

**Offline content packs:** each course is a downloadable ZIP containing Markdown + images, stored in app-specific storage. In-app download manager with progress indicator.

**Knowledge streak:** consecutive days of completing at least one lesson → streak counter → XP bonus.

---

#### 2.2 East African Legends (20 Initial Profiles)

##### [NEW] `app/lib/features/legends/`
##### [NEW] `tools/legend-data/`

**Data model (YAML seed files → SQLite):**

```yaml
- id: kipchoge-eliud
  name: Eliud Kipchoge
  country: KE
  birth_year: 1984
  distances: [marathon, 5000m]
  records:
    - distance: marathon
      time_ms: 7269000  # 2:01:09
      venue: Berlin
      year: 2022
      verification_status: RATIFIED
  biography_md: legends/kipchoge-eliud/bio.md
  career_timeline:
    - year: 2003
      event: "5000m World Championship gold"
    - year: 2018
      event: "Marathon WR 2:01:39, Berlin"
    # ...
  quotes:
    - "No human is limited."
    - "Only the disciplined ones in life are free."
  challenge_paces:
    - distance: marathon
      split_times_ms: [172000, 173000, ...]  # per-km splits
  image_credits: "Photo © ..."
```

**Initial 20 legends (10 male, 10 female):**

*Male:* Kipchoge Keino, Paul Tergat, Haile Gebrselassie, Eliud Kipchoge, Kelvin Kiptum, Kenenisa Bekele, David Rudisha, Daniel Komen, Moses Kiptanui, Sabastian Sawe

*Female:* Faith Kipyegon, Tegla Loroupe, Brigid Kosgei, Ruth Chepngetich, Beatrice Chebet, Tigist Assefa, Vivian Cheruiyot, Catherine Ndereba, Pamela Jelimo, Hellen Obiri

**UI:**
- Legends grid/list with search and filter (by country, distance, era)
- Legend detail page: bio, timeline, records, quotes, gallery
- "Challenge Me" button → navigate to Beat the Legends flow

> **Implemented scope:** the shipped build expanded this to **30 legends** (Step 2 added 10 more —
> Tirunesh Dibaba, Meseret Defar, Sifan Hassan, Catherine Ndereba, Edna Kiplagat, Moses Tanui,
> Ibrahim Hussein, Abel Mutai, Ezekiel Kemboi, plus the existing 20) with new fields (personal
> bests, training philosophy, rivalries, notable races, categorized quotes, fun facts, related
> legends), country/discipline/era filter chips, a "How You Compare" panel, and a
> "Legend of the Day/Week" home card.

---

#### 2.3 Beat the Legends (5 Initial Ghost Paces)

##### [NEW] `app/lib/features/tracking/beat_the_legends/`

**Initial ghost-runner challenges:**

| Legend | Distance | Target Time | Difficulty |
|---|---|---|---|
| Eliud Kipchoge | Marathon (first 5K split) | ~14:20 | 🔥🔥🔥🔥🔥 |
| Faith Kipyegon | 1500m | 3:48.68 | 🔥🔥🔥🔥🔥 |
| Paul Tergat | 10K | 26:27.85 | 🔥🔥🔥🔥🔥 |
| Tegla Loroupe | 5K (from marathon pace) | ~16:40 | 🔥🔥🔥 |
| David Rudisha | 800m | 1:40.91 | 🔥🔥🔥🔥🔥 |

**Implementation:**
- Legend's split times stored as an array of per-100m or per-km timestamps
- During recording, app interpolates the ghost's position at the current elapsed time
- Map shows ghost runner as a second marker (different colour/icon)
- Dashboard shows: "You are X metres ahead/behind [Legend] at this point"
- On completion: compare total time, show result, award badge if applicable
- Progressive unlock: complete Tier 1 legends (easier paces) to unlock Tier 2

> **Implemented scope:** the shipped build now has **12 ghost paces** with a **Bronze / Silver /
> Gold / G.O.A.T.** tier system — each pace is scaled to 125% / 110% / 102% / 100% of the record
> time, and the header, splits chart, description, and race target rescale live with the selected
> tier. (The in-run ghost marker and real-time comparison from the plan are not yet built.)

### Month 6–7: Full Challenges & Gamification

---

#### 2.4 Full Challenge Library

##### [MODIFY] `app/lib/features/challenges/`

Expand from 3 starter challenges to ~50:

**Categories:**
- **Starter** (5): First Run, First 5K, First 10K, 3-Day Streak, 7-Day Streak
- **Distance milestones** (8): 50 km total, 100 km, 250 km, 500 km, 1000 km, 2500 km, 5000 km, 10000 km
- **Performance** (8): Sub-30 5K, Sub-25 5K, Sub-60 10K, Sub-50 10K, Sub-2:00 HM, Sub-1:45 HM, Sub-4:00 Marathon, Sub-3:30 Marathon
- **Consistency** (6): 30-Day Streak, 90-Day Streak, 365-Day Streak, 4 runs/week for a month, morning runner (10 runs before 7am), night owl (10 runs after 8pm)
- **Fun & seasonal** (10): Sunrise Challenge, Hill Repeat Challenge, Rift Valley Altitude, Rainy Season Streak, Run Every Day in January, Valentine's Day 14K, Independence Day 10K, Full Moon Run, etc.
- **Education** (5): Complete 3 courses, Complete all courses, 7-day knowledge streak, Pass all quizzes, Heritage Keeper (complete Kenyan heritage course)
- **Beat the Legends** (5): see 2.3
- **Community-voted** (3): seeded from Discord polls

All challenges define: slug, title, description, condition (JSON), xp_reward, badge_slug, medal_slug (optional), category, difficulty_tier.

---

#### 2.5 Gamification System

##### [NEW] `app/lib/features/gamification/`

**XP sources:**

| Action | XP |
|---|---|
| Per km run | 10 |
| Complete an activity | 25 |
| New personal record | 100 |
| Complete a challenge | varies (50–1000) |
| Complete a lesson | 15 |
| Pass a quiz | 50 |
| Daily streak day | 5 × streak_length |

**Levelling:**
- Level 1–100, exponential curve: `xp_for_level(n) = 100 * n^1.5`
- Level 1: 100 XP. Level 10: ~3,162 XP. Level 50: ~35,355 XP. Level 100: ~100,000 XP.
- Each level unlocks profile customisation options (avatar frames, title slots)

**Badges:**
- ~100 at launch, expanding over time
- Categories: distance, speed, consistency, education, legends, hidden/easter-egg
- Each badge has: slug, name, description, icon, rarity (common/rare/epic/legendary)

**Streaks:**
- Run streak: consecutive days with ≥1 activity
- Knowledge streak: consecutive days with ≥1 lesson completed
- One free "streak freeze" per 30-day period (prevents negative psychology per Octalysis CD8 guidance)

**Leaderboards:**
- Opt-in only
- Filters: weekly/monthly/all-time × distance/XP × global/country/club
- Redis sorted sets for real-time ranking
- Anonymised display names for privacy

**Titles:**
- Earnable monikers displayed on profile: "Mountain Goat" (1000m+ elevation gain in one run), "Historian" (complete heritage course), "5K Master" (sub-20 5K), "Legend Chaser" (complete any Beat the Legends challenge)

---

### Month 7–8: Swahili, Polish & Full Release

---

#### 2.6 Swahili Localisation

##### [MODIFY] `app/lib/core/l10n/`

- Flutter's `intl` package with ARB files
- `app_en.arb` (English) — primary
- `app_sw.arb` (Swahili) — translated
- All education content authored in both languages (separate Markdown files per locale)
- Voice announcements recorded in both languages
- In-app language switcher in settings

##### [NEXT TASK] Close localization gaps from the 2026-07-12 audit

> Full findings: [`docs/localization_audit.md`](./localization_audit.md). The shipped build uses a
> custom `L10n.tr()` catalog (`app/lib/core/l10n/app_strings.dart`, en/sw) instead of ARB files.
> Coverage is ~50–60% by UI surface and lower by content volume. Because `L10n.tr` returns the raw
> key when a key is missing, missing keys are **visible bugs**, not silent fallbacks.

Work items, in priority order:

- [x] **P0 — Add the ~62 missing `tr()` keys** (Category 1) — ✅ DONE 2026-07-12: all ~62 keys added to `app/lib/core/l10n/app_strings.dart` with `en`+`sw`.
  Largest clusters: Beat-the-Legends flow (33 keys), `legend_detail_page.dart` (15), onboarding
  slide hints + 4th slide (6), plus `per_km`, `lv`, `all_courses`, `read_more`,
  `leaderboard_badge_goat`, `lesson`/`lesson_complete_xp`, `unknown`, `ready_to_race`.
- ~~**P1 — Content layer (prose):**~~ **✅ DONE 2026-07-12 Evening:** Introduced `LocalizedText` record + `lt()` resolver in `app_strings.dart`. Applied to `legends.dart` (all prose fields: bio, trainingPhilosophy, timeline, records, quotes, notableRaces, funFact, era labels, quote category labels) and `courses.dart` (titles, subtitles, authors, lesson titles/summaries/paragraphs, category labels). Updated renderers: `learn_page.dart`, `legend_detail_page.dart`, `legends_page.dart`, `course_detail_page.dart`, `lesson_page.dart`, `dashboard_page.dart`, `activity_detail_page.dart`. Remaining content gaps: `beat_legends.dart`, challenge evaluator/ranks, milestone stories.
- [ ] **P0 — Localize safety/auth strings:** SOS SMS body (`safety_service.dart:7`, parameterize
  the location URL) and the three auth error messages (`session_provider.dart:60,118,119`).
- [ ] **P1 — Wire existing-but-bypassed keys:** `you`, `runner`, `stop_run`, `pause_run`/`resume_run`,
  `gps_required_body`, `you_beat_ghost`. Fix theme-key mismatches
  (`theme_kinetic_orange`→`theme_orange`, etc.) and add `edit`/`share`/`learning_insight`/
  `activity_not_found`(+body). Fix the Explore nav tab mislabelled as `run`
  (`app_router.dart:335`, add an `explore` key).
- [ ] **P1 — Wrap remaining hardcoded UI literals** (Category 2): shared `xp`, `day streak`,
  `Re-center map`/`Zoom` semantics, learn category headers, legends filter values, challenge
  tier badges, share message. Fully localize `route_detail_page.dart` and fix its broken
  escaped `\$slug` interpolation.
- [ ] **P2 — Enable Flutter framework localization:** add `flutter_localizations` to `pubspec.yaml`,
  register `GlobalMaterialLocalizations`/`GlobalWidgetsLocalizations`/`GlobalCupertinoLocalizations`
  delegates + `supportedLocales: [en, sw]` in `app.dart`, and bind `locale:` to `localeProvider`.
  (Consider migrating the custom catalog to ARB per the section above at this point.)
- [ ] **P2 — Content-localization layer** (Category 3, remaining): per-locale storage for
  `beat_legends.dart` (ghost names/descriptions, tier labels), challenge evaluator (19 challenges
  × title/description/badge), rank titles (8), milestone stories (8), explore sample data,
  activity types (~3 strings).
- [ ] **P3 — Polish:** pluralization helper for Swahili noun classes (`lessons`/`runs`/`days`);
  decide unit-token strategy (`km`/`mi`/`min`/`bpm`/`XP`) and brand/code literals (`Mwendo`,
  `EN`/`SW`); fix the first-frame English flash in `LocaleNotifier.build()`.

---

#### 2.7 Template-Based Milestone Stories

##### [NEW] `app/lib/features/gamification/milestone_stories.dart`

Simple, offline, template-based celebrations — no AI generation.

```
"🎉 [Name] just crushed their first 10K! That's [distance] km of pure determination. 
In the spirit of the great Kipchoge Keino, every journey begins with a single step. 
Keep running, keep growing. 🏃‍♂️"
```

- ~30 templates, randomised per milestone type
- Variables: `{name}`, `{distance}`, `{time}`, `{legend_name}`, `{legend_quote}`
- Shareable as an image card (generated client-side with `RenderRepaintBoundary`)

---

#### 2.8 Phase 2 Backend Additions

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/v1/legends` | List legends |
| GET | `/api/v1/legends/:id` | Legend detail + split times |
| GET | `/api/v1/challenges` | List challenges (server-side for community-voted ones) |
| GET | `/api/v1/leaderboards/:type` | Leaderboard data |
| POST | `/api/v1/gamification/sync` | Sync XP, badges, streaks from client |

---

## Phases 3–5 (Milestones Only)

### Phase 3 — Community & Organisational Tools (Conditional, ~Months 9–12)
- Schools Mode: teacher/student roles, join codes, attendance, house competitions, parental consent
- Coach Portal: separate web app (Go + HTMX or Next.js), athlete management, manual workout assignment
- Inter-school leaderboards
- Incident detection (accelerometer + GPS fusion, countdown alert)

### Phase 4 — Wearable Ecosystem (Conditional, ~Months 13–16)
- Deploy Open Wearables (or fork) — OAuth ingestion from Garmin, Strava, Apple Health, etc.
- BLE HR strap + foot pod integration via `flutter_blue_plus`
- RSC measurement parsing (0x1814 / 0x2A53) for independent pace verification in GPS-degraded environments

### Phase 5 — Continuous Enrichment (Ongoing)
- Legend library expansion via community YAML contributions
- Additional languages (Kalenjin, Amharic, Kiswahili dialects)
- Community mapathons for offline tile coverage
- Low-end device performance hardening
- Accessibility improvements

---

## Verification Plan

### Automated Tests
```bash
# Flutter app
cd app && flutter test
cd app && flutter test integration_test/

# GPS plugin
cd packages/mwendo_gps_engine && flutter test

# FIT parser
cd packages/mwendo_fit_parser/rust && cargo test
cd packages/mwendo_fit_parser && flutter test

# Backend
cd backend && go test ./...
```

### Manual Verification
- Field test: 5 km known route on 3 devices, verify ±2% distance accuracy
- Offline test: airplane mode for full recording + education + challenge flow
- Accessibility: TalkBack + VoiceOver on all screens
- Battery: < 5% per hour of recording on mid-range device
- Crash recovery: force-kill app during recording, verify recovery on relaunch
- Swahili: native speaker review of all UI strings and education content

### Beta Launch Checklist
- [ ] Play Store internal testing track published
- [ ] TestFlight build distributed
- [ ] GitHub repo public with licences, README, CONTRIBUTING.md
- [ ] Discord server created with #general, #bugs, #feature-requests channels
- [ ] Landing page live

---

## Dependency Summary (Flutter packages)

| Package | Purpose | Licence |
|---|---|---|
| `drift` + `sqlite3_flutter_libs` | Local database | MIT |
| `maplibre_gl` | Maps | BSD |
| `fl_chart` | Graphs | MIT |
| `flutter_blue_plus` | BLE sensors (Phase 4) | BSD |
| `go_router` | Navigation | BSD |
| `riverpod` | State management | MIT |
| `dio` | HTTP client | MIT |
| `web_socket_channel` | WebSocket for live sharing | BSD |
| `flutter_local_notifications` | Foreground service notification | BSD |
| `url_launcher` | SMS/phone for SOS | BSD |
| `share_plus` | System share sheet for exports | BSD |
| `flutter_localizations` + `intl` | i18n | BSD |
| `xml` | GPX/TCX parsing | MIT |
| `path_provider` | File system paths | BSD |

No AI/ML packages. No commercial SDK dependencies.

---

## Changelog

### v1.0.2 (2026-07-12) — Tag: `v1.0.2`
- **Localization — prose layer:** Introduced `LocalizedText` (`({String en, String sw})`) + `lt()` resolver in `app/lib/core/l10n/app_strings.dart`. Migrated `features/learn/data/legends.dart` (all prose fields) and `features/learn/data/courses.dart` (titles, subtitles, lessons, categories) to bilingual en/sw pairs. Updated all renderers to resolve through `lt()` based on current `locale`.
- **Localization — missing keys:** Added the ~62 missing `L10n.tr()` keys (P0 fix from 2026-07-12 audit) covering onboarding hints, live HUD labels (`km`/`per_km`/`lv`), Learn/Legends/Explore pages, and the Beat-the-Legends cluster (33 keys).
- **Build fixes:** Resolved type errors in `activity_detail_page.dart`, `dashboard_page.dart`, `learn_page.dart`, and `legend_detail_page.dart` triggered by the `LocalizedText` migration.
- **Release APK:** Successfully rebuilt `app-release.apk` (89.6 MB).
- **Version bump:** 1.0.1+2 → 1.0.2+1

### v1.0.1 (2026-07-10) — Tag: `v1.0.1`
- **Fix: Navigation back stack** — Changed `context.go` to `context.push` in `ghost_result_screen.dart` for "Rematch" and "Try harder tier" buttons. This preserves the Learn branch navigator history so back navigation correctly returns to Legends/Learn pages.
- **Fix: Dart compilation errors** — Resolved all type mismatches across 12 files:
  - LatLng type unification between `latlong2` and `maplibre_gl` (conversion helpers in `mwendo_map.dart`, updated `route_map.dart`, `activity_detail_page.dart`)
  - GhostRaceController pattern matching with explicit casts in `maybeWhen`
  - GhostDrawer `maybeWhen` null-safety wrapper
  - PreRaceSheet added missing `appRouterProvider` import, passed `locale` to `_SplitTable`, fixed return type
  - BeatLegendsPage removed duplicate/stray code, added `RunRecord` import
- **Version bump:** 1.0.0+1 → 1.0.1+2

### v1.0.0 (2026-07-09) — Initial working build
- Core tracking, challenges, learn, legends, beat-the-legends UI complete
- GPS engine plugin (Android) functional
- Offline-first JSON persistence
- MapLibre integration with Carto dark style
