import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'mwendo_gps_engine_method_channel.dart';

enum BatteryProfile { standard, powerSaver, ultraSaver }
enum EngineState { idle, recording, paused, recovering }

class TrackPoint {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;
  final double speedMps;
  final int? heartRate;
  final int? cadence;
  final int accuracy;
  final String state;

  TrackPoint({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
    required this.speedMps,
    this.heartRate,
    this.cadence,
    required this.accuracy,
    required this.state,
  });
}

class RecordingSummary {
  final String activityId;
  final double distanceM;
  final int durationMs;
  final int movingTimeMs;

  RecordingSummary({
    required this.activityId,
    required this.distanceM,
    required this.durationMs,
    required this.movingTimeMs,
  });
}

abstract class MwendoGpsEnginePlatform extends PlatformInterface {
  MwendoGpsEnginePlatform() : super(token: _token);
  static final Object _token = Object();

  static MwendoGpsEnginePlatform? _instance;

  static MwendoGpsEnginePlatform get instance {
    _instance ??= MethodChannelMwendoGpsEngine();
    return _instance!;
  }

  static set instance(MwendoGpsEnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<TrackPoint> startRecording({BatteryProfile profile});
  Future<void> pause();
  Future<void> resume();
  Future<RecordingSummary> stop();
  Stream<EngineState> get state;
}