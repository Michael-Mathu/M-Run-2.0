import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:permission_handler/permission_handler.dart';
import 'package:mwendo_app/core/permissions/location_permission.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/core/utils/format.dart';
import 'package:mwendo_app/core/utils/haptics.dart';
import 'package:mwendo_app/core/gamification/gamification_provider.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/network/session_provider.dart';
import 'package:mwendo_app/core/safety/safety_provider.dart';
import 'package:mwendo_app/data/models/run_record.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/beat/ghost_drawer.dart';
import 'package:mwendo_app/features/challenges/challenge_evaluator.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';
import 'package:mwendo_app/features/safety/safety_service.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';
import 'package:mwendo_app/widgets/celebration_overlay.dart';
import 'package:mwendo_app/widgets/metric_tile.dart';
import 'package:mwendo_app/widgets/mwendo_map.dart';
import 'package:mwendo_app/design_system/app_permission_card.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';
import 'package:go_router/go_router.dart';

class LiveDashboard extends ConsumerStatefulWidget {
  const LiveDashboard({super.key});

  @override
  ConsumerState<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends ConsumerState<LiveDashboard> {
  GamifiedChallenge? _celebrate;
  int _lastMilestone = 0;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    // Check location permission once here rather than on every GPS tick.
    // It's re-checked only when a run is started (a relevant event).
    _refreshLocationPermission();
    // Recover a run that was interrupted by a crash/kill.
    ref
        .read(trackingModelProvider.notifier)
        .hasRecoverableRun()
        .then((has) {
      if (has) ref.read(trackingModelProvider.notifier).restoreInterrupted();
    });
  }

