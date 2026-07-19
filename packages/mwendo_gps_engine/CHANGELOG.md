## 0.1.2

* Android: `MwendoTrackingService.startInForeground()` now wraps
  `ServiceCompat.startForeground()` in a try/catch for `SecurityException`, so a
  denied `POST_NOTIFICATIONS` permission no longer crashes the tracking service
  (it runs without a visible notification on API 33+).
* Dart: `MwendoGpsEngine()` registers its platform handler exactly once (guarded
  by a `_registered` flag), so re-instantiation no longer opens a second
  EventChannel stream or orphans the previous listener.

## 0.1.1

* Build fix for AGP 9 / modern Gradle: `MwendoTrackingService.activityId` is now
  package-visible (was `private`, which broke the plugin's `start`/`stop` result),
  and the `@SuppressLint("MissingPermission")` annotation was removed because
  `androidx.annotation` is not on the plugin's compile classpath. Permission is
  requested at runtime from Dart, so the suppression was unnecessary.

## 0.1.0

* Android: move the GPS subscription into a dedicated `MwendoTrackingService`
  foreground service with a persistent notification (`FOREGROUND_SERVICE_TYPE_LOCATION`),
  so a run keeps recording when the app is backgrounded or the screen is locked.
  The plugin binds to the service and forwards location updates via the EventChannel.
* iOS: keep Core Location updating in the background — `pausesLocationUpdatesAutomatically = false`,
  `activityType = .fitness`, and the `location` background mode declared in the host app.

## 0.0.1

* Initial scaffold.
