# Mwendo (M-Run 2.0) Technical Architecture & Production Documentation

---

## 1. Project Overview

### 1.1 Executive Summary
**Mwendo** (*Swahili for "Speed", "Motion", or "Movement"*) is an enterprise-grade, offline-first GPS running tracking ecosystem, geospatial processing engine, and training intelligence platform. Designed to honor East African distance running heritage while meeting top-tier sports engineering standards, Mwendo combines low-latency sensor telemetry, state-space mathematical filtering, on-device SQLite persistence, dynamic ghost racing against world records, and a high-performance Go/PostGIS cloud backend.

```
       ┌────────────────────────────────────────────────────────┐
       │                Mwendo System Architecture              │
       └───────────────────────────┬────────────────────────────┘
                                   │
       ┌───────────────────────────┼────────────────────────────┐
       ▼                           ▼                            ▼
┌──────────────┐          ┌───────────────────┐       ┌───────────────────┐
│ Flutter App  │ ◄──────► │ Pure Dart Engine  │       │    Go Backend     │
│  (Client)    │          │  (gps_pipeline)   │       │ (PostGIS + Redis) │
└──────┬───────┘          └───────────────────┘       └─────────┬─────────┘
       │                                                        │
       ├───────────────────────────┬────────────────────────────┤
       ▼                           ▼                            ▼
┌──────────────┐          ┌───────────────────┐       ┌───────────────────┐
│ Platform GPS │          │  Rust FFI Engine  │       │ Docker Ecosystem  │
│(Android/iOS) │          │(mwendo_fit_parser)│       │(Compose Services) │
└──────────────┘          └───────────────────┘       └───────────────────┘
```

### 1.2 Core Purpose & Objectives
* **Eliminate Telemetry Drift & "Ghost Traces"**: Standard GPS engines suffer from multipath interference, urban canyons, and stationary position wandering. Mwendo implements a multi-stage deterministic pipeline (Quality Gate, Outlier Lookahead, Local ENU 2D Kalman Filter, Stationary Clustering, and Post-Session OSRM Map Matching) that produces smooth tracks while maintaining raw measurement provenance.
* **Offline-First Resilience**: Full autonomous operation without network connectivity. Workouts are recorded into local SQLite storage via Drift and protected against OS task kills or battery death through a serial disk-recovery snapshot journal (`mwendo_recovery.json`).
* **"Beat Legends" Pacing Engine**: Runners can race in real-time against mathematical models of iconic world-record performances (Eliud Kipchoge, Kelvin Kiptum, Faith Kipyegon, Kenenisa Bekele, etc.) dynamically scaled across difficulty tiers (*Bronze, Silver, Gold, G.O.A.T.*).
* **High-Throughput Geospatial Cloud Backend**: A lightweight Go service featuring PostGIS `GEOGRAPHY(LineString, 4326)` geospatial indexing, Douglas-Peucker route simplification (`ST_Simplify`), and Redis Sorted Set weekly leaderboards with graceful in-memory fallbacks.

### 1.3 Key Value Propositions
| Feature Dimension | Legacy Running Apps | Mwendo Architecture |
| :--- | :--- | :--- |
| **GPS Processing** | Raw averaging or basic thresholding | Multi-stage pipeline with 2D ENU Kalman Filter and 3-point lookahead spike suppression |
| **Stationary Drift** | Accumulates false distance while standing still | Density-weighted stationary centroid clustering |
| **Crash Protection** | Run lost if OS kills background activity | Serial recovery journal with auto-restore on restart |
| **Map Rendering** | Generic vector tiles with online dependencies | Local MapLibre GL dark Carto basemap with dynamic ghost overlay |
| **Virtual Pacing** | Static target split pace | Segment-by-segment spline interpolation against historical splits |
| **Cloud Dependency**| Mandatory account lock-in for saving data | 100% offline-first local SQLite with selective cloud sync |

---

## 2. Architecture & Design

### 2.1 Monorepo & Modular Boundaries
The project is structured as a decoupled monorepo containing the Flutter client application, reusable pure Dart domain packages, hardware platform channel plugins, native Rust FFI modules, and the Go cloud API.

