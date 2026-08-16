# Mwendo API & Module Reference

This document provides a granular reference for all public interfaces, data models, and REST endpoints across the Mwendo ecosystem.

---

## 1. Package: `gps_pipeline`

### 1.1 Class: `GpsPipeline`
**Namespace:** `package:gps_pipeline/gps_pipeline.dart`

```dart
class GpsPipeline {
  final ActivityProfile profile;

  GpsPipeline({
    required this.profile,
    bool enableMapMatching = false,
  });

  PipelineResult? process(RawFix fix);
  List<PipelineResult> reprocess(List<RawFix> fixes);
  Future<List<PipelineResult>> reprocessAsync(List<RawFix> fixes);
}
```

#### Method Specifications

##### `process(RawFix fix) -> PipelineResult?`
* **Purpose:** Processes a single GPS fix in real-time. Employs a 1-fix lookahead buffer to catch 3-point spikes.
* **Parameters:** `fix` (`RawFix`) - Raw incoming fix from the GPS engine.
* **Returns:** `PipelineResult?` - `null` while buffered; returns `PipelineResult` once lookahead confirms validity.
* **Error / Rejection:** Rejected points return with `filterStatus == FilterStatus.rejected` and a non-null `rejectReason`.

##### `reprocess(List<RawFix> fixes) -> List<PipelineResult>`
* **Purpose:** Synchronously processes a full array of raw points for historical recalculation.
* **Parameters:** `fixes` (`List<RawFix>`) - Array of raw GPS fixes.
* **Returns:** `List<PipelineResult>` - Processed and smoothed results matching the length of the input.

##### `reprocessAsync(List<RawFix> fixes) -> Future<List<PipelineResult>>`
* **Purpose:** Asynchronously reprocesses an activity, executing OSRM network map-matching across accepted coordinates.

---

### 1.2 Data Structures & Enums

#### `enum ActivityProfile`
```dart
enum ActivityProfile {
  run(maxAccuracyM: 30.0, maxSpeedMps: 8.0),
  cycle(maxAccuracyM: 75.0, maxSpeedMps: 22.0),
  drive(maxAccuracyM: 100.0, maxSpeedMps: 55.0);

  final double maxAccuracyM;
  final double maxSpeedMps;
}
```

#### `enum FilterStatus`
```dart
enum FilterStatus {
  measured,    // Accepted raw measurement
  filtered,    // Smoothed via Kalman filter
  stationary,  // Part of stationary centroid cluster
  gapShort,    // Minor signal gap (10-60s)
  gapLong,     // Major signal outage (>60s)
  rejected     // Rejected by quality gate / outlier detector
}
```

#### `class RawFix`
```dart
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

  const RawFix({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
    required this.speedMps,
    this.heartRate,
    this.cadence,
    required this.accuracy,
    this.hdop,
    this.satelliteCount,
    this.provider,
    this.isMocked = false,
    this.fixType = 'unknown',
  });
}
```

#### `class PipelineResult`
```dart
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

### 1.3 Class: `SessionQualityReport`

```dart
class SessionQualityReport {
  final double rejectionRatePct;
  final double medianAccuracyM;
  final double p95AccuracyM;
  final int jumpsPerKm;
  final double maxImpliedSpeedMps;
  final double rawDistanceM;
  final double filteredDistanceM;
  final int signalGapCount;
  final double totalGapSeconds;
  final double interpolatedPct;
  final int stationaryClusterCount;

  static SessionQualityReport compute(List<PipelineResult> results);
}
```

---

## 2. Package: `mwendo_gps_engine`

### 2.1 Class: `MwendoGpsEngine`
**Namespace:** `package:mwendo_gps_engine/mwendo_gps_engine.dart`

```dart
class MwendoGpsEngine {
  Stream<TrackPoint> startRecording({BatteryProfile profile = BatteryProfile.standard});
  Future<void> pause();
  Future<void> resume();
  Future<RecordingSummary> stop();
  Stream<EngineState> get state;
}
```

#### Native Platform Bindings
* **Android Service:** `com.mwendo.mwendo_gps_engine.MwendoTrackingService` (Kotlin foreground service).
* **iOS Plugin:** `MwendoGpsEnginePlugin.swift` (`CLLocationManager` background stream).

---

## 3. Package: `mwendo_fit_parser`

### 3.1 Class: `MwendoFitParser`
**Namespace:** `package:mwendo_fit_parser/mwendo_fit_parser.dart`

```dart
class MwendoFitParser {
  static final instance = MwendoFitParser._();
  Future<void> initialize();
  Future<FitParseResult> parseBytes(Uint8List bytes);
}
```

#### Rust FFI Exports (`packages/mwendo_fit_parser/rust/src/lib.rs`)
```rust
#[no_mangle]
pub extern "C" fn parse_fit_data(path: *const c_char) -> *mut c_char;

