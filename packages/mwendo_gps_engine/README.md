# mwendo_gps_engine

Native Flutter plugin (Kotlin/Swift) that powers Mwendo's GPS tracking. It is
architecturally based on the Apache-2.0 [OpenTracks](https://github.com/OpenTracksAPP/OpenTracks)
project; no GPL code is copied.

## Features

- **Background recording** — on Android the subscription lives in a
  `MwendoTrackingService` foreground service with a persistent notification, so a
  run keeps recording after the app is backgrounded or the screen is locked.
- **iOS background updates** — `CLLocationManager` is configured with
  `allowsBackgroundLocationUpdates = true`, `pausesLocationUpdatesAutomatically = false`,
  and `activityType = .fitness`; the host app declares the `location` background mode.
- Battery profiles: `standard` / `powerSaver` / `ultraSaver` (5s / 20s / 30s interval).
- Stream of `TrackPoint` (lat/lng/elevation/speed/accuracy/state) via an `EventChannel`.

## Dart API

```dart
final engine = MwendoGpsEngine();
engine.startRecording(profile: BatteryProfile.standard).listen((TrackPoint p) { /* ... */ });
await engine.pause();
await engine.resume();
final summary = await engine.stop(); // RecordingSummary
```

## Required permissions / setup

- Android: `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`,
  `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS`
  (request `POST_NOTIFICATIONS` at runtime on API 33+).
- iOS: `NSLocationWhenInUseUsageDescription` +
  `NSLocationAlwaysAndWhenInUseUsageDescription`, and the `location` value in
  `UIBackgroundModes`.

## Not yet implemented

Adaptive hysteresis state machine, GPS watchdog, big-jump multipath filter, and a
real-time Kalman smoother still live on the tracking-quality roadmap (see blueprint
Phase 1 / "F — Tracking quality").

> **Note:** light smoothing already happens one layer up, in the app's
> `TrackingModel` (`tracking_controller.dart`). The live map polyline is fed an
> EMA-smoothed, 5m noise-culled copy of each fix (`_addDisplayPoint` /
> `displayPoints`), with the smoothing factor driven by `accuracy`. The raw
> `TrackPoint`s emitted by *this* engine are unchanged — they remain the source of
> truth for stored distance, pace, and SOS.
