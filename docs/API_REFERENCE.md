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
  void flush();
  void reset();
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

##### `flush() -> PipelineResult?`
* **Purpose:** Flushes any remaining lookahead buffered point when tracking finishes or pauses.

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

#### `enum RejectReason`
```dart
enum RejectReason {
  none,
  invalidCoordinates,
  nonMonotonicTime,
  mockLocation,
  poorAccuracy,
  excessiveSpeed,
  threePointSpike,
  kalmanGatingFailed,
  stationaryDrift
}
```

#### `enum TrackVersion`
```dart
enum TrackVersion {
  deviceLive('device_live'),
  kalmanEkf('kalman_ekf'),
  postSessionSmoothed('post_session_smoothed'),
  mapMatchedOsm('map_matched_osm');

  final String id;
  const TrackVersion(this.id);
}
```

#### `enum QualityGrade`
```dart
enum QualityGrade {
  excellent('A', Color(0xFF2BB673)),
  good('B', Color(0xFF8DC63F)),
  acceptable('C', Color(0xFFFFD15C)),
  poor('D', Color(0xFFFF5A1F)),
  unreliable('F', Color(0xFFE53935));

  final String letter;
  final Color color;
  const QualityGrade(this.letter, this.color);
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

---

## 2. Package: `mwendo_app` Domain Models

### 2.1 Class: `RunRecord`
**Namespace:** `package:mwendo_app/data/models/run_record.dart`

```dart
class RunRecord {
  final String id;
  final String type;
  final DateTime startedAt;
  final double distanceM;
  final int durationMs;
  final int movingTimeMs;
  final int calories;
  final double elevationGainM;
  final int avgHeartRate;
  final int avgCadence;
  final List<RawFix> rawFixes;
  final List<PipelineResult> filteredResults;
  final List<PipelineResult>? matchedResults;
  final TrackVersion trackVersion;
  final String? ghostId;
  final bool? ghostWon;
  final int? ghostRaceVersion;

  /// Converts this record into an offline GhostPace to race against past personal efforts.
  GhostPace toGhostPace({String? customName});
}
```

### 2.2 Class: `ActivityRepository`
**Namespace:** `package:mwendo_app/data/repositories/activity_repository.dart`

```dart
class ActivityRepository {
  final AppDatabase _db;

  ActivityRepository(this._db);

  Future<List<RunRecord>> list();
  Future<RunRecord?> get(String id);
  Future<void> save(RunRecord run);
  Future<void> delete(String id);
}
```

---

## 3. Go Cloud REST API Reference

### 3.1 `POST /api/v1/auth/login`
* **Request:** `{"email": "runner@mwendo.app", "password": "securepassword"}`
* **Response (200 OK):** `{"token": "JWT_BEARER_TOKEN", "user_id": "uuid"}`

### 3.2 `POST /api/v1/activities`
* **Headers:** `Authorization: Bearer <TOKEN>`
* **Request Payload:**
```json
{
  "name": "Morning Forest Run",
  "started_at": "2026-08-16T06:30:00Z",
  "distance_m": 10245.5,
  "duration_s": 2700,
  "moving_time_s": 2640,
  "elevation_gain_m": 142.0,
  "calories": 680,
  "avg_hr": 154,
  "points": [
    {"lat": -1.2921, "lng": 36.8219, "ele": 1680.0, "time": "2026-08-16T06:30:00Z", "speed": 3.8}
  ]
}
```
* **Response (201 Created):** `{"id": "activity_uuid", "status": "persisted"}`

### 3.3 `GET /api/v1/activities/{id}`
* **Query Parameters:** `simplify` (optional float, tolerance in degrees/metres for `ST_Simplify`)
* **Response (200 OK):**
```json
{
  "id": "activity_uuid",
  "name": "Morning Forest Run",
  "distance_m": 10245.5,
  "route": {
    "type": "LineString",
    "coordinates": [[36.8219, -1.2921], [36.8225, -1.2915]]
  }
}
```

### 3.4 `GET /api/v1/leaderboard/weekly`
* **Response (200 OK):**
```json
[
  {"rank": 1, "user_id": "usr_001", "total_distance_m": 75400.0},
  {"rank": 2, "user_id": "usr_002", "total_distance_m": 68200.0}
]
```