```
M-Run-2.0/
├── app/                        # Main Flutter Client Application
│   ├── lib/
│   │   ├── core/               # Gamification, l10n, theme, permissions, safety
│   │   ├── data/               # Drift SQLite database, models, repositories, GPX
│   │   ├── design_system/      # Atomic UI components, cards, banners, HUDs
│   │   ├── features/           # Feature slices: tracking, beat, learn, explore, etc.
│   │   └── widgets/            # MapLibre map wrappers, metrics tiles, overlays
│   └── test/                   # Widget and repository integration tests
├── packages/
│   ├── gps_pipeline/           # Pure Dart GPS filter, Kalman math, quality analysis
│   ├── mwendo_gps_engine/      # Federated platform plugin (Android Foreground / iOS)
│   └── mwendo_fit_parser/      # Rust FFI bridge for binary Garmin FIT file parsing
├── backend/                    # Go Cloud Service
│   ├── cmd/api/                # HTTP server bootstrap and routing
│   └── internal/
│       ├── activity/           # PostGIS activity store & Douglas-Peucker simplification
│       ├── auth/               # JWT authentication & password hashing
│       ├── config/             # Environment configuration parser
│       ├── db/                 # SQL database migrations & connection manager
│       └── leaderboard/        # Redis ZSET weekly rankings with memory fallback
├── app-rn/                     # React Native Schema & Type Parity Definitions
├── docker-compose.yml          # PostGIS 16 + Redis 7 + Go API orchestration
└── Makefile                    # Unified build, test, and execution tasks
```

---

### 2.2 Domain Layer Interactions & Data Flow

#### Live Tracking & Mathematical Filtering Flow
```
┌──────────────────────────────┐
│  Hardware GNSS / Location    │
└──────────────┬───────────────┘
               │ (Raw NMEA / Location Events)
               ▼
┌──────────────────────────────┐
│   MwendoTrackingService.kt   │ (Android Foreground Service / iOS CLLocationManager)
│   (mwendo_gps_engine)        │
└──────────────┬───────────────┘
               │ (Stream<TrackPoint> via MethodChannel)
               ▼
┌──────────────────────────────┐
│      TrackingModel           │ (flutter_riverpod Notifier)
│  (app/lib/features/tracking) │
└──────┬───────────────┬───────┘
       │               │
       │ (RawFix)      │ (Async batch snapshot)
       ▼               ▼
┌──────────────┐ ┌──────────────────────┐
│ GpsPipeline  │ │ mwendo_recovery.json │ (Crash-Proof Disk Journal)
└──────┬───────┘ └──────────────────────┘
       │
       ├─► 1. FixValidator: Coordinate range, monotonic timestamp, mock check
       ├─► 2. QualityGate: Accuracy threshold (<=30m run, <=75m cycle)
       ├─► 3. OutlierDetector: Implied velocity & 3-point lookahead spike rejection
       ├─► 4. KalmanFilter: 2D State-Space (East/North/Velocities) in ENU Frame
       ├─► 5. StationarySuppressor: Density-weighted centroid aggregation
       ├─► 6. GapDetector: Signal loss demarcation (gapShort / gapLong)
       └─► 7. MapMatcher: Post-session OSRM Hidden Markov Map Matching
               │
               ▼ (PipelineResult: FilterStatus.filtered / stationary)
┌──────────────────────────────┐
│    DisplaySegment Polyline   │ ──► [MapLibre GL Screen Canvas]
└──────────────────────────────┘
```

---

### 2.3 Core Architectural Design Patterns

#### 1. Decoupled Polyline Display vs. Provenance Architecture
Raw GPS fixes (`RawFix`) remain the immutable source of truth for disk persistence, GPX exporting, distance aggregation, and SOS safety dispatch. The UI polyline is rendered exclusively through smoothed `DisplaySegment` structures generated by the `GpsPipeline`, preventing map rendering noise from corrupting analytical metrics.