  Future<void> _refreshLocationPermission() async {
    final granted = await Permission.location.isGranted;
    if (mounted && granted != _hasLocationPermission) {
      setState(() => _hasLocationPermission = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(trackingModelProvider);
    final ghostRace = ref.watch(ghostRaceControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);

    // km milestone haptic
    final km = (m.distanceM / 1000).floor();
    if (km > _lastMilestone && km > 0) {
      _lastMilestone = km;
      Haptics.light();
    }

    final isIdle = m.state == AppEngineState.idle;
    final isRecording = m.state == AppEngineState.recording;
    // A recovered run sits in `recovering` with loaded points but no engine
    // running. Show the primary Start/Resume CTA for it too, so resuming goes
    // through the permission-gated start() path (which starts the engine).
    final showStart =
        isIdle || m.state == AppEngineState.recovering;

    // Start ghost race when run starts recording
    ref.listen<GhostRaceStateData>(ghostRaceControllerProvider, (prev, next) {
      if (next is GhostRaceArmedData && isRecording) {
        ref.read(ghostRaceControllerProvider.notifier).start();
      }
    });

    // Update ghost race during tracking (throttled to avoid excessive updates)
    ref.listen<TrackingState>(trackingModelProvider, (prev, next) {
      final ghostRace = ref.read(ghostRaceControllerProvider);
      if (ghostRace is GhostRaceRacingData) {
        // Only update when distance or elapsed time change significantly
        final prevDist = prev?.distanceM ?? 0;
        final prevElapsed = prev?.elapsedMs ?? 0;
        if ((next.distanceM - prevDist).abs() < 1 && (next.elapsedMs - prevElapsed) < 500) {
          return; // Skip update - too frequent
        }
        final notifier = ref.read(trackingModelProvider.notifier);
        final routePoints = [
          for (final p in notifier.points) latlong.LatLng(p.lat, p.lng),
        ];
        ref.read(ghostRaceControllerProvider.notifier).update(
          userDistanceM: next.distanceM,
          userElapsedMs: next.elapsedMs.toDouble(),
          routePoints: routePoints,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Map takes full height when idle, split when recording
              Expanded(
                flex: isIdle ? 100 : 55,
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: MwendoMap(
                        // Snapshot the points as LatLng on every rebuild so the
                        // map never holds a mutable reference that _onPoint
                        // mutates concurrently (fixes Bug #6).
                        points: [
                          for (final p
                              in ref
                                  .read(trackingModelProvider.notifier)
                                  .displayPoints)
                            latlong.LatLng(p.lat, p.lng),
                        ],
                        mode: MapMode.live,
                        locationEnabled: _hasLocationPermission,
                        isRecording: isRecording,
                        ghost: ghostRace.maybeWhen(
                          racing: (r) => r.ghost,
                          armed: (g, _) => g,
                          finished: (g) => g.ghost,
                        ),
                        userDistanceM: m.distanceM,
                        raceState: ghostRace.maybeWhen(
                          racing: (r) => GhostRaceState.racing,
                          armed: (_, _) => GhostRaceState.armed,
                          finished: (g) => GhostRaceState.finished,
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppTheme.s12,
                      left: AppTheme.s16,
                      child: _StatusPill(state: m.state),
                    ),
                    if (!isIdle)
                      ghostRace.maybeWhen(
                        racing: (racing) => Positioned(
                          top: MediaQuery.of(context).padding.top + AppTheme.s12 + 36,
                          left: AppTheme.s16,
                          child: _GhostChip(
                            ghost: racing.ghost,
                            m: m,
                            deltaSeconds: racing.deltaSeconds,
                          ),
                        ),
                        armed: (ghost, tier) => Positioned(
                          top: MediaQuery.of(context).padding.top + AppTheme.s12 + 36,
                          left: AppTheme.s16,
                          child: _GhostChipArmed(ghost: ghost, tier: tier),
                        ),
                        idle: () => const SizedBox.shrink(),
                      ) ?? const SizedBox.shrink(),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppTheme.s12,
                      right: AppTheme.s16,
                      child: const _SosButton(),
                    ),
                    // Ghost drawer for live split comparison
                    if (!isIdle) const GhostDrawer(),
                  ],
                ),
              ),
              // Bottom panel - only show metrics when not idle
              if (!isIdle)
                Expanded(
                  flex: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.r24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.s24,
                      AppTheme.s20,
                      AppTheme.s24,
                      AppTheme.s16,
                    ),
                    child: Column(
children: [
                         // Drag handle
                         Container(
                           width: 36,
                           height: 4,
                           decoration: BoxDecoration(
                             color: cs.onSurface.withValues(alpha: 0.2),
                             borderRadius: BorderRadius.circular(2),
                           ),
                         ),
                         const SizedBox(height: AppTheme.s16),
                         // Primary metrics using canonical MetricTile
                         Row(
                           children: [
                             Expanded(
                               child: MetricTile(
                                 variant: MetricVariant.hero,
                                 value: (m.distanceM / 1000).toStringAsFixed(2),
                                 label: L10n.tr('distance_label', locale),
                                 valueColor: AppTheme.brand,
                               ),
                             ),
                             const SizedBox(width: AppTheme.s24),
                             Expanded(
                               child: MetricTile(
                                 variant: MetricVariant.hero,
                                 value: formatPace(m.paceMinPerKm),
                                 label: L10n.tr('pace', locale),
                                 valueColor: cs.onSurface,
                               ),
                             ),
                             const SizedBox(width: AppTheme.s24),
                             Expanded(
                               child: MetricTile(
                                 variant: MetricVariant.hero,
                                 value: formatDuration(m.elapsedMs),
                                 label: L10n.tr('time_label', locale),
                                 valueColor: cs.onSurface,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: AppTheme.s16),
// Secondary metrics row
                         Container(
                           padding: const EdgeInsets.all(AppTheme.s12),
                           decoration: BoxDecoration(
                             color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                             borderRadius: BorderRadius.circular(AppTheme.r12),
                           ),
                           child: Row(
                             children: [
                               Expanded(
                                 child: Row(
                                   children: [
                                     Icon(Icons.terrain_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.7)),
                                     const SizedBox(width: AppTheme.s8),
                                     Expanded(
                                       child: MetricTile(
                                         variant: MetricVariant.inline,
                                         value: m.elevationGainM.toStringAsFixed(0),
                                         label: L10n.tr('elev_label', locale),
                                         valueColor: cs.onSurface,
                                         align: TextAlign.end,
                                       ),
                                     ),
                                   ],
                                 ),
),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: cs.onSurface.withValues(alpha: 0.1),
                                ),
                                Expanded(
                                 child: Row(
                                   children: [
                                     Icon(Icons.local_fire_department_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.7)),
                                     const SizedBox(width: AppTheme.s8),
                                     Expanded(
                                       child: MetricTile(
                                         variant: MetricVariant.inline,
                                         value: m.calories.toString(),
                                         label: L10n.tr('calories_label', locale),
                                         valueColor: cs.onSurface,
                                         align: TextAlign.end,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Control buttons - positioned differently based on state
          if (showStart)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AppTheme.s32,
              left: 0,
              right: 0,
              child: Center(
                child: _StartButton(
                  onStart: () => _requestAndStart(ref, context),
                ),
              ),
            )
          else
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + AppTheme.s16,
              left: 0,
              right: 0,
              child: _ControlBar(
                isRecording: isRecording,
                onPause: () {
                  Haptics.light();
                  ref.read(trackingModelProvider.notifier).pause();
                },
                onResume: () {
                  Haptics.light();
                  ref.read(trackingModelProvider.notifier).resume();
                },
                onStop: () => _onStop(ref),
              ),
            ),
          if (_celebrate != null)
            CelebrationOverlay(
              title: _celebrate!.title,
              subtitle: 'Challenge complete · +${_celebrate!.xp} XP',
              onDone: () => setState(() => _celebrate = null),
            ),
        ],
      ),
    );
  }

  Future<void> _requestAndStart(WidgetRef ref, BuildContext context) async {
    Haptics.medium();
    final locale = ref.read(localeProvider);
    
    // 1. Foreground Location
    final ok = await ensureLocationPermission(context, ref);
    if (!ok) return;

    // 2. Notifications (Android 13+)
    final notif = await Permission.notification.status;
    if (!notif.isGranted) {
      final notifResult = await Permission.notification.request();
      if (context.mounted && !notifResult.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.tr('enable_notifications', locale)),
          ),
        );
      }
    }

    // 3. Background Location (Android 11+)
    // We cannot request this concurrently with foreground location.
    // If not granted, explain and let them go to Settings, OR skip.
    if (context.mounted) {
      final bgStatus = await Permission.locationAlways.status;
      if (!context.mounted) return;
      if (!bgStatus.isGranted) {
        final shouldGoToSettings = await showModalBottomSheet<bool>(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppTheme.s16,
              left: AppTheme.s16,
              right: AppTheme.s16,
              top: AppTheme.s16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.r24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppTheme.s16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppPermissionCard(
                  icon: Icons.location_on_rounded,
                  title: L10n.tr('gps_required_title', locale),
                  description: "For reliable tracking when your phone is locked, allow background location. Note: Android will restart the app when you grant this in Settings.",
                  actionLabel: L10n.tr('open_settings', locale),
                  onAction: () {
                    Navigator.of(ctx).pop(true);
                  },
                ),
                const SizedBox(height: AppTheme.s8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(L10n.tr('continue_without_background_location', locale)),
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
              ],
            ),
          ),
        );

        if (shouldGoToSettings == true) {
          openAppSettings();
          // Stop here. The user goes to settings. When they grant the permission,
          // Android will kill and restart the app. They can tap Start Run again.
          return;
        }
      }
    }
    
    // Wait for Android to fully transition the Activity to the foreground state
    // and for the OS to sync the newly granted permissions across its services.
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Enable MapLibre location component AFTER the delay to prevent native SecurityException
    if (mounted) setState(() => _hasLocationPermission = true);
    
    if (mounted) {
      try {
        await ref.read(trackingModelProvider.notifier).start();
      } catch (e) {
        debugPrint('Failed to start GPS engine: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.tr('gps_error_start', locale)),
            ),
          );
        }
        return;
      }
    }
    _refreshLocationPermission();
  }

  void _onStop(WidgetRef ref) async {
    Haptics.heavy();
    // Capture ALL state BEFORE calling stop() which resets to initial.
    final m = ref.read(trackingModelProvider);
    final notifier = ref.read(trackingModelProvider.notifier);
    final trackPoints = List<TrackPoint>.from(notifier.points);
    final distanceM = m.distanceM;
    final elapsedMs = m.elapsedMs;
    final movingTimeMs = m.movingTimeMs;
    final elevationGainM = m.elevationGainM;
    final calories = m.calories;
    final heartRate = m.heartRate;
    // Calculate average cadence from trackpoints
    int cadenceSum = 0, cadenceCount = 0;
    for (final p in trackPoints) {
      if (p.cadence != null) {
        cadenceSum += p.cadence!;
        cadenceCount++;
      }
    }
    final avgCadence = cadenceCount > 0 ? (cadenceSum / cadenceCount).round() : 0;
    final ghostRaceState = ref.read(ghostRaceControllerProvider);
    final ghost = ghostRaceState.maybeWhen(
      racing: (r) => r.ghost,
      armed: (g, _) => g,
      finished: (g) => g.ghost,
    );

    await ref.read(trackingModelProvider.notifier).stop();

    if (distanceM < 1) {
      ref.read(ghostRaceControllerProvider.notifier).reset();
      return;
    }

    final record = runRecordFromSession(
      trackPoints: trackPoints,
      distanceM: distanceM,
      durationMs: elapsedMs,
      elevationGainM: elevationGainM,
      calories: calories,
      movingTimeMs: movingTimeMs,
      avgHeartRate: heartRate,
      avgCadence: avgCadence,
    );
    try {
      final repo = await ref.read(activityRepositoryProvider.future);
      await repo.save(record);
      debugPrint('Run saved successfully: id=${record.id}, distance=${distanceM}m');
    } catch (e, st) {
      debugPrint('Run save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save run')),
        );
      }
    }
    // Invalidate repository to force all dependent providers to re-read
    ref.invalidate(activityRepositoryProvider);
    ref.invalidate(activitiesProvider);
    ref.invalidate(activityByIdProvider);

