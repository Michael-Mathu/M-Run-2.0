import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:mwendo_app/core/l10n/app_strings.dart';
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/features/beat/ghost_race_controller.dart';
import 'package:mwendo_app/features/beat/ghost_race_utils.dart';
import 'package:mwendo_app/features/learn/data/beat_legends.dart';

/// Free, key-less, globally-available Carto dark basemap. Works everywhere.
const kDarkStyle =
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

/// Default map centre (Nairobi) used before the first GPS fix arrives.
const kDefaultCenter = latlong.LatLng(-1.2921, 36.8219);

const _kRouteColor = '#FE2E4B';
const _kRouteWidth = 6.0;
const _kRouteOpacity = 0.95;
const _kRouteBlur = 0.5;

const _kGhostRouteColor = '#FFFF5A1F';
const _kGhostRouteWidth = 4.0;
const _kGhostRouteOpacity = 0.7;
const _kGhostMarkerColor = '#FFFF5A1F';

/// How the [MwendoMap] behaves.
enum MapMode { live, replay }

class MwendoMap extends StatefulWidget {
  final List<latlong.LatLng> points;
  final MapMode mode;
  final double zoom;
  final bool locationEnabled;
  final bool isRecording;
  final String styleString;
  final GhostPace? ghost;
  final double userDistanceM;
  final GhostRaceState? raceState;

  const MwendoMap({
    super.key,
    required this.points,
    this.mode = MapMode.replay,
    this.zoom = 14,
    this.locationEnabled = false,
    this.isRecording = false,
    this.styleString = kDarkStyle,
    this.ghost,
    this.userDistanceM = 0,
    this.raceState,
  });

  @override
  State<MwendoMap> createState() => _MwendoMapState();
}

class _MwendoMapState extends State<MwendoMap> {
  MapLibreMapController? _ctrl;
  Line? _line;
  Line? _ghostLine;
  Symbol? _ghostMarker;

  bool _isSyncing = false;
  List<latlong.LatLng>? _pendingCoords;

  bool _autoFollow = true;
  bool _firstFixDone = false;
  bool _styleLoaded = false;

  bool get _isLive => widget.mode == MapMode.live;

  @override
  void didUpdateWidget(covariant MwendoMap old) {
    super.didUpdateWidget(old);
    if (old.points.length > widget.points.length) {
      _autoFollow = true;
      _firstFixDone = false;
    }
    if (widget.points.length != old.points.length) {
      if (_isLive && !_firstFixDone && widget.points.isNotEmpty) {
        _firstFixDone = true;
        _autoFollow = true;
        _ctrl?.animateCamera(
          CameraUpdate.newLatLngZoom(_toMlLatLng(widget.points.first), 16),
        );
      }
      _syncRoute();
    }
    if (widget.ghost != old.ghost ||
        widget.userDistanceM != old.userDistanceM ||
        widget.raceState != old.raceState) {
      _syncGhostOverlay();
    }
  }

  void _syncRoute() {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    if (widget.points.length < 2) {
      _clearLine();
      return;
    }
    final coords = _toMlLatLngList(widget.points);

    if (_isSyncing) {
      _pendingCoords = widget.points;
      return;
    }

    _isSyncing = true;
    _drawRoute(coords).whenComplete(() {
      _isSyncing = false;
      if (!mounted) return;
      final pending = _pendingCoords;
      if (pending != null) {
        _pendingCoords = null;
        _syncRoute();
      }
    });
  }

  LatLng _toMlLatLng(latlong.LatLng ll) => LatLng(ll.latitude, ll.longitude);

  List<LatLng> _toMlLatLngList(List<latlong.LatLng> points) {
    return points.map(_toMlLatLng).toList();
  }

  Future<void> _clearLine() async {
    final ctrl = _ctrl;
    if (ctrl == null || _line == null) return;
    final toRemove = _line!;
    _line = null;
    try {
      await ctrl.removeLine(toRemove);
    } catch (_) {}
  }

  Future<void> _drawRoute(List<LatLng> coords) async {
    final ctrl = _ctrl;
    if (ctrl == null || coords.length < 2) return;

    if (_line != null) {
      try {
        await ctrl.updateLine(_line!, LineOptions(geometry: coords));
      } catch (_) {
        if (!mounted || _ctrl == null) return;
        try {
          await ctrl.removeLine(_line!);
        } catch (_) {}
        if (!mounted || _ctrl == null) return;
        _line = await ctrl.addLine(_routeOptions(coords));
      }
    } else {
      _line = await ctrl.addLine(_routeOptions(coords));
    }

    if (!mounted || _ctrl == null) return;

    if (_isLive && _autoFollow && !widget.isRecording) {
      await ctrl.animateCamera(CameraUpdate.newLatLng(coords.last));
    }
  }

  LineOptions _routeOptions(List<LatLng> coords) => LineOptions(
        geometry: coords,
        lineColor: _kRouteColor,
        lineWidth: _kRouteWidth,
        lineOpacity: _kRouteOpacity,
        lineBlur: _kRouteBlur,
      );