#### 2. Serial Command Queue Locking
To prevent race conditions during rapid pause/resume/stop button presses, `TrackingModel` implements an asynchronous queue via `_enqueue(Future<void> Function() op)`:
```dart
Future<void> _enqueue(Future<void> Function() op) {
  final prev = _lock;
  final completer = Completer<void>();
  _lock = completer.future;
  (prev ?? Future.value()).then((_) async {
    try {
      await op();
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
    }
  });
  return completer.future;
}
```

#### 3. State-Space 2D ENU Kalman Filter
Latitude and Longitude are projected into a tangent Euclidean plane (East-North-Up in metres) relative to an origin point using flat-earth trigonometric approximations. The state vector $x = [e, n, v_e, v_n]^T$ is updated dynamically:
$$\hat{x}_{k|k-1} = F \hat{x}_{k-1|k-1}$$
$$P_{k|k-1} = F P_{k-1|k-1} F^T + Q$$
Adaptive process noise $Q$ scales dynamically depending on whether the runner's speed exceeds $0.3\text{ m/s}$. Measurements exceeding the Mahalanobis innovation threshold ($d^2 > 25.0$, $\sim 5\sigma$) are rejected to stop multipath jumps.

#### 4. Sealed Class Hierarchies for Reactive State
Ghost racing telemetry utilizes Dart 3 sealed class models (`GhostRaceStateData`), guaranteeing exhaustive pattern matching in the UI without unhandled edge states:
```dart
sealed class GhostRaceStateData {
  const GhostRaceStateData();
  static GhostRaceStateData idle() => const GhostRaceIdleData();
  static GhostRaceStateData armed(GhostPace ghost, DifficultyTier tier) =>
      GhostRaceArmedData(ghost, tier);
  static GhostRaceStateData racing(GhostPace ghost, DifficultyTier tier) =>
      GhostRaceRacingData(ghost: ghost, tier: tier);
  static GhostRaceStateData finished(...) => GhostRaceFinishedData(...);
}
```

---

## 3. Installation & Setup

### 3.1 Prerequisite Software & System Matrix

| Component | Minimum Version | Recommended | Purpose |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.22.0` | `3.24.x` (Channel Stable) | Cross-platform UI & Engine |
| **Dart SDK** | `3.12.2` | `3.12.x` | Language Runtime |
| **Go SDK** | `1.22.0` | `1.22.5` | Cloud API Services |
| **Rust & Cargo** | `1.75.0` | `1.80+` | Native FIT Binary Parser C-ABI |
| **Docker & Compose** | `24.0.0` | `27.x` | PostGIS & Redis containerization |
| **Android SDK / NDK** | API 34 (Android 14) | NDK 26.x | Android compilation & background service |
| **Xcode** | `15.0` | `15.4+` | iOS CoreLocation integration |

---

### 3.2 Step-by-Step Environment Initialization

#### Step 1: Clone the Repository
```bash
git clone https://github.com/Michael-Mathu/M-Run-2.0.git
cd M-Run-2.0
```

#### Step 2: Bootstrap Dependencies Across All Sub-Projects
Run the automated Makefile target to install dependencies across the client and all internal packages:
```bash
make setup-app
```
*Equivalent manual commands:*
```bash
cd app && flutter pub get
cd ../packages/mwendo_gps_engine && flutter pub get
cd ../packages/mwendo_fit_parser && flutter pub get
cd ../packages/gps_pipeline && flutter pub get
```

#### Step 3: Compile the Rust FFI Dynamic Library
Compile the FIT parser native library for your host platform or target Android ABI:
```bash
cd packages/mwendo_fit_parser/rust
cargo build --release
```
*For Android NDK cross-compilation:*
```bash
cargo ndk -t arm64-v8a -t armeabi-v7a -o ../../../app/android/app/src/main/jniLibs build --release
```

#### Step 4: Run Drift Code Generation
Generate the SQLite database type mappings and query companions:
```bash
cd app
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Step 5: Start Local Backend Infrastructure via Docker
Initialize PostGIS 16 and Redis 7 in detached mode:
```bash
docker compose up -d
```
Verify container health status:
```bash
docker compose ps
```
The database executes schema migrations automatically from `0001_init.sql` upon startup.

