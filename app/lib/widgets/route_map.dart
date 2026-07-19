import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;

import 'package:mwendo_app/widgets/mwendo_map.dart';

// Re-exported so existing imports of route_map.dart keep resolving these.
export 'package:mwendo_app/widgets/mwendo_map.dart' show kDarkStyle, kDefaultCenter;

/// Static replay of a finished route, used on the activity detail screen.
///
/// This is now a thin wrapper over the shared [MwendoMap] in [MapMode.replay],
/// so the live tracking map and this replay map share the exact same drawing
/// and camera logic (and stay in sync). The camera is set once and never
/// moves; the polyline redraws whenever [points] changes.
class RouteMap extends StatelessWidget {
  final List<latlong.LatLng> points;
  final double zoom;

  const RouteMap({
    super.key,
    required this.points,
    this.zoom = 14,
  });

  @override
  Widget build(BuildContext context) {
    return MwendoMap(
      points: points,
      mode: MapMode.replay,
      zoom: zoom,
    );
  }
}
