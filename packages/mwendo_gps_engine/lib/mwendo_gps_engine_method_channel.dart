import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'mwendo_gps_engine_platform_interface.dart';

class MethodChannelMwendoGpsEngine extends MwendoGpsEnginePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('mwendo_gps_engine');

  final _eventChannel = const EventChannel('mwendo_gps_engine/events');

  final _stateController = StreamController<EngineState>.broadcast();
  final _trackpointController = StreamController<TrackPoint>.broadcast();

  MethodChannelMwendoGpsEngine() {
    _eventChannel.receiveBroadcastStream().listen(
      _onTrackpointEvent,
      onError: _onEngineError,
    );
  }

  void _onEngineError(dynamic error) {
    // Native-side failures (e.g. foreground start rejected) arrive here.
    // Log rather than crash; the run simply receives no points.
    // ignore: avoid_print
    print('MwendoGpsEngine event error: $error');
  }

  void _onTrackpointEvent(dynamic event) {
    if (event is! Map) return;
    final Map<dynamic, dynamic> data = event;
    final rawFix = NormalizedFix.fromMap(data);
    _trackpointController.add(TrackPoint(
      raw: rawFix,
      heartRate: data['heart_rate'] as int?,
      cadence: data['cadence'] as int?,
      state: data['state'] as String? ?? 'idle',
    ));
  }

  @override
  Stream<TrackPoint> startRecording({BatteryProfile profile = BatteryProfile.standard}) {
    _stateController.add(EngineState.recording);
    methodChannel.invokeMethod('startRecording', {'profile': profile.name}).catchError((dynamic e) {
      debugPrint('Failed to start native recording: $e');
      _stateController.add(EngineState.idle);
    });
    return _trackpointController.stream;
  }

  @override
  Future<void> pause() async {
    _stateController.add(EngineState.paused);
    await methodChannel.invokeMethod('pause');
  }

  @override
  Future<void> resume() async {
    _stateController.add(EngineState.recording);
    await methodChannel.invokeMethod('resume');
  }

  @override
  Future<RecordingSummary> stop() async {
    _stateController.add(EngineState.idle);
    final result = await methodChannel.invokeMethod<Map>('stop');
    return RecordingSummary(
      activityId: result?['activity_id'] as String? ?? '',
      distanceM: (result?['distance_m'] as num?)?.toDouble() ?? 0.0,
      durationMs: (result?['duration_ms'] as num?)?.toInt() ?? 0,
      movingTimeMs: (result?['moving_time_ms'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Stream<EngineState> get state => _stateController.stream;

  @override
  Future<EnginePlatformMetadata> getPlatformMetadata() async {
    final result = await methodChannel.invokeMethod<Map>('getPlatformMetadata');
    return EnginePlatformMetadata(
      osVersion: result?['osVersion'] as String? ?? 'unknown',
      hardwareModel: result?['hardwareModel'] as String? ?? 'unknown',
      appVersion: result?['appVersion'] as String? ?? 'unknown',
    );
  }
}