---

## 4. Build & Deployment Process

### 4.1 Local Execution Workflows

#### Launching the Flutter Client
```bash
# Run on connected Android/iOS device or emulator
cd app
flutter run

# Run with custom backend API URL override
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

#### Launching the Go Backend Standalone
```bash
cd backend
export PORT=8080
export DATABASE_URL="postgres://mwendo:mwendo@localhost:5432/mwendo?sslmode=disable"
export REDIS_URL="redis://localhost:6379/0"
export JWT_SECRET="your-secure-secret-key-32-bytes-min"
export CORS_ORIGIN="*"
go run ./cmd/api
```

---

### 4.2 CI/CD Automation Specifications

The repository includes GitHub Actions workflows for continuous integration and automated release packaging:

#### Continuous Integration Pipeline (`.github/workflows/test.yml`)
Triggers on every `push` and `pull_request`:
* **Job 1: `flutter-test`**: Sets up Flutter `3.x` on Ubuntu, executes `flutter pub get`, and runs all widget and unit tests.
* **Job 2: `go-test`**: Sets up Go `1.22`, runs `go test ./...` across all backend packages.

```yaml
name: Mwendo CI
on: [push, pull_request]
jobs:
  flutter-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable
      - name: App tests
        run: cd app && flutter pub get && flutter test
  go-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'
      - name: Backend tests
        run: cd backend && go test ./...
```

#### Automated Release Packaging (`.github/workflows/release.yml`)
Triggers on Git version tags (`v*`):
* Provisions Java 21 (Zulu OpenJDK distribution).
* Executes `flutter build apk --debug` (or `--release`).
* Uploads the binary artifact to GitHub Releases via `softprops/action-gh-release@v1`.

---

### 4.3 Containerized Production Deployment

#### Production Dockerfile (`backend/Dockerfile`)
The backend compiles into a minimal scratch/alpine binary:
```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/api ./cmd/api

FROM alpine:3.19
RUN apk --no-cache add ca-certificates
COPY --from=build /bin/api /bin/api
EXPOSE 8080
ENTRYPOINT ["/bin/api"]
```

---

## 5. API & Module Reference

### 5.1 Module: `gps_pipeline` (`packages/gps_pipeline`)

#### Class: `GpsPipeline`
Central orchestration pipeline for incoming raw GPS fixes.

##### Constructor
```dart
GpsPipeline({
  required ActivityProfile profile,
  bool enableMapMatching = false,
})
```
* `profile`: Activity configuration (`ActivityProfile.run`, `cycle`, `drive`) governing speed ceilings and accuracy cutoffs.
* `enableMapMatching`: Enables post-session OSRM road snapping.

##### Methods
* **`PipelineResult? process(RawFix fix)`**
  * *Description:* Processes an incoming fix in real-time. Employs a 1-fix lookahead buffer for 3-point spike detection.
  * *Parameters:* `fix` (`RawFix`) - raw sensor fix.
  * *Returns:* `PipelineResult?` - null if buffered awaiting lookahead; otherwise contains filtered status and smoothed coordinates.
* **`List<PipelineResult> reprocess(List<RawFix> fixes)`**
  * *Description:* Synchronously recalculates an entire array of raw points without state bleed.
* **`Future<List<PipelineResult>> reprocessAsync(List<RawFix> fixes)`**
  * *Description:* Full reprocessing pipeline including asynchronous OSRM map-matching network requests.

##### Models & Enums
```dart
enum FilterStatus { measured, filtered, stationary, gapShort, gapLong, rejected }

class RawFix {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;
  final double speedMps;
  final int? heartRate;
  final int? cadence;
  final int accuracy;
  final double? hdop;
  final int? satelliteCount;
  final String? provider;
  final bool isMocked;
  final String fixType;
}

class PipelineResult {
  final RawFix raw;
  final double? smoothedLat;
  final double? smoothedLng;
  final FilterStatus filterStatus;
  final String? rejectReason;
  final double? innovationDistance;