    final userAvgPace = distanceM > 0
        ? (elapsedMs / 60000) / (distanceM / 1000)
        : 0.0;
    final newly = ref.read(gamificationProvider.notifier).completeRun(
          distanceM: distanceM,
          durationMs: elapsedMs,
          elevationGainM: elevationGainM,
          avgPaceMinPerKm: userAvgPace,
        );
    // B2: sync to the leaderboard when signed in; anonymous runs stay local.
    final session = ref.read(sessionProvider);
    if (!session.isAnonymous && mounted) {
      final ok = await ref.read(sessionProvider.notifier).submitRun(
        distanceM: distanceM,
        durationMs: elapsedMs,
        movingTimeMs: movingTimeMs,
        elevationGainM: elevationGainM,
        startedAt: trackPoints.isNotEmpty
            ? trackPoints.first.timestamp
            : DateTime.now(),
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.tr('submitted', ref.read(localeProvider)))),
        );
      }
    }

    // Handle ghost race finish
    if (ghost != null && ghostRaceState is GhostRaceRacingData) {
      final userAvg = (elapsedMs / 60000) / (distanceM / 1000);
      final beat = userAvg <= ghost.avgPaceMinPerKm;
      final newlyGhost = ref.read(gamificationProvider.notifier).recordBeatLegend(ghost, beat);

      // Finish the ghost race controller
      ref.read(ghostRaceControllerProvider.notifier).finish(
        userWon: beat,
        userElapsedMs: elapsedMs,
      );

      if (mounted) {
        // Navigate to ghost result screen
        final ghostRaceFinal = ref.read(ghostRaceControllerProvider);
        ghostRaceFinal.maybeWhen(
          finished: (finished) {
            GoRouter.of(context).go('/ghost-result/${ghost.id}', extra: {
              'tier': finished.tier.name,
              'won': finished.result == GhostRaceResult.win,
              'elapsedMs': finished.userElapsedMs,
              'splits': finished.splitComparisons.map((s) => {
                'index': s.splitIndex,
                'ghostTime': s.ghostSplitTime,
                'userTime': s.userProjectedSplitTime,
                'delta': s.deltaSeconds,
                'isAhead': s.isAhead,
                'progress': s.progressInSplit,
              }).toList(),
              'routePoints': trackPoints.map((p) => {'lat': p.lat, 'lng': p.lng}).toList(),
            });
          },
        );
      }

      if (newlyGhost.isNotEmpty && mounted) {
        setState(() => _celebrate = newlyGhost.first);
      }
    } else if (newly.isNotEmpty && mounted) {
      setState(() => _celebrate = newly.first);
    }
  }
}