#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char);
```

---

## 4. Client State & Database Layer (`app/lib`)

### 4.1 Drift Database Schema (`app/lib/data/database/tables.dart`)

```sql
-- Activities Table Schema
CREATE TABLE activities (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'Run',
    started_at INTEGER NOT NULL,
    ended_at INTEGER,
    distance_m REAL NOT NULL,
    duration_ms INTEGER NOT NULL,
    moving_time_ms INTEGER NOT NULL,
    calories INTEGER NOT NULL DEFAULT 0,
    elevation_gain_m REAL NOT NULL DEFAULT 0.0,
    avg_heart_rate INTEGER NOT NULL DEFAULT 0,
    avg_cadence INTEGER NOT NULL DEFAULT 0
);

-- Activity Points Table Schema
CREATE TABLE activity_points (
    activity_id TEXT NOT NULL,
    point_index INTEGER NOT NULL,
    lat REAL NOT NULL,
    lng REAL NOT NULL,
    elevation REAL NOT NULL,
    pace REAL NOT NULL,
    timestamp INTEGER NOT NULL,
    accuracy INTEGER,
    hdop REAL,
    satellite_count INTEGER,
    provider TEXT,
    is_mocked INTEGER NOT NULL DEFAULT 0,
    fix_type TEXT,
    state TEXT,
    PRIMARY KEY (activity_id, point_index)
);
```

---

## 5. Cloud REST API Specification (`backend/cmd/api`)

Base URL: `/api/v1`

### Summary of Endpoints

| Endpoint | Method | Auth | Description |
| :--- | :--- | :--- | :--- |
| `/health` | `GET` | No | Service and database health check |
| `/auth/register` | `POST` | No | Register new runner account |
| `/auth/login` | `POST` | No | Authenticate and obtain JWT access token |
| `/auth/refresh` | `POST` | Cookie | Refresh expired access token |
| `/auth/logout` | `POST` | Cookie | Invalidate refresh token |
| `/activities` | `GET` | Bearer | List authenticated user's activities |
| `/activities` | `POST` | Bearer | Upload and persist new activity |
| `/activities/{id}` | `GET` | Bearer | Get activity detail with `simplify` tolerance |
| `/leaderboard` | `GET` | No | Get global weekly ranking leaderboard |
| `/leaderboard/submit` | `POST` | Bearer | Increment weekly distance score |

---

### Granular Endpoint Definitions

#### `POST /api/v1/auth/register`
* **Request:**
  ```json
  {
    "email": "string (valid email)",
    "password": "string (min 8 chars)"
  }
  ```
* **Status Codes:**
  * `200 OK`: `{"status": "ok"}`
  * `400 Bad Request`: Validation failure.
  * `409 Conflict`: Email already exists.

#### `POST /api/v1/auth/login`
* **Request:**
  ```json
  {
    "email": "runner@mwendo.app",
    "password": "Password123"
  }
  ```
* **Response (200 OK):**
  ```json
  {
    "access_token": "eyJhbGciOi..."
  }
  ```
* **Headers:** Sets `Set-Cookie: refresh_token=...; HttpOnly; SameSite=Lax`.

#### `GET /api/v1/activities/{id}?simplify=1.0`
* **Query Parameters:**
  * `simplify` (optional, float): Douglas-Peucker simplification tolerance in metres (default: `1.0`).
* **Response (200 OK):**
  ```json
  {
    "id": "c1f7b8a9e0d1",
    "user_id": "usr_99",
    "type": "run",
    "started_at": "2026-08-16T06:00:00Z",
    "ended_at": "2026-08-16T06:45:00Z",
    "distance_m": 8450.2,
    "moving_time_ms": 2400000,
    "elevation_gain_m": 78.5,
    "route": [
      [36.8219, -1.2921],
      [36.8230, -1.2935]
    ],
    "trackpoints": [
      {
        "lat": -1.2921,
        "lng": 36.8219,
        "elevation": 1680.0,
        "speed_mps": 3.52,
        "timestamp": "2026-08-16T06:00:00Z"
      }
    ]
  }
  ```
