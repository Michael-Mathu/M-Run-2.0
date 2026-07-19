// Basic Flutter integration test for the mwendo_gps_engine plugin.
//
// Integration tests run in a full Flutter application, so they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// Real GPS recording requires location permissions and a device, so this only
// asserts the plugin can be constructed on the host platform.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin constructs', (WidgetTester tester) async {
    expect(MwendoGpsEngine(), isA<MwendoGpsEngine>());
  });
}