/// Professional start button for idle state - large, gradient, with icon
class _StartButton extends ConsumerWidget {
  final VoidCallback onStart;
  const _StartButton({required this.onStart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Semantics(
      button: true,
      label: L10n.tr('start_run_control', locale),
      child: _AnimatedBounceButton(
        onTap: onStart,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.brand.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Professional control bar for recording/paused state
class _ControlBar extends ConsumerWidget {
  final bool isRecording;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const _ControlBar({
    required this.isRecording,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.s32),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.rFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stop button
          Semantics(
            button: true,
            label: L10n.tr('stop_run', locale),
            child: _AnimatedBounceButton(
              onTap: onStop,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.sos,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
          // Main play/pause button
          Semantics(
            button: true,
            label: isRecording ? L10n.tr('pause_run', locale) : L10n.tr('resume_run', locale),
            child: _AnimatedBounceButton(
              onTap: isRecording ? onPause : onResume,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brand.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Spacer for symmetry (placeholder for future lap button)
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _StatusPill extends ConsumerWidget {
  final AppEngineState state;
  const _StatusPill({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final map = {
      AppEngineState.idle: (L10n.tr('ready', locale), AppTheme.idle),
      AppEngineState.recording: (L10n.tr('recording', locale), AppTheme.recording),
      AppEngineState.paused: (L10n.tr('paused', locale), AppTheme.paused),
      AppEngineState.recovering: (L10n.tr('gps_searching', locale), AppTheme.paused),
    };
    final (label, color) = map[state] ?? (L10n.tr('unknown', locale), AppTheme.idle);
    final live = state == AppEngineState.recording;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: live
                  ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 2)]
                  : null,
            ),
          ),
          const SizedBox(width: AppTheme.s8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _GhostChip extends ConsumerWidget {
  final GhostPace ghost;
  final TrackingState m;
  final double deltaSeconds;
  const _GhostChip({required this.ghost, required this.m, required this.deltaSeconds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final userAvg = m.distanceM > 0
        ? (m.elapsedMs / 60000) / (m.distanceM / 1000)
        : 0.0;
    final ahead = deltaSeconds < 0 && userAvg > 0;
    final color = ahead ? AppTheme.recording : AppTheme.idle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.blur_on_rounded, color: Colors.white, size: 14),
          const SizedBox(width: AppTheme.s6),
           Text(
            '${L10n.tr('ghost_label', locale)} ${formatPace(ghost.avgPaceMinPerKm)} · you ${userAvg > 0 ? formatPace(userAvg) : "--:--"}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const SizedBox(width: AppTheme.s6),
          Text(
            userAvg > 0 ? '${ahead ? "" : "+"}${formatSeconds(deltaSeconds.abs())}' : '',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _GhostChipArmed extends ConsumerWidget {
  final GhostPace ghost;
  final DifficultyTier tier;
  const _GhostChipArmed({required this.ghost, required this.tier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s10, vertical: AppTheme.s6),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tier.badge, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: AppTheme.s4),
          Text(
            '${L10n.tr('ghost_label', locale)} ${tier.label} · ${L10n.tr('ready_to_race', locale)}',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SosButton extends ConsumerWidget {
  const _SosButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Semantics(
      button: true,
      label: L10n.tr('sos_button', locale),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _confirmSos(context, ref),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.shield_outlined, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  void _confirmSos(BuildContext context, WidgetRef ref) {
    final locale = ref.read(localeProvider);
    final cs = Theme.of(context).colorScheme;
    final surface = Theme.of(context).dialogTheme.backgroundColor ?? cs.surface;
    final contacts = ref.read(safetyContactsProvider);
    if (contacts.isEmpty) {
      showDialog(
        context: context,
        builder: (dlg) => AlertDialog(
          backgroundColor: surface,
          title: Text(L10n.tr('no_emergency_contacts', locale),
              style: TextStyle(color: cs.onSurface)),
          content: Text(
            L10n.tr('sos_prompt', locale),
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlg).pop(),
              child: Text(L10n.tr('ok', locale)),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlg) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(dlg).pop();
        },
        child: _SosCountdownDialog(onComplete: () {
          Navigator.of(dlg).pop();
          _sendSos(ref);
        }),
      ),
    );
  }

  Future<void> _sendSos(WidgetRef ref) async {
    final contacts = ref.read(safetyContactsProvider);
    final notifier = ref.read(trackingModelProvider.notifier);
    final pts = notifier.points;
    final last = pts.isNotEmpty ? pts.last : null;
    final lat = last?.lat ?? kDefaultCenter.latitude;
    final lng = last?.lng ?? kDefaultCenter.longitude;
    await SafetyService.sendSos(contacts, lat, lng);
  }
}

/// Safety-critical SOS countdown: a circular ring that fills red while the
/// number ticks 3 → 2 → 1, escalating amber → orange → red for urgency. Each
/// tick fires a light haptic. Cancelling pops the dialog (timer disposed).
class _SosCountdownDialog extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const _SosCountdownDialog({required this.onComplete});

  @override
  ConsumerState<_SosCountdownDialog> createState() => _SosCountdownDialogState();
}

class _SosCountdownDialogState extends ConsumerState<_SosCountdownDialog> {
  static const int _start = 3;
  int _remaining = _start;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      // Genuine 1-second tick (not a UI animation) — light haptic per second.
      Haptics.light();
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Color _urgency(BuildContext context) {
    final tokens = context.tokens;
    if (_remaining >= 3) return AppTheme.paused; // amber
    if (_remaining == 2) return AppTheme.brand; // orange
    return tokens.sos; // red
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final cs = Theme.of(context).colorScheme;
    final surface = Theme.of(context).dialogTheme.backgroundColor ?? cs.surface;
    final urgency = _urgency(context);
    final progress = (1 - _remaining.clamp(0, _start) / _start).clamp(0.0, 1.0);

    return AlertDialog(
      backgroundColor: surface,
      contentPadding: const EdgeInsets.fromLTRB(
        AppTheme.s24,
        AppTheme.s24,
        AppTheme.s24,
        AppTheme.s16,
      ),
      title: Text(L10n.tr('sending_sos', locale),
          style: TextStyle(color: cs.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  color: urgency,
                  backgroundColor: cs.onSurface.withValues(alpha: 0.12),
                ),
              ),
              Text(
                '$_remaining',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: urgency, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s16),
          Text(
            L10n.tr('alerting_contacts', locale),
            style: TextStyle(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.s20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.tokens.sos,
                foregroundColor: cs.onError,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(L10n.tr('cancel', locale)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedBounceButton({required this.child, required this.onTap});

  @override
  State<_AnimatedBounceButton> createState() => _AnimatedBounceButtonState();
}

class _AnimatedBounceButtonState extends State<_AnimatedBounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
