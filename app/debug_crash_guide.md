The debug APK has been built and is available at:

`mwendo/app/build/app/outputs/flutter-apk/app-debug.apk`

> **Update (2026-07-09):** the run-sequence crash and the non-functional manual
> zoom described below have been **diagnosed and fixed** in
> `docs/diagnostic_report.md` (C1–C4 + Z1) and the fixes are implemented.
> The remaining value of this guide is confirming the fixes on a real device and
> catching any device-specific crash the static analysis couldn't (e.g. a
> different foreground-service / OEM quirk).

## Why the crash needs crash logs to diagnose

Without actual crash logs (e.g. `adb logcat`, crashlytics, or stack traces), it's impossible to pinpoint why "Begin Run" fails — the symptom could be a permission-denied `SecurityException`, an EventChannel registration error, an engine re-registration race, a notified permission crash, or any number of runtime issues.

## How to capture crash logs on a real device or emulator

### 1. Connect a device/emulator

If no Android device is found, start an Android Virtual Device (AVD):

```bash
flutter emulators
flutter emulators --launch <avd-name>
```

Or use `adb devices` to verify a connected emulator.

### 2. Install the debug APK

```bash
cd mwendo/app
flutter install --debug
```

### 3. Clear existing app data (if the app was previously installed)

```bash
adb shell pm clear com.mwendo.mwendo_app
```

### 4. Launch the app and reproduce the crash

- Tap **Begin Run** (the UI button that should trigger the run).
- The app will attempt GPS permissions, start the foreground service, and emit location points.
- As soon as the UI turns to **Recording** or the first GPS point is processed, let the app run for 5–10 seconds.

### 5. Capture logs

```bash
adb logcat -s "MwendoGpsEngine|flutter|TrackingModel|EventChannel"
```

Tap the button, then paste the entire log block into a reply. Expect to see anything among:

- **ERROR/AndroidRuntime (SecurityException)** — often from `ServiceCompat.startForeground()` (missing POST_NOTIFICATIONS)
- **java.lang.IllegalStateException** — EventChannel listen onCancel without proper cleanup
- **DriverDisconnectedException** / **Asynchronous error** — MethodChannel issues with the native plugin
- **FlutterError** — null instances (e.g., `service?.pause()`), or timing bugs in the engine methods.

## Common root causes in this codebase (based on the recent hardening)

From the audit/Kilo fixes just applied, the most likely runtime culprits are:

1. **Android 13+ POST_NOTIFICATIONS race** — `MwendoTrackingService.startInForeground()` tries
   `ServiceCompat.startForeground(...)` without a try/catch. If the user denies the notification
   permission, the service crashes, and Dart never receives the activity_id or the location stream.
   Result: the Dart side waits forever for the `activity_id`, potentially hanging or throwing a
   `Timeout` later.

2. **Multi-tasking EventChannel listeners** — The Dart `MwendoGpsEngine` constructor registers a
   fresh EventChannel listener every time `MwendoGpsEngine()` is instantiated. If Riverpod ever
   re-creates `trackingModelProvider` (e.g., a hot reload or app switch), the old listener is
   orphaned, the service stops forwarding events, and Dart gets no points.

   **Fix** (just applied): guard registration with `_registered` flag:
   ```dart
   bool _registered = false;
   void _register() {
     if (_registered) return;
     _registered = true;
     MwendoGpsEnginePlatform.instance = MethodChannelMwendoGpsEngine();
   }
   ```

3. **Offline-map tile server (removed)** — the app previously shipped a custom loopback tile
   server (`offline_map_provider.dart`) that parsed MBTiles/PMTiles bundles. It ran synchronous
   I/O on the UI thread, defaulted to offline even with no bundle present, and destroyed the map
   widget on toggle. This whole subsystem has been **deleted**; the app now uses the online Carto
   dark style via the shared `MwendoMap` widget, so these crash vectors no longer exist. (Offline
   maps will return later via MapLibre's built-in offline regions API.)

4. **GPS permission timing** — The Dart `TrackingModel._start()` calls `_engine.startRecording()`
   before Dart knows if notification permission was granted. If the user denies, the native
   `startForeground` silently crashes; Dart has no error feedback. **Fix** (just applied): wrap
   `ServiceCompat.startForeground()` in a try/catch in Kotlin, so the service continues without a
   visible notification, and Dart receives the activity_id event.

5. **Missing wall-clock timer** (pre-fix) — the UI used to derive `elapsedMs` from GPS point
   timestamps. With poor GPS coverage, the elapsed readout appeared frozen, mimicking a crash.
   **Fix** (just applied): add a 1‑second `Timer` in `TrackingModel` that drives `elapsedMs`
   independently of GPS. This ensures the timer ticks even on a GPS failure, and the dashboard
   reflects real progress.
6.  **Missing INTERNET Permission (Fixed in v0.15)** — Because the map relies on fetching styles (Carto Dark) over the network, missing the `<uses-permission android:name="android.permission.INTERNET" />` declaration in the Android Manifest leads to immediate `SecurityException` crashes from MapLibre's C++ core whenever location is granted, or a completely black map if the activity survives.

## Next steps

1. **Install the debug APK** on a connected Android device.
2. **Clear any cached app data** (as above).
3. **Reproduce the crash** by clicking the Begin Run button.
4. **Copy the logcat output** (via `adb logcat` with the suggested tags).
5. **Paste the logs here** — this will let you know exactly what's failing.

**Minimal scenario for a clean crash**: after installation, tap "Begin Run”. If you see
“Starting…” enter the live dashboard, and the app appears frozen or immediately returns to
the previous screen, capture those logs immediately.

Once you provide the crash logs, I can pinpoint the exact line and surrounding code that
needs fixing — likely a permission race or EventChannel orphaning.
