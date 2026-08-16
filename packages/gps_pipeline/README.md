# gps_pipeline

A high-precision, pure Dart mathematical telemetry processing engine for running, cycling, and vehicular GPS traces.

## Features

- **7-Stage Deterministic Pipeline**:
  1. `FixValidator`: Boundary checks, monotonic timestamps, and anti-mock filtering.
  2. `QualityGate`: Activity-specific accuracy radius thresholds and inverse-variance weighting.
  3. `OutlierDetector`: Maximum implied speed gating and 3-point lookahead spike rejection.
  4. `KalmanFilter`: 2D local tangent plane (ENU) state-space Extended Kalman Filter with adaptive process noise and Mahalanobis innovation gating.
  5. `StationarySuppressor`: Density-weighted centroid clustering to eliminate drift during stops.
  6. `GapDetector`: Temporal gap identification and state demarcation.
  7. `MapMatcher`: Post-session OSRM Hidden Markov road snapping.
- **Diagnostics & Quality Metrics**: `SessionQualityReport` calculation (rejection rates, median/P95 accuracy, spikes per km, signal gaps).
- **Pure Dart**: Zero Flutter UI dependencies — runnable on servers, CLI tools, and mobile engines.

## Usage

```dart
import 'package:gps_pipeline/gps_pipeline.dart';

void main() {
  final pipeline = GpsPipeline(profile: ActivityProfile.run);

  // Real-time processing
  final fix = RawFix(
    lat: -1.2921,
    lng: 36.8219,
    elevation: 1680.0,
    timestamp: DateTime.now(),
    speedMps: 3.5,
    accuracy: 8,
  );

  final result = pipeline.process(fix);
  if (result != null && result.isAccepted) {
    print('Smoothed Lat: ${result.smoothedLat}, Lng: ${result.smoothedLng}');
  }
}
```
