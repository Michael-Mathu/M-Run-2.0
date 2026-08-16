import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelMwendoGpsEngine();
  const channel = MethodChannel('mwendo_gps_engine');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'stop') {
        return {
          'activity_id': 'a',
          'duration_ms': 2,
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('stop returns a RecordingSummary', () async {
    final summary = await platform.stop();
    expect(summary.activityId, 'a');
    expect(summary.durationMs, 2);
  });
}
