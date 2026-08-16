import Flutter
import UIKit
import CoreLocation

public class MwendoGpsEnginePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, FlutterStreamHandler {
    var locationManager: CLLocationManager?
    var eventSink: FlutterEventSink?
    var activityId: String = UUID().uuidString
    var startTime: Int = 0

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
        case "getPlatformMetadata":
            getPlatformMetadata(result: result)
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
        locationManager?.startUpdatingLocation()
        result(nil)
    }

    private func stop(result: FlutterResult) {
        locationManager?.stopUpdatingLocation()
        let duration = Int(Date().timeIntervalSince1970 * 1000) - startTime
        result([
            "activity_id": activityId,
            "duration_ms": duration,
        ])
    }

    private func getPlatformMetadata(result: FlutterResult) {
        let osVersion = UIDevice.current.systemVersion
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let hardwareModel = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        
        result([
            "osVersion": "iOS " + osVersion,
            "hardwareModel": hardwareModel,
            "appVersion": appVersion
        ])
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            processLocation(location)
        }
    }

    private func processLocation(_ location: CLLocation) {
        let speed = max(0.0, location.speed)
        
        var isMocked = false
        if #available(iOS 15.0, *) {
            isMocked = location.sourceInformation?.isSimulatedBySoftware == true || location.sourceInformation?.isProducedByAccessory == true
        }
        
        var bearing: Double? = nil
        var bearingAccuracy: Double? = nil
        if location.course >= 0 {
            bearing = location.course
            if #available(iOS 13.4, *) {
                bearingAccuracy = location.courseAccuracy >= 0 ? location.courseAccuracy : nil
            }
        }
        
        eventSink?([
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "elevation": location.altitude,
            "timestamp": Int(location.timestamp.timeIntervalSince1970 * 1000),
            "speed": speed,
            "accuracy": location.horizontalAccuracy,
            "verticalAccuracy": location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil,
            "hdop": nil,
            "satelliteCount": nil, // CoreLocation doesn't expose satellite count
            "provider": "gps",
            "isMocked": isMocked,
            "fixType": "unknown",
            "bearing": bearing,
            "bearingAccuracy": bearingAccuracy,
        ])
    }
}