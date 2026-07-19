import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMwendoGpsEnginePlatform
    with MockPlatformInterfaceMixin
    implements MwendoGpsEnginePlatform {
  @override
  Stream<TrackPoint> startRecording(
          {BatteryProfile profile = BatteryProfile.standard}) =>
      const Stream.empty();

  @override
  Future<void> pause() => Future.value();

  @override
  Future<void> resume() => Future.value();

  @override
  Future<RecordingSummary> stop() => Future.value(
        RecordingSummary(
          activityId: 'x',
          distanceM: 0,
          durationMs: 0,
          movingTimeMs: 0,
        ),
      );

  @override
  Stream<EngineState> get state => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('$MethodChannelMwendoGpsEngine is the default instance', () {
    MwendoGpsEngine(); // triggers registration of the default platform
    expect(
      MwendoGpsEnginePlatform.instance,
      isInstanceOf<MethodChannelMwendoGpsEngine>(),
    );
  });

  test('startRecording returns a stream and stop a summary', () async {
    final engine = MwendoGpsEngine();
    // Override the platform AFTER construction so the engine uses the mock.
    MwendoGpsEnginePlatform.instance = MockMwendoGpsEnginePlatform();
    expect(engine.startRecording(), isA<Stream<TrackPoint>>());
    expect(await engine.stop(), isA<RecordingSummary>());
  });
}
