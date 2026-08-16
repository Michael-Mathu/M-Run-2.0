import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// OSRM's /match endpoint performs the HMM; this config controls the adapter.
class MapMatcherConfig {
  final bool enabled;
  final String baseUrl;
  final String profile;
  final int chunkSize;
  final Duration timeout;
  final double maxAccuracyM;
  final bool tidy;

  const MapMatcherConfig({
    this.enabled = false,
    this.baseUrl = 'https://router.project-osrm.org',
    this.profile = 'foot',
    this.chunkSize = 90,
    this.timeout = const Duration(seconds: 15),
    this.maxAccuracyM = 100,
    this.tidy = true,
  });
}

class MapMatcher {
  final MapMatcherConfig config;
  final http.Client _client;

  MapMatcher({bool enabled = false, MapMatcherConfig? config, http.Client? client})
      : config = config ?? MapMatcherConfig(enabled: enabled),
        _client = client ?? http.Client();

  /// Intentionally a pass-through: network HMM matching belongs post-session.
  PipelineResult process(PipelineResult result) => result;

  /// Post-session bulk map matching via OSRM.
  Future<List<PipelineResult>> matchBatch(List<PipelineResult> results) async {
    if (!config.enabled) return results;
    final output = List<PipelineResult>.from(results);
    final accepted = <int>[];
    for (var i = 0; i < results.length; i++) {
      final r = results[i];
      if (r.isAccepted && r.filterStatus != FilterStatus.gapLong &&
          r.raw.accuracy <= config.maxAccuracyM) accepted.add(i);
    }
    if (accepted.length < 2) return output;

    final size = config.chunkSize.clamp(2, 100);
    for (var start = 0; start < accepted.length; start += size - 1) {
      final end = (start + size).clamp(0, accepted.length);
      final indexes = accepted.sublist(start, end);
      final points = await _request(results, indexes);
      if (points != null) {
        for (var j = 0; j < points.length; j++) {
          final p = points[j];
          if (p == null) continue;
          final original = results[indexes[j]];
          output[indexes[j]] = PipelineResult(
            raw: original.raw, filterStatus: FilterStatus.filtered,
            rejectReason: original.rejectReason,
            innovationDistance: original.innovationDistance,
            smoothedLat: p.lat, smoothedLng: p.lng,
          );
        }
      }
      if (end == accepted.length) break;
    }
    return output;
  }

  Future<List<_Point?>?> _request(List<PipelineResult> results, List<int> indexes) async {
    final coords = indexes.map((i) {
      final r = results[i];
      return '${r.smoothedLng ?? r.raw.lng},${r.smoothedLat ?? r.raw.lat}';
    }).join(';');
    final uri = Uri.parse('${config.baseUrl.replaceFirst(RegExp(r'/$'), '')}/match/v1/${config.profile}/$coords').replace(queryParameters: {
      'timestamps': indexes.map((i) => results[i].raw.timestamp.millisecondsSinceEpoch ~/ 1000).join(';'),
      'radiuses': indexes.map((i) => results[i].raw.accuracy.clamp(5, 100)).join(';'),
      'tidy': config.tidy.toString(), 'overview': 'false',
    });
    try {
      final response = await _client.get(uri).timeout(config.timeout);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map || body['code'] != 'Ok' || body['tracepoints'] is! List) return null;
      final tracepoints = body['tracepoints'] as List;
      if (tracepoints.length != indexes.length) return null;
      return tracepoints.map<_Point?>((tp) {
        if (tp is! Map || tp['location'] is! List) return null;
        final l = tp['location'] as List;
        if (l.length < 2 || l[0] is! num || l[1] is! num) return null;
        return _Point(lat: (l[1] as num).toDouble(), lng: (l[0] as num).toDouble());
      }).toList();
    } on TimeoutException { return null; } on FormatException { return null; } on http.ClientException { return null; }
  }

  void close() => _client.close();
}

class _Point { final double lat; final double lng; const _Point({required this.lat, required this.lng}); }
