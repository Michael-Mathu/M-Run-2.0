import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwendo_app/app.dart';
import 'package:mwendo_app/core/theme/shared_preferences_provider.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MwendoApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    // Onboarding is shown on a fresh install; its first slide proves the
    // theme, router and Phase 2 widget tree all build without error.
    expect(find.text('Run with Mwendo'), findsWidgets);
  });
}