  bool get isAccepted => filterStatus != FilterStatus.rejected;
}
```

---

### 5.2 Module: `MwendoGpsEngine` (`packages/mwendo_gps_engine`)

Provides native OS background telemetry acquisition through platform channels.

##### Public Interface
```dart
class MwendoGpsEngine {
  Stream<TrackPoint> startRecording({BatteryProfile profile = BatteryProfile.standard});
  Future<void> pause();
  Future<void> resume();
  Future<RecordingSummary> stop();
  Stream<EngineState> get state;
}
```

##### Native Implementations
* **Android (`MwendoTrackingService.kt`)**: Starts a foreground service with a persistent notification (`FOREGROUND_SERVICE_LOCATION`), subscribing to `LocationManager.GPS_PROVIDER` and `FusedLocationProviderClient`.
* **iOS (`MwendoGpsEnginePlugin.swift`)**: Configures `CLLocationManager` with `allowsBackgroundLocationUpdates = true` and `pausesLocationUpdatesAutomatically = false`.

---

### 5.3 Module: `MwendoFitParser` (`packages/mwendo_fit_parser`)

High-performance native Rust binary parser interfacing through `dart:ffi`.

##### Rust C-ABI Interface (`packages/mwendo_fit_parser/rust/src/lib.rs`)
```rust
#[no_mangle]
pub extern "C" fn parse_fit_data(path: *const c_char) -> *mut c_char;

#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char);
```

##### Dart Interface
```dart
class MwendoFitParser {
  static final instance = MwendoFitParser._();
  Future<void> initialize();
  Future<FitParseResult> parseBytes(Uint8List bytes);
}
```

---

### 5.4 Backend REST API Endpoints (`backend/cmd/api`)

Base URL: `http://localhost:8080/api/v1`

#### Authentication Endpoints

##### 1. Register User
* **Method & Route:** `POST /api/v1/auth/register`
* **Request Body:**
  ```json
  {
    "email": "runner@mwendo.app",
    "password": "SecurePassword123"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "status": "ok"
  }
  ```
* **Error Responses:** `400 Bad Request` (Validation), `409 Conflict` (Email already registered).

##### 2. Login
* **Method & Route:** `POST /api/v1/auth/login`
* **Request Body:**
  ```json
  {
    "email": "runner@mwendo.app",
    "password": "SecurePassword123"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```
  *Sets HTTP-Only `refresh_token` cookie.*

