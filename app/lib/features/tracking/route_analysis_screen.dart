import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mwendo_app/core/theme/app_theme.dart';
import 'package:mwendo_app/data/repositories/activity_repository.dart';
import 'package:mwendo_app/widgets/mwendo_map.dart';
import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:mwendo_app/features/tracking/tracking_controller.dart';
import 'package:mwendo_gps_engine/mwendo_gps_engine.dart';

class RouteAnalysisScreen extends ConsumerStatefulWidget {
  final String runId;

  const RouteAnalysisScreen({super.key, required this.runId});

  @override
  ConsumerState<RouteAnalysisScreen> createState() => _RouteAnalysisScreenState();
}

class _RouteAnalysisScreenState extends ConsumerState<RouteAnalysisScreen> {
  bool _isLoading = true;
  List<DisplaySegment> _segments = [];
  List<latlong.LatLng> _rawPoints = [];
  SessionQualityReport? _report;
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    _loadAndProcess();
  }

  Future<void> _loadAndProcess() async {
    final repo = await ref.read(activityRepositoryProvider.future);
    final run = await repo.get(widget.runId);
    if (run == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final pipeline = GpsPipeline(profile: ActivityProfile.run, enableMapMatching: true);
    final results = await pipeline.reprocessAsync(run.rawFixes);

    _report = SessionQualityReport.compute(results);

    final segments = <DisplaySegment>[];
    for (final res in results) {
      if (res.isAccepted) {
        final pt = TrackPoint(
          lat: res.smoothedLat ?? res.raw.lat,
          lng: res.smoothedLng ?? res.raw.lng,
          elevation: res.raw.elevation,
          timestamp: res.raw.timestamp,
          speedMps: res.raw.speedMps,
          accuracy: res.raw.accuracy,
          isMocked: res.raw.isMocked,
          fixType: res.raw.fixType,
          state: res.filterStatus.name,
        );
        if (segments.isEmpty || segments.last.type != res.filterStatus) {
          segments.add(DisplaySegment(points: [pt], type: res.filterStatus));
        } else {
          segments.last.points.add(pt);
        }
      }
    }

    final rawPoints = run.rawFixes.map((f) => latlong.LatLng(f.lat, f.lng)).toList();

    if (mounted) {
      setState(() {
        _segments = segments;
        _rawPoints = rawPoints;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Analysis'),
        actions: [
          IconButton(
            icon: Icon(_showRaw ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showRaw = !_showRaw),
            tooltip: 'Toggle Raw Points',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      MwendoMap(
                        points: [
                          for (final seg in _segments)
                            for (final p in seg.points)
                              latlong.LatLng(p.lat, p.lng)
                        ],
                        mode: MapMode.replay,
                        locationEnabled: false,
                        isRecording: false,
                      ),
                      if (_showRaw)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black87,
                            child: Text(
                              'Raw Points: ${_rawPoints.length}\nTo display raw points on map, MwendoMap widget needs to be updated to support an overlay layer.',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _report == null
                      ? const SizedBox()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text('Session Quality Report', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            _StatRow('Rejection Rate', '${_report!.rejectionRatePct.toStringAsFixed(1)}%'),
                            _StatRow('Median Accuracy', '${_report!.medianAccuracyM.toStringAsFixed(1)}m'),
                            _StatRow('95th %ile Accuracy', '${_report!.p95AccuracyM.toStringAsFixed(1)}m'),
                            _StatRow('Signal Gaps', '${_report!.signalGapCount}'),
                            _StatRow('Spikes (Jumps/km)', '${_report!.jumpsPerKm}'),
                            _StatRow('Stationary Clusters', '${_report!.stationaryClusterCount}'),
                            _StatRow('Filtered Distance', '${(_report!.filteredDistanceM / 1000).toStringAsFixed(2)}km'),
                            _StatRow('Raw Distance', '${(_report!.rawDistanceM / 1000).toStringAsFixed(2)}km'),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: AppTheme.brand)),
        ],
      ),
    );
  }
}
