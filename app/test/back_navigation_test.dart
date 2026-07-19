import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwendo_app/app.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/core/theme/shared_preferences_provider.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Navigator).last));

/// The run tab shows a perpetual pulse animation, so `pumpAndSettle` never
/// settles. Advance past the 200ms route transition instead.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('deep-linked detail page backs through its parent chain',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MwendoApp(),
    ));
    await _settle(tester);

    final router = _router(tester);
    // Land directly on a lesson via deep link (no in-app history yet).
    router.go('/learn/course/how-to-start-running/lesson/0');
    await _settle(tester);

    // The Back button is present even though we arrived via deep link.
    expect(find.byType(AppBackButton), findsWidgets);

    // Back -> course detail.
    await tester.tap(find.byType(AppBackButton).first);
    await _settle(tester);
    expect(router.state.matchedLocation,
        '/learn/course/how-to-start-running');

    // Back -> learn list.
    await tester.tap(find.byType(AppBackButton).first);
    await _settle(tester);
    expect(router.state.matchedLocation, '/learn');
  });

  testWidgets('deep-linked branch root falls back to home, not a tab',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MwendoApp(),
    ));
    await _settle(tester);

    final router = _router(tester);
    router.go('/learn'); // deep link straight to a tab root
    await _settle(tester);

    // No in-app history and no parent: system-wide back returns home.
    onAppBack(tester.element(find.byType(Navigator).last));
    await _settle(tester);
    expect(router.state.matchedLocation, '/');
  });

  test('branchRootFor maps every drill-down to its parent', () {
    expect(branchRootFor('/challenges/foo'), '/challenges');
    expect(branchRootFor('/learn/course/foo'), '/learn');
    expect(branchRootFor('/learn/course/foo/lesson/0'), '/learn/course/foo');
    expect(branchRootFor('/learn/legends/foo'), '/learn');
    expect(branchRootFor('/activity/123'), '/activity');
    expect(branchRootFor('/beat/123'), '/beat');
    expect(branchRootFor('/'), '/');
    expect(branchRootFor('/learn'), '/learn');
    expect(branchRootFor('/auth'), '/');
    expect(branchRootFor('/onboarding'), '/');
  });
}