##### 3. Refresh Access Token
* **Method & Route:** `POST /api/v1/auth/refresh`
* **Cookie:** `refresh_token=<token>`
* **Response (200 OK):**
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ```

---

#### Activity Endpoints *(Requires `Authorization: Bearer <token>`)*

##### 4. List Activities
* **Method & Route:** `GET /api/v1/activities?limit=20`
* **Response (200 OK):**
  ```json
  [
    {
      "id": "5f9b4c2a1e8d3b7a",
      "user_id": "usr_991823",
      "type": "run",
      "started_at": "2026-08-16T06:30:00Z",
      "ended_at": "2026-08-16T07:15:20Z",
      "distance_m": 10042.5,
      "moving_time_ms": 2720000,
      "elevation_gain_m": 142.0
    }
  ]
  ```

##### 5. Create / Upload Activity
* **Method & Route:** `POST /api/v1/activities`
* **Request Body:**
  ```json
  {
    "type": "run",
    "started_at": "2026-08-16T06:30:00Z",
    "ended_at": "2026-08-16T07:15:20Z",
    "distance_m": 5000.0,
    "moving_time_ms": 1350000,
    "elevation_gain_m": 45.0,
    "trackpoints": [
      {
        "lat": -1.2921,
        "lng": 36.8219,
        "elevation": 1680.0,
        "timestamp": "2026-08-16T06:30:00Z",
        "speed_mps": 3.7
      }
    ]
  }
  ```
* **Response (200 OK):** Returns full persisted `Activity` object with generated ID.

##### 6. Get Activity Detail with PostGIS Simplification
* **Method & Route:** `GET /api/v1/activities/{id}?simplify=2.0`
* **Parameters:** `simplify` - Douglas-Peucker tolerance in metres (default `1.0m`).
* **Response (200 OK):**
  ```json
  {
    "id": "5f9b4c2a1e8d3b7a",
    "user_id": "usr_991823",
    "type": "run",
    "started_at": "2026-08-16T06:30:00Z",
    "distance_m": 5000.0,
    "moving_time_ms": 1350000,
    "elevation_gain_m": 45.0,
    "route": [
      [36.8219, -1.2921],
      [36.8225, -1.2930]
    ]
  }
  ```

---

#### Leaderboard Endpoints

##### 7. Get Top Leaderboard
* **Method & Route:** `GET /api/v1/leaderboard?limit=10`
* **Response (200 OK):**
  ```json
  [
    { "user_id": "usr_102", "score": 42195.0, "rank": 1 },
    { "user_id": "usr_883", "score": 35000.0, "rank": 2 }
  ]
  ```

##### 8. Submit Score *(Authorized)*
* **Method & Route:** `POST /api/v1/leaderboard/submit`
* **Request Body:**
  ```json
  { "score": 10000.0 }
  ```

---

## 6. Usage Guides & Tutorials

### Scenario 1: Tracking a Run with the Resilient Engine
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

class RunExample {
  void startRun(WidgetRef ref) async {
    final notifier = ref.read(trackingModelProvider.notifier);

    // 1. Initialize recording through the serial queue
    await notifier.start();

    // 2. Observe state reactively in UI
    final state = ref.read(trackingModelProvider);
    print('Engine State: ${state.state}'); // AppEngineState.recording
  }

  void pauseAndResume(WidgetRef ref) {
    final notifier = ref.read(trackingModelProvider.notifier);
    notifier.pause();
    // Later...
    notifier.resume();
  }

  Future<void> finishAndSave(WidgetRef ref) async {
    final notifier = ref.read(trackingModelProvider.notifier);
    final trackingState = ref.read(trackingModelProvider);

    // Build immutable RunRecord from finished session
    final record = runRecordFromSession(
      trackPoints: notifier.points,
      distanceM: trackingState.distanceM,
      durationMs: trackingState.elapsedMs,
      elevationGainM: trackingState.elevationGainM,
      calories: trackingState.calories,
      movingTimeMs: trackingState.movingTimeMs,
    );

    // Persist to local Drift SQLite database
    final repo = await ref.read(activityRepositoryProvider.future);
    await repo.save(record);

    // Stop and clear recovery journal
    await notifier.stop();
  }
}
```

---

### Scenario 2: Configuring a "Beat Legends" Virtual Race
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

void launchGhostRace(WidgetRef ref) {
  // 1. Select Ghost Profile (e.g. Eliud Kipchoge's Marathon WR)
  final ghost = ghostPaceForId('kipchoge-marathon');

  // 2. Select Scaled Difficulty Tier (Bronze = 125% of WR pace)
  final controller = ref.read(ghostRaceControllerProvider.notifier);
  controller.arm(ghost, DifficultyTier.bronze);

  // 3. Start run tracking; the Ghost controller automatically triggers
  // 4. Ghost race state updates on every incoming GPS point:
  ref.listen<GhostRaceStateData>(ghostRaceControllerProvider, (prev, next) {
    if (next is GhostRaceRacingData) {
      print('Delta vs Legend: ${next.deltaSeconds}s');
      print('Current Ghost Marker Position: ${next.ghostPosition}');
    }
  });
}
```

---

### Scenario 3: Generating a Route Quality Diagnostics Report
```dart
import 'package:gps_pipeline/gps_pipeline.dart';

