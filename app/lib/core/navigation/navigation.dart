import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Maps any matched location to the "parent" page it should fall back to when
/// there is no in-app history to pop (deep link / external URL landing).
///
/// Single source of truth, derived from the route table in
/// `core/router/app_router.dart`. Keep the two in sync.
const Map<String, String> _branchRoots = {
  '/': '/',
  '/run': '/run',
  '/explore': '/explore',
  '/learn': '/learn',
  '/learn/legends': '/learn',
  '/you': '/you',
  '/activity': '/activity',
  '/beat': '/beat',
  '/auth': '/',
  '/onboarding': '/',
};

/// Immediate parent page route for a deep-linked location, or `null` if the
/// location is not part of a known drill-down (defer to home). Used only when
/// there is no in-app history to pop, so back lands one step up the chain
/// rather than on a random tab.
String? branchRootFor(String location) {
  if (_branchRoots.containsKey(location)) return _branchRoots[location];
  if (location.startsWith('/learn/course/')) {
    // /learn/course/:slug/lesson/:index -> /learn/course/:slug
    // /learn/course/:slug             -> /learn
    final parts = location.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 4) return '/${parts[0]}/${parts[1]}/${parts[2]}';
    return '/learn';
  }
  if (location.startsWith('/challenges/')) return '/challenges';
  if (location.startsWith('/learn/legends/')) return '/learn';
  if (location.startsWith('/activity/')) return '/activity';
  if (location.startsWith('/beat/')) return '/beat';
  return null;
}

/// System-wide back behavior. Decides, in priority order:
///  1. An open modal/dialog (its own Navigator) — pop that.
///  2. Real in-app history within the active [StatefulNavigationShell] branch —
///     pop it. This is what makes "Legends → Learn" work: the Legends screen
///     lives on the Learn branch's internal navigator, so popping the branch
///     returns to the Learn root instead of falling through to a hard `go('/')`.
///  3. Any other go_router history — pop it.
///  4. Deep-link / orphan landing — go to the nearest parent page. Never a
///     random tab jump; only falls back to home for non-shell routes.
///
/// `canPop` (from the OS Navigator, the shell branch, and go_router) is the
/// single source of truth for history — no custom stack to keep in sync.
void onAppBack(BuildContext context) {
  // 1. Modal / dialog owned by the OS Navigator.
  final nav = Navigator.of(context, rootNavigator: false);
  if (nav.canPop()) {
    nav.maybePop();
    return;
  }

  // 2. Pop within the current bottom-nav branch (e.g. Legends → Learn).
  // The branch navigator is the nearest Navigator ancestor (rootNavigator: false).
  // If that navigator can't pop, try go_router's history.
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
    return;
  }

  // 3. Orphan / deep-link landing: fall back one step up the chain.
  final loc = router.state.matchedLocation;
  final fallback = branchRootFor(loc);
  final target = (fallback != null && fallback != loc) ? fallback : '/';
  router.go(target);
}

/// Consistent in-app Back control for every page. Auto-hides on the dashboard
/// home (`/`), where there is nowhere to go back to.
class AppBackButton extends StatelessWidget {
  final Color? color;
  const AppBackButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouter.of(context).state.matchedLocation;
    if (loc == '/') return const SizedBox.shrink();
    return IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: color),
      onPressed: () => onAppBack(context),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}

extension NavigationX on BuildContext {
  /// Navigate without re-pushing the route you are already on. Prevents the
  /// "tap back / re-tap, re-push same detail" accidental loop.
  void goSafe(String location) {
    if (GoRouter.of(this).state.matchedLocation == location) return;
    GoRouter.of(this).go(location);
  }

  void pushSafe(String location) {
    if (GoRouter.of(this).state.matchedLocation == location) return;
    GoRouter.of(this).push(location);
  }
}