import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/navigation/navigation.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/activity/activity_detail_page.dart';
import 'package:mwendo_app/features/activity/activity_list_page.dart';
import 'package:mwendo_app/features/auth/auth_page.dart';
import 'package:mwendo_app/features/beat/beat_legends_page.dart';
import 'package:mwendo_app/features/beat/ghost_result_screen.dart';
import 'package:mwendo_app/features/challenges/challenge_detail_page.dart';
import 'package:mwendo_app/features/challenges/challenge_library_page.dart';
import 'package:mwendo_app/features/home/dashboard_page.dart';
import 'package:mwendo_app/features/learn/course_detail_page.dart';
import 'package:mwendo_app/features/learn/learn_page.dart';
import 'package:mwendo_app/features/learn/legend_detail_page.dart';
import 'package:mwendo_app/features/learn/legends_page.dart';
import 'package:mwendo_app/features/explore/explore_page.dart';
import 'package:mwendo_app/features/explore/route_detail_page.dart';
import 'package:mwendo_app/features/learn/lesson_page.dart';
import 'package:mwendo_app/features/onboarding/onboarding_page.dart';
import 'package:mwendo_app/features/onboarding/onboarding_provider.dart';
import 'package:mwendo_app/features/profile/profile_page.dart' show YouPage;
import 'package:mwendo_app/features/tracking/live_dashboard.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/features/tracking/route_analysis_screen.dart';

/// Slide-up + fade transition for pushed/drilled-down routes (detail pages,
/// full-screen flows): 6% upward slide, 200ms, easeOutCubic.
CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

/// Cross-fade transition for tab switches within the [StatefulShellRoute].
/// Tab changes should NOT feel like a push — they dissolve between branches.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

