# Mwendo — Run-Sequence Crash & Map Zoom Diagnostic Report

> Scope: `app/lib/features/tracking/*`, `app/lib/widgets/mwendo_map.dart`,
> `packages/mwendo_gps_engine/**` (Dart + Kotlin).
> Method: static deep-dive of every function on the run path + the shared map
> widget. No `adb logcat` was available (see `app/debug_crash_guide.md`), so the
> crash root cause is ranked by code evidence; the #1 hypothesis is a direct
> consequence of the most recent commit ("consolidate the two map
> implementations → `trackingCompass`").

> **Status: IMPLEMENTED (2026-07-09, second pass).** All Phase 1–3 fixes are
> applied and verified: `flutter analyze` is clean and the GPS engine package
> tests pass. See `docs/audit.md` "Fixes Applied — Run-sequence crash & map
> zoom" for the per-bug mapping (C1→#9, C2→#10, Z1→#11, C3→#12, C4→#13).
> Phase 4 (manual device + logcat confirmation) remains the user's to run.
>
> **Refreshed 2026-07-10.** The run path has since been further refined (see
> `docs/audit.md` §18): foreground location is now requested on the home screen
> with the `Always`/background upgrade deferred to run start (no longer
> hard-blocking iOS); the engine moving-time calc was fixed in both Kotlin and
> Swift; `_stopTicker`'s dead `isPaused` param was removed; and the tab-swipe
> gesture no longer intercepts map pans on the Run tab. `flutter analyze`
> remains clean.

---

## 1. Executive summary

| # | Severity | Symptom | Root-cause location |
|---|----------|---------|---------------------|
| C1 | 🔴 High | App crashes / freezes shortly after tapping **Begin Run** | `MwendoMap` now forces `MyLocationTrackingMode.trackingCompass` during recording (`mwendo_map.dart:191`), replacing the previous `none`. Camera is driven by the native SDK while `myLocationEnabled` may still be `false` and the controller may be mid-bind → `PlatformException` / render exception. |
| C2 | 🔴 High | Hard crash on Android 13/14 when notification permission denied | `MwendoTrackingService.startInForeground()` catches the exception but never foregrounds the service → system `RemoteServiceException` when the foreground timeout fires (`MwendoTrackingService.kt:163-208`). |
| C3 | 🟡 Med | Run "freezes" after a previous crash / never records | `restoreInterrupted()` sets `recovering` without starting the engine or ticker (`tracking_controller.dart:187-222`); user cannot Start and Resume is a silent no-op. |
| C4 | 🟡 Med | Duplicate `activity_id` / orphaned stream on recover | `_start()` recover branch calls both `_engine.resume()` **and** `_engine.startRecording().listen()` again (`tracking_controller.dart:230-233`). |
| Z1 | 🔴 High | Manual pinch-zoom is non-functional on the run map | Same `trackingCompass` lock (C1) owns the camera every GPS fix; only **panning** frees it via `onCameraTrackingDismissed`, and there are **no explicit zoom controls** (`mwendo_map.dart:235-241`). |

The crash (C1/C2) and the zoom failure (Z1) share a single architectural cause:
**the live map hands the camera entirely to MapLibre's native tracking and gives
the user no first-class way to interrupt it.** The recent consolidation
(`live_dashboard.dart` / `mwendo_map.dart`) is what regressed this — before it the
live map used `MyLocationTrackingMode.none`.

---

## 2. Run-screen deep dive (`live_dashboard.dart` + `tracking_controller.dart`)

### 2.1 `_LiveDashboardState` lifecycle
- `initState` (`:38-50`) checks permission, then restores an interrupted run.
  ⚠️ `restoreInterrupted()` is fire-and-forget and **not awaited**; the next
  build may render `recovering` before points are loaded. (see C3)
- `build` (`:60-277`) rebuilds on **every GPS tick** because `_onPoint` mutates
  provider state. The `MwendoMap` is given a fresh `List<LatLng>` each time
  (`:91-95`). `didUpdateWidget` guards redraws by length, so this is not a storm,
  but it does re-run `build` of the whole dashboard per fix (5 s cadence — fine).

### 2.2 `_requestAndStart` (`:357-408`) — start of the run sequence
- Requests `locationWhenInUse` → if granted, `locationAlways`. If `locationAlways`
  is denied it **returns early and does not start** (good — prevents frozen runs).
- Then requests `Permission.notification`. ⚠️ If denied it only shows a snackbar
  **and still calls `ref.read(...).start()`** (`:404`). On Android 13+ a denied
  `POST_NOTIFICATIONS` normally only suppresses the notification (no throw), but on
  some OEMs / Android 14 the foreground start still fails → C2.
- ⚠️ Order bug: `start()` is called (`:404`) **before** `_refreshLocationPermission()`
  (`:407`). So the first recording frames have `locationEnabled = false` while the
  map immediately requests `trackingCompass` → C1.

### 2.3 `_onStop` (`:465-558`)
- Captures state *before* `stop()`, then `await stop()`. Correct ordering.
- Calls `sessionProvider.notifier.submitRun(...)` only when signed in (`:523`);
  guarded, but `submitRun` is unverified here and any throw inside that `await`
  propagates to the Stop tap (stop-path crash risk, not the start-path crash).

### 2.4 `TrackingModel` functions (`tracking_controller.dart`)
- `_start()` (`:226-263`): clears, starts ticker, subscribes `_engine.startRecording().listen(_onPoint)`.
  **Recover branch** (`:228-242`) calls `_engine.resume()` **and** `_engine.startRecording().listen()` →
  second native `startRecording` + second EventChannel subscription (C4).
- `restoreInterrupted()` (`:187-222`): sets `recovering` and loads points but
  **never** calls `_engine.startRecording()` or `_startTicker()`. If the user lands
  here (stale `mwendo_recovery.json` from a crashed prior run), the UI shows
  "GPS searching" forever and the Start FAB is hidden (not idle). Tapping Resume
  calls native `resume()` with `service == null` → silent no-op (C3).
- `_enqueue` (`:340-356`): good — serialises start/stop/pause and propagates
  errors instead of swallowing. No defect.
- `_writeRecovery`/`_clearRecovery` (`:137-171`): best-effort, swallow errors. Fine.
- `_onPoint` (`:265-307`): haversine + elevation gain. Correct. Throttled recovery
  every 10 points. No defect. **Note (post-audit):** each raw point is also passed
  through `_addDisplayPoint`, which maintains an EMA-smoothed lat/lng (alpha chosen
  from `accuracy`) and drops points within 5m of the last drawn one. Smoothed points
  go to `_displayPts` (exposed via `displayPoints`) for the live map polyline only;
  `_pts`/`points` stay raw and feed the DB, distance, pace, and SOS.

### 2.5 GPS engine — Dart (`packages/mwendo_gps_engine/lib/*`)
- `MwendoGpsEngine()` ctor registers the platform impl once (`_registered`
  guard). Good.
- `MethodChannelMwendoGpsEngine` ctor subscribes `_eventChannel.receiveBroadcastStream().listen(...)`
  once. Good — no orphaned listener.
- `startRecording()` (method_channel `:35-40`) adds `recording` to the state
  controller and fires `invokeMethod('startRecording')` **without awaiting**; it
  returns the broadcast `_trackpointController.stream`. Acceptable, but the
  `activity_id` from native is never surfaced to Dart (harmless today).

### 2.6 GPS engine — Kotlin (`MwendoGpsEnginePlugin.kt`, `MwendoTrackingService.kt`)
- `onServiceConnected` (`:28-36`) resolves `pendingStartResult` with `activity_id`.
  Double-tap protection in `startService` resolves a previous pending result as
  `null` to avoid "Reply already submitted" — good.
- `startInForeground` (`:163-208`) wraps `ServiceCompat.startForeground` in
  try/catch (SecurityException + generic Exception). **The catch hides the
  failure**: if the service fails to enter foreground, the OS kills it with
  `RemoteServiceException` a few seconds later → C2. No error is reported back to
  Dart, so the run silently dies.
- `processLocation` (`:126-155`) now `maxOf(0.0, speed)` and null-guards
  `accuracy`; wrapped in try/catch. Benign.

---

## 3. Map module deep dive (`mwendo_map.dart`)

### 3.1 Camera ownership (the crux of C1 + Z1)
```
MyLocationTrackingMode get _trackingMode {            // :187-194
  if (!_isLive || !_autoFollow) return MyLocationTrackingMode.none;
  return widget.isRecording
      ? MyLocationTrackingMode.trackingCompass        // <-- live + recording
      : MyLocationTrackingMode.tracking;
}
```
- While recording, the SDK **owns the camera**: it re-centers on the blue dot and
  rotates to heading on every fix. User gestures are intercepted/overridden.
- `onCameraTrackingDismissed` (`:235-241`) is the **only** escape, and it is wired
  **only in live mode**. It fires on **pan**, not pinch-zoom/rotate. So a user who
  only pinch-zooms can never free the camera → **manual zoom appears dead (Z1)**.
- There is **no zoom UI** (no +/- FAB). `MwendoMap` only offers a `_RecenterButton`
  shown after a pan.

### 3.2 First-fix race (feeds C1)
- `onUserLocationUpdated` (`:242-253`) animates to `latLngZoom(…,16)` the first
  time, guarded by `_firstFixDone`. But `didUpdateWidget` (`:92-99`) *also* sets
  `_firstFixDone` and animates. Two code paths toggle the same flag with no
  ordering guarantee against an unready `_ctrl`.
- During the first recording frames `myLocationEnabled` is still `false`
  (`_requestAndStart` bug, §2.2) while tracking mode is already `trackingCompass`.
  Requesting a tracking mode before the location layer is enabled is a known
  throw path in maplibre_gl/mapbox_gl → **C1**.

### 3.3 Route drawing
- `_syncRoute` (`:104-130`) serialises draws via `_isSyncing`/`_pendingCoords` —
  correct, coalesces overlapping ticks.
- `_drawRoute` (`:144-177`) updates the line in place, falls back to
  remove+add. Guarded by `mounted`/`_ctrl`. No defect.
- `build` (`:204-271`) returns a placeholder for replay with <2 points. Fine.

---

## 4. Root-cause verdict

- **Crash (C1)** is the most likely *run-sequence* crash and is tied to the most
  recent commit: switching the live map from `MyLocationTrackingMode.none` to
  `tracking`/`trackingCompass` while `myLocationEnabled` can still be `false`.
  The native layer rejects the tracking-mode update → `PlatformException` during
  the first render/animation of the recording map.
- **Crash (C2)** is the most likely *device-dependent* crash (Android 13/14,
  notification denied): the swallowed `startForeground` failure becomes a system
  `RemoteServiceException`.
- **Zoom (Z1)** is the same `trackingCompass` lock with no zoom affordance.

To confirm C1 vs C2 definitively, capture `adb logcat -s "MwendoGpsEngine|flutter|TrackingModel"`.

---

## 5. Step-by-step remediation roadmap

### Phase 0 — Capture logs (5 min, to confirm C1/C2)
1. `flutter emulators --launch <avd>` (or `adb devices`).
2. `adb shell pm clear com.mwendo.mwendo_app`.
3. Tap **Begin Run**, wait ~10 s, `adb logcat -s "MwendoGpsEngine|flutter|TrackingModel|AndroidRuntime"`.
4. Paste output. If you see `PlatformException(...tracking...)` → C1. If
   `RemoteServiceException: did not call startForeground` → C2.

### Phase 1 — Fix the crash (run sequence)
1. **Decouple camera from compass tracking (fixes C1 & Z1 together).**
   In `mwendo_map.dart` change the live recording mode from `trackingCompass` to
   north-up **`tracking`** (see §3.1). This keeps the SDK follow (and the
   `onCameraTrackingDismissed` → `_autoFollow=false` escape hatch) but stops the
   per-fix heading spin that fought user pinch-zoom and removed the
   tracking-while-location-disabled throw. Combined with the explicit `+/−` zoom
   FABs from step 4, manual zoom is now first-class.
   ```dart
   MyLocationTrackingMode get _trackingMode {
     if (!_isLive || !_autoFollow) return MyLocationTrackingMode.none;
     // North-up follow; never trackingCompass (C1/Z1).
     return MyLocationTrackingMode.tracking;
   }
   ```
   > **Implemented note:** the original plan proposed fully manual camera
   > (`none` + self-driven `animateCamera`). The shipped fix uses north-up
   > `tracking` instead — it preserves follow-to-user and the pan-to-free gesture
   > without needing a custom camera driver, and is paired with the zoom FABs.
2. **Order the permission refresh before start (fixes the `false`→`tracking` race).**
   In `live_dashboard.dart:_requestAndStart`, set `_hasLocationPermission = true`
   synchronously once all location permissions are granted, *before*
   `ref.read(...).start()`, so the location layer is enabled before the first
   recording frame requests tracking mode.
3. **Surface foreground-service failure to Dart (fixes C2).**
   `MwendoTrackingService.startInForeground()` now returns a `Boolean`;
   `onStartCommand` `stopSelf()`s when it fails (preventing the Android
   `RemoteServiceException` kill), and the plugin reports `FOREGROUND_FAILED` via
   `pendingStartResult.error(...)`. The Dart side logs event-stream errors via a
   new `onError` handler instead of crashing.

### Phase 2 — Fix the zoom UX (Z1)
4. **Add explicit zoom controls** to `MwendoMap`: a `+`/`−` FAB pair calling
   `ctrl.animateCamera(CameraUpdate.zoomIn()/zoomOut())`. These work regardless of
   tracking state and give users a first-class manual zoom.
5. **Wire `onCameraTrackingDismissed` for replay too** (currently `null`), so any
   static map also cancels auto-follow cleanly.
6. **Reset `_autoFollow` on `didUpdateWidget` when points change drastically**
   (e.g., new run) so a finished run's pan doesn't leak into the next run.

### Phase 3 — Fix run-state integrity (C3, C4)
7. **Make `restoreInterrupted()` start the engine + ticker, or auto-resume.**
   Either call `_start()` (which already handles the recover branch) from
   `initState` instead of just loading points, or have `restoreInterrupted()` also
   subscribe `_engine.startRecording().listen(_onPoint)` and `_startTicker()`.
8. **Remove the double start in the recover branch** (`tracking_controller.dart:230-233`):
   keep `_engine.resume()` *or* `_engine.startRecording().listen(...)`, not both,
   and guard against a second `_sub`.

### Phase 4 — Verify
9. `flutter analyze` and `flutter test` (existing GPS engine tests).
10. Manual: Begin Run with permission denied → expect a clear error, not a crash.
    Begin Run with permission granted → map shows blue dot, pinch-zoom works,
    pan shows recenter, Stop saves an activity.
11. Re-run Phase 0 logcat to confirm no `PlatformException` / `RemoteServiceException`.

### Priority order
C1 (camera/tracking lock) → C2 (foreground failure) → Z1 (zoom controls) →
C3/C4 (run-state integrity). Steps 1–2 alone are expected to resolve the reported
crash and the non-functional zoom, since they share the same `trackingCompass`
root cause.