  Future<void> _syncGhostOverlay() async {
    final ctrl = _ctrl;
    if (ctrl == null || widget.ghost == null || !_isLive) return;

    final ghost = widget.ghost!;
    final routePoints = widget.points;
    if (routePoints.length < 2) return;

    if (_ghostLine == null) {
      _ghostLine = await ctrl.addLine(LineOptions(
        geometry: _toMlLatLngList(routePoints),
        lineColor: _kGhostRouteColor,
        lineWidth: _kGhostRouteWidth,
        lineOpacity: _kGhostRouteOpacity,
        linePattern: 'dash',
      ));
    }

    final ghostPos = computeGhostPosition(
      ghost,
      widget.userDistanceM,
      routePoints,
    );

    if (ghostPos != null) {
      if (_ghostMarker == null) {
        _ghostMarker = await ctrl.addSymbol(SymbolOptions(
          geometry: _toMlLatLng(ghostPos),
          iconImage: 'marker',
          iconSize: 1.2,
          iconColor: _kGhostMarkerColor,
          iconHaloColor: '#FFFFFF',
          iconHaloWidth: 2,
          iconHaloBlur: 4,
        ));
      } else {
        await ctrl.updateSymbol(_ghostMarker!, SymbolOptions(
          geometry: _toMlLatLng(ghostPos),
        ));
        final pulse = 1.0 + 0.3 * math.sin(DateTime.now().millisecondsSinceEpoch / 300);
        await ctrl.updateSymbol(_ghostMarker!, SymbolOptions(
          iconSize: 1.2 * pulse,
        ));
      }
    }
  }

  MyLocationTrackingMode get _trackingMode {
    if (!widget.locationEnabled || !_styleLoaded || widget.points.isEmpty) {
      return MyLocationTrackingMode.none;
    }
    if (!_isLive || !_autoFollow) return MyLocationTrackingMode.none;
    return MyLocationTrackingMode.tracking;
  }

  void _recenter() {
    setState(() => _autoFollow = true);
    final ctrl = _ctrl;
    if (ctrl != null && widget.points.isNotEmpty) {
      ctrl.animateCamera(CameraUpdate.newLatLng(_toMlLatLng(widget.points.last)));
    }
  }

  @override
  void dispose() {
    if (_line != null) _ctrl?.removeLine(_line!);
    if (_ghostLine != null) _ctrl?.removeLine(_ghostLine!);
    if (_ghostMarker != null) _ctrl?.removeSymbol(_ghostMarker!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLive && widget.points.length < 2) {
      return _EmptyRoutePlaceholder();
    }

    final initialTarget = widget.points.isNotEmpty
        ? _toMlLatLng(widget.points.last)
        : _toMlLatLng(kDefaultCenter);

    final map = MapLibreMap(
      key: ValueKey('mwendo-map-${widget.locationEnabled}'),
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: _isLive ? 12 : widget.zoom,
      ),
      styleString: kDarkStyle,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
      myLocationEnabled: widget.locationEnabled && _styleLoaded && widget.points.isNotEmpty,
      myLocationTrackingMode: _trackingMode,
      onMapCreated: (c) {
        _ctrl = c;
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_styleLoaded) {
            _styleLoaded = true;
            setState(() {});
          }
        });
      },
      onStyleLoadedCallback: () {
        _styleLoaded = true;
        _line = null;
        _ghostLine = null;
        _ghostMarker = null;
        _syncRoute();
        if (mounted) setState(() {});
      },
      onCameraTrackingDismissed: () {
        if (mounted) setState(() => _autoFollow = false);
      },
      onUserLocationUpdated: _isLive
          ? (userLocation) {
              if (_ctrl != null && !_firstFixDone) {
                _firstFixDone = true;
                _ctrl!.animateCamera(
                  CameraUpdate.newLatLngZoom(userLocation.position, 16),
                );
              }
            }
          : null,
    );

    return Stack(
      children: [
        map,
        if (!_styleLoaded)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        Positioned(
          right: AppTheme.s16,
          bottom: (_isLive && !_autoFollow) ? 72 : AppTheme.s16,
          child: _ZoomControls(
            onIn: () => _ctrl?.animateCamera(CameraUpdate.zoomIn()),
            onOut: () => _ctrl?.animateCamera(CameraUpdate.zoomOut()),
          ),
        ),
        if (_isLive && !_autoFollow)
          Positioned(
            right: AppTheme.s16,
            bottom: AppTheme.s16,
            child: _RecenterButton(onTap: _recenter),
          ),
      ],
    );
  }
}

class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Re-center map',
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onIn;
  final VoidCallback onOut;
  const _ZoomControls({required this.onIn, required this.onOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZoomButton(icon: Icons.add_rounded, onTap: onIn),
        const SizedBox(height: AppTheme.s8),
        _ZoomButton(icon: Icons.remove_rounded, onTap: onOut),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Zoom',
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _EmptyRoutePlaceholder extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.2, -0.3),
          radius: 1.4,
          colors: [Color(0xFF1B2733), Color(0xFF0B0B0C)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_outlined, size: 40, color: Colors.white24),
            const SizedBox(height: AppTheme.s8),
            Text(ref.tr('no_route_recorded'), style: const TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}