GoRouter makeRouter(Ref ref) {
  // Redirect-loop guard: a successful route settlement resets the counter, so
  // a redirect that keeps bouncing (e.g. auth ⇄ onboarding) is capped and
  // falls through to home instead of freezing the app.
  var redirectHops = 0;
  return GoRouter(
    initialLocation: '/',
    observers: [
      _RouteSettledObserver(() => redirectHops = 0),
    ],
    redirect: (context, state) async {
      final done = await ref.read(onboardingDoneProvider.future);
      final loc = state.matchedLocation;
      if (!done && loc != '/onboarding') {
        if (++redirectHops > 10) return '/';
        return '/onboarding';
      }
      if (done && loc == '/onboarding') {
        if (++redirectHops > 10) return '/';
        return '/';
      }
      redirectHops = 0;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => _fadePage(state, const DashboardPage()),
              ),
            ],
          ),
          // Tab 1: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) => _fadePage(state, const ExplorePage()),
              ),
            ],
          ),
          // Tab 2: Track
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/run',
                pageBuilder: (context, state) => _fadePage(state, const LiveDashboard()),
              ),
            ],
          ),
          // Tab 3: Learn
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                pageBuilder: (context, state) => _fadePage(state, const LearnPage()),
              ),
            ],
          ),
          // Tab 4: You
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/you',
                pageBuilder: (context, state) => _fadePage(state, const YouPage()),
              ),
            ],
          ),
        ],
      ),
      // Standalone routes (outside tabs)
      GoRoute(
        path: '/explore/:slug',
        pageBuilder: (context, state) => _slidePage(
          state,
          RouteDetailPage(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/learn/course/:slug',
        pageBuilder: (context, state) => _slidePage(
          state,
          CourseDetailPage(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/learn/course/:slug/lesson/:index',
        pageBuilder: (context, state) => _slidePage(
          state,
          LessonPage(
            slug: state.pathParameters['slug']!,
            index: int.parse(state.pathParameters['index']!),
          ),
        ),
      ),
      GoRoute(
        path: '/learn/legends',
        pageBuilder: (context, state) => _slidePage(state, const LegendsPage()),
      ),
      GoRoute(
        path: '/learn/legends/:slug',
        pageBuilder: (context, state) => _slidePage(
          state,
          LegendDetailPage(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/beat',
        pageBuilder: (context, state) => _slidePage(state, const BeatLegendsPage()),
      ),
      GoRoute(
        path: '/beat/:id',
        pageBuilder: (context, state) => _slidePage(
          state,
          BeatLegendsPage(id: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/activity',
        pageBuilder: (context, state) => _slidePage(state, const ActivityListPage()),
      ),
      GoRoute(
        path: '/activity/:id',
        pageBuilder: (context, state) => _slidePage(
          state,
          ActivityDetailPage(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/route-analysis/:id',
        pageBuilder: (context, state) => _slidePage(
          state,
          RouteAnalysisScreen(runId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/challenges',
        pageBuilder: (context, state) => _slidePage(state, const ChallengesLibraryPage()),
      ),
      GoRoute(
        path: '/challenges/:slug',
        pageBuilder: (context, state) => _slidePage(
          state,
          ChallengeDetailPage(slug: state.pathParameters['slug']!),
        ),
      ),
      GoRoute(
        path: '/ghost-result/:ghostId',
        pageBuilder: (context, state) => _slidePage(
          state,
          GhostResultScreen(
            ghostId: state.pathParameters['ghostId']!,
            tierName: state.uri.queryParameters['tier'] ?? 'goat',
            userWon: state.uri.queryParameters['won'] == 'true',
            userElapsedMs: int.tryParse(state.uri.queryParameters['elapsedMs'] ?? '0') ?? 0,
            splitsJson: state.uri.queryParameters['splits'] ?? '[]',
            routePointsJson: state.uri.queryParameters['route'] ?? '[]',
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _slidePage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _slidePage(state, const AuthPage()),
      ),
    ],
  );
}

/// Resets the redirect-loop counter whenever a route is actually pushed,
/// popped, or replaced, so the cap only trips on genuine redirect storms.
class _RouteSettledObserver extends NavigatorObserver {
  final VoidCallback onSettle;
  _RouteSettledObserver(this.onSettle);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) => onSettle();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previous) => onSettle();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      onSettle();
}

final appRouterProvider = Provider<GoRouter>((ref) => makeRouter(ref));

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const ScaffoldWithNavBar({super.key, required this.shell});

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  // Swipe-to-switch-tab: detect a horizontal fling on the shell body and move
  // to the adjacent branch. Lightweight alternative to wrapping the shell in a
  // PageView, which would fight StatefulShellRoute's internal navigators.
  static const _branchCount = 5;

  // Tabs that contain horizontal scrollable content should opt out of
  // shell-level swipe navigation to avoid gesture conflicts.
  // Index 1: Explore (horizontal segment chips + list)
  // Index 2: Track/Run (live map pans horizontally)
  // Index 3: Learn (horizontal course/lesson cards)
  static const _swipeDisabledIndices = {1, 2, 3}; // Explore, Track/Run, Learn

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_swipeDisabledIndices.contains(widget.shell.currentIndex)) return;
    final v = details.primaryVelocity;
    if (v == null || v.abs() < 300) return;
    final i = widget.shell.currentIndex;
    final next = v < 0 ? i + 1 : i - 1;
    if (next >= 0 && next < _branchCount) widget.shell.goBranch(next);
  }

  Widget _destination({
    required Widget icon,
    required Widget selectedIcon,
    required String label,
  }) =>
      NavigationDestination(
        icon: Opacity(opacity: 0.6, child: icon),
        selectedIcon: Transform.scale(scale: 1.15, child: selectedIcon),
        label: label,
      );

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final runTabVisible = widget.shell.currentIndex == 2;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onAppBack(context);
      },
      child: Scaffold(
        extendBody: true,
        body: GestureDetector(
          onHorizontalDragEnd: _onHorizontalDragEnd,
          behavior: HitTestBehavior.translucent,
          child: widget.shell,
        ),
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: NavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
              indicatorColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
              elevation: 0,
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: (i) {
                if (i != widget.shell.currentIndex) Haptics.selection();
                widget.shell.goBranch(i);
              },
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
            _destination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: L10n.tr('home', locale),
            ),
            _destination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: L10n.tr('explore_routes', locale),
            ),
            NavigationDestination(
              icon: _RunNavIcon(runTabVisible: runTabVisible),
              selectedIcon: _RunNavIcon(runTabVisible: runTabVisible),
              label: L10n.tr('run', locale),
            ),
            _destination(
              icon: const Icon(Icons.school_outlined),
              selectedIcon: const Icon(Icons.school_rounded),
              label: L10n.tr('learn', locale),
            ),
            _destination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: L10n.tr('you', locale),
            ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

/// Run tab icon. When not recording it emits a soft pulsing glow (attract
/// mode); once recording the glow steadies into a solid red pulse.
/// Pauses animation when the run tab is not visible to save CPU.
class _RunNavIcon extends ConsumerStatefulWidget {
  final bool runTabVisible;
  const _RunNavIcon({this.runTabVisible = true});

  @override
  ConsumerState<_RunNavIcon> createState() => _RunNavIconState();
}

class _RunNavIconState extends ConsumerState<_RunNavIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.runTabVisible) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _RunNavIcon old) {
    super.didUpdateWidget(old);
    if (widget.runTabVisible && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.runTabVisible && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recording =
        ref.watch(trackingModelProvider).state == AppEngineState.recording;
    const base = AppTheme.brand;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = recording ? 0.0 : (_pulse.value * 8 + 6);
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: recording ? 1.0 : 0.5),
                blurRadius: recording ? 14 : glow,
                spreadRadius: recording ? 3 : glow * 0.4,
              ),
            ],
          ),
          child: Icon(
            recording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 26,
          ),
        );
      },
    );
  }
}