void analyzeRunQuality(List<RawFix> rawFixes) {
  final pipeline = GpsPipeline(profile: ActivityProfile.run);
  final results = pipeline.reprocess(rawFixes);

  final report = SessionQualityReport.compute(results);

  print('=== Run Quality Report ===');
  print('Rejection Rate: ${report.rejectionRatePct.toStringAsFixed(1)}%');
  print('Median Accuracy: ${report.medianAccuracyM}m');
  print('Signal Gaps Detected: ${report.signalGapCount}');
  print('Raw Distance: ${report.rawDistanceM}m');
  print('Filtered Distance: ${report.filteredDistanceM}m');
}
```

---

## 7. Dependency Map

### 7.1 Client Dependencies (`app/pubspec.yaml`)

| Package | Version | Architectural Justification |
| :--- | :--- | :--- |
| `flutter_riverpod` | `^3.3.2` | Reactive, compile-safe dependency injection and state management without `BuildContext` leaks. |
| `drift` / `sqlite3_flutter_libs` | `^2.19.0` | Type-safe, reactive SQLite ORM supporting fast queries, migrations, and offline transactions. |
| `maplibre_gl` | `^0.26.2` | High-performance vector tile rendering with offline Carto dark styles and custom line layer shaders. |
| `go_router` | `^17.3.0` | Declarative routing with `StatefulShellRoute` tab persistence, custom transitions, and redirect guards. |
| `dio` | `^5.4.0` | Interceptor-based HTTP client handling JWT authorization headers, timeouts, and token refreshes. |
| `fl_chart` | `^1.2.0` | Hardware-accelerated elevation and pace split charting. |
| `permission_handler` | `^11.4.0` | Granular OS location and activity recognition permission requests. |
| `uuid` | `^4.2.0` | Cryptographically secure UUID v4 generation for local entity IDs. |
| `google_fonts` | `^6.2.1` | Typography system loading curated font weights. |

---

### 7.2 Cloud Backend Dependencies (`backend/go.mod`)

| Module | Version | Architectural Justification |
| :--- | :--- | :--- |
| `github.com/lib/pq` | `v1.10.9` | Pure Go PostgreSQL/PostGIS driver for geospatial SQL queries. |
| `github.com/redis/go-redis/v9` | `v9.5.1` | Non-blocking Redis client for Sorted Set weekly leaderboard scoring. |
| `github.com/golang-jwt/jwt/v5` | `v5.2.1` | Standard JWT token signing and verification library. |
| `golang.org/x/crypto` | `v0.21.0` | Bcrypt secure password hashing implementation. |

---

## 8. Contribution Guidelines

### 8.1 Local Development Standards
* **Code Formatting**:
  * Flutter / Dart: `dart format --line-length 100 .`
  * Go: `gofmt -s -w .`
  * Rust: `cargo fmt`
* **Static Analysis**:
  * Run `make analyze` before pushing code. Zero warnings are permitted under `flutter_lints 6.0.0`.
* **State Management Convention**:
  * Keep business logic inside `Notifier` / `AsyncNotifier` classes. Avoid mixing UI logic with data mutation.
* **Geospatial Precision**:
  * Coordinate transformations must use the `CoordinateUtil` helper in `gps_pipeline`. Never perform naive flat Euclidean distance calculations on WGS84 degree coordinates.

---

### 8.2 Testing Protocol
All PRs must include passing tests for affected modules:
```bash
# Run all client and backend tests
make test-all

# Run pure Dart GPS pipeline unit tests
cd packages/gps_pipeline && dart test

# Run Go backend test suite
cd backend && go test -v ./...
```

---

### 8.3 Branching & Pull Request Lifecycle
1. **Branch Naming**:
   * Features: `feat/feature-name` (e.g. `feat/ghost-splits-export`)
   * Bugfixes: `fix/issue-description` (e.g. `fix/kalman-singularity`)
   * Documentation: `docs/topic-name`
2. **Commit Convention**: Follow Conventional Commits:
   * `feat: add post-session OSRM map matching`
   * `fix: prevent race condition in tracking model lock queue`
   * `refactor: optimize PostGIS trackpoint spatial index`
3. **Pull Request Checklist**:
   - [ ] Automated tests passing in GitHub Actions.
   - [ ] No regression in GPS pipeline benchmarks.
   - [ ] Code formatted according to standard rules.
   - [ ] Database schema migrations tested forward and backward.
