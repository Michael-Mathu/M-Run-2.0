import Flutter
import UIKit
import CoreLocation

public class MwendoGpsEnginePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, FlutterStreamHandler {
    var locationManager: CLLocationManager?
    var eventSink: FlutterEventSink?
    var activityId: String = UUID().uuidString
    var distanceM: Double = 0
    var movingTimeMs: Int = 0
    var startTime: Int = 0
    var lastLat: Double = 0
    var lastLng: Double = 0
    var lastTime: Int = 0
    var hasLast: Bool = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "mwendo_gps_engine", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "mwendo_gps_engine/events", binaryMessenger: registrar.messenger())
        let instance = MwendoGpsEnginePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startRecording":
            startRecording(result: result)
        case "pause":
            pause(result: result)
        case "resume":
            resume(result: result)
        case "stop":
            stop(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(with arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(with arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private func startRecording(result: FlutterResult) {
        activityId = UUID().uuidString
        distanceM = 0
        movingTimeMs = 0
        startTime = Int(Date().timeIntervalSince1970 * 1000)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        // Keep recording while the app is backgrounded; do not let Core Location
        // auto-pause the stream when it detects little movement.
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.activityType = .fitness
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 5
        locationManager?.startUpdatingLocation()
        result(["activity_id": activityId])
    }

    private func pause(result: FlutterResult) {
        locationManager?.stopUpdatingLocation()
        result(nil)
    }

    private func resume(result: FlutterResult) {
        // Re-seed the last-fix anchor so the paused duration isn't counted as
        // moving time on the first fix after resume.
        lastTime = Int(Date().timeIntervalSince1970 * 1000)
        hasLast = false
        locationManager?.startUpdatingLocation()
        result(nil)
    }

    private func stop(result: FlutterResult) {
        locationManager?.stopUpdatingLocation()
        let duration = Int(Date().timeIntervalSince1970 * 1000) - startTime
        result([
            "activity_id": activityId,
            "distance_m": distanceM,
            "duration_ms": duration,
            "moving_time_ms": movingTimeMs
        ])
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            processLocation(location)
        }
    }

    private func processLocation(_ location: CLLocation) {
        let speed = location.speed
        let state = classifyState(speed)
        
        if hasLast {
            let distance = calculateDistance(lat1: lastLat, lng1: lastLng, lat2: location.coordinate.latitude, lng2: location.coordinate.longitude)
            distanceM += distance
            if state == "run" || state == "walk" {
                let gap = Int(location.timestamp.timeIntervalSince1970 * 1000) - lastTime
                // Out-of-order fixes or clock corrections can yield negative or
                // huge gaps; only count sane, positive deltas.
                if gap > 0 && gap < 60000 {
                    movingTimeMs += gap
                }
            }
        }
        
        lastLat = location.coordinate.latitude
        lastLng = location.coordinate.longitude
        lastTime = Int(location.timestamp.timeIntervalSince1970 * 1000)
        hasLast = true
        
        eventSink?([
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "elevation": location.altitude,
            "timestamp": lastTime,
            "speed_mps": speed,
            "accuracy": location.horizontalAccuracy,
            "state": state
        ])
    }

    private func classifyState(_ speed: Double) -> String {
        if speed < 0.8 { return "idle" }
        if speed < 5.0 { return "walk" }
        return "run"
    }

    private func calculateDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lng1)
        let loc2 = CLLocation(latitude: lat2, longitude: lng2)
        return loc1.distance(from: loc2)
    }
}