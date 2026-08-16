# Mwendo Usage Guides & Practical Tutorials

---

## 1. Scenario 1: Tracking a Run with the Resilient Engine

This tutorial demonstrates how to use the Riverpod `TrackingModel` to record a workout with full crash resilience and Drift SQLite storage.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

class RunTrackerExample extends ConsumerWidget {
  const RunTrackerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingModelProvider);
    final isRecording = trackingState.state == AppEngineState.recording;
    final isPaused = trackingState.state == AppEngineState.paused;

    return Scaffold(
      appBar: AppBar(title: const Text('Mwendo Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${(trackingState.distanceM / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pace: ${trackingState.paceMinPerKm.toStringAsFixed(2)} min/km',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (trackingState.state == AppEngineState.idle)
                  ElevatedButton(
                    onPressed: () => ref.read(trackingModelProvider.notifier).start(),
                    child: const Text('Start Run'),
                  ),
                if (isRecording) ...[
                  ElevatedButton(
                    onPressed: () => ref.read(trackingModelProvider.notifier).pause(),
                    child: const Text('Pause'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async => _finishRun(ref),
                    child: const Text('Finish'),
                  ),
                ],
                if (isPaused) ...[
                  ElevatedButton(
                    onPressed: () => ref.read(trackingModelProvider.notifier).resume(),
                    child: const Text('Resume'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async => _finishRun(ref),
                    child: const Text('Finish'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishRun(WidgetRef ref) async {
    final notifier = ref.read(trackingModelProvider.notifier);
    final state = ref.read(trackingModelProvider);

    // 1. Build immutable RunRecord with full raw GPS provenance
    final record = runRecordFromSession(
      trackPoints: notifier.points,
      distanceM: state.distanceM,
      durationMs: state.elapsedMs,
      elevationGainM: state.elevationGainM,
      calories: state.calories,
      movingTimeMs: state.movingTimeMs,
    );

    // 2. Persist to local SQLite via Drift ActivityRepository
    final repo = await ref.read(activityRepositoryProvider.future);
    await repo.save(record);

    // 3. Stop hardware GPS engine and purge temporary journal snapshot
    await notifier.stop();
  }
}
```

---

## 2. Scenario 2: Launching a "Beat Legends" Virtual Race

This tutorial explains how to arm and race against Eliud Kipchoge's Marathon World Record scaled to Bronze Difficulty (125% of WR pace).

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';

void startKipchogeGhostRace(WidgetRef ref) {
  // 1. Retrieve Legend performance profile
  final ghost = ghostPaceForId('kipchoge-marathon');

  // 2. Arm GhostRaceController with chosen difficulty tier
  final ghostNotifier = ref.read(ghostRaceControllerProvider.notifier);
  ghostNotifier.arm(ghost, DifficultyTier.bronze);

  // 3. Start run tracking
  ref.read(trackingModelProvider.notifier).start();

  // 4. Listen to live race delta comparisons in your UI
  ref.listen<GhostRaceStateData>(ghostRaceControllerProvider, (prev, next) {
    if (next is GhostRaceRacingData) {
      print('Current split index: ${next.currentSplitIndex + 1}');
      print('Delta vs Legend: ${next.deltaSeconds > 0 ? "+" : ""}${next.deltaSeconds.toStringAsFixed(1)}s');
      print('Projected finish: ${(next.projectedFinishSeconds / 60).toStringAsFixed(1)} mins');
    }
  });
}
```

---

## 3. Scenario 3: Reprocessing GPS Telemetry & Generating Quality Metrics

This tutorial shows how to execute the pure Dart `GpsPipeline` to filter raw sensor data and compute a `SessionQualityReport`.

```dart
import 'package:gps_pipeline/gps_pipeline.dart';

void reprocessTelemetrySession(List<RawFix> rawTelemetry) {
  // 1. Instantiate pure Dart GpsPipeline with Running profile
  final pipeline = GpsPipeline(
    profile: ActivityProfile.run,
    enableMapMatching: false,
  );

  // 2. Reprocess raw fixes synchronously
  final results = pipeline.reprocess(rawTelemetry);

  // 3. Extract only accepted/smoothed points for display
  final smoothedCoords = results
      .where((r) => r.isAccepted)
      .map((r) => (lat: r.smoothedLat ?? r.raw.lat, lng: r.smoothedLng ?? r.raw.lng))
      .toList();

  // 4. Generate comprehensive quality report
  final report = SessionQualityReport.compute(results);

  print('Total fixes: ${rawTelemetry.length}');
  print('Accepted fixes: ${smoothedCoords.length}');
  print('Rejection rate: ${report.rejectionRatePct.toStringAsFixed(1)}%');
  print('Median accuracy: ${report.medianAccuracyM}m');
  print('P95 accuracy: ${report.p95AccuracyM}m');
  print('GPS Spikes / km: ${report.jumpsPerKm}');
  print('Signal gaps detected: ${report.signalGapCount}');
  print('Stationary clusters: ${report.stationaryClusterCount}');
}
```

---

## 4. Scenario 4: Querying the Go PostGIS Cloud API

### Fetching Simplified Routes for Fast Rendering
```bash
# Obtain simplified GeoJSON linestring (1-metre tolerance)
curl -X GET "http://localhost:8080/api/v1/activities/5f9b4c2a1e8d3b7a?simplify=1.0" \
     -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Submitting Scores to the Redis Weekly Leaderboard
```bash
curl -X POST "http://localhost:8080/api/v1/leaderboard/submit" \
     -H "Authorization: Bearer <ACCESS_TOKEN>" \
     -H "Content-Type: application/json" \
     -d '{"score": 10000.0}'
```
