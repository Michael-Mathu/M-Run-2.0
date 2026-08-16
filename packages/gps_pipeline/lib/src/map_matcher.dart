import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'match_provider.dart';

class OsrmMatchProvider implements MatchProvider {
  @override
  String get name => 'OSRM';

  @override
  String get version => '1.0';

  final http.Client _client;
  final String _baseUrl;
  final String _profile;
  final Duration _timeout;

  int _consecutiveFailures = 0;
  DateTime? _circuitBreakerUntil;

  final _requestQueue = Queue<_QueuedRequest>();
  bool _isProcessingQueue = false;

  OsrmMatchProvider({
    http.Client? client,
    String? baseUrl,
    String profile = 'foot',
    Duration timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _profile = profile,
        _timeout = timeout,
        _baseUrl = baseUrl ?? _getInitialBaseUrl();

  static String _getInitialBaseUrl() {
    const definedUrl = String.fromEnvironment('OSRM_BASE_URL');
    if (definedUrl.isNotEmpty) return definedUrl;
    
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease) {
      throw AssertionError('OSRM_BASE_URL must be defined in release mode.');
    }
    
    return 'https://router.project-osrm.org';
  }

  @override
  Future<bool> isAvailable() async {
    if (_circuitBreakerUntil != null && DateTime.now().isBefore(_circuitBreakerUntil!)) {
      return false;
    }
    try {
      final uri = Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<MatchResult> match(List<MatchRequest> points) async {
    if (points.isEmpty) {
      return const MatchResult(points: [], meanSnapDistanceM: 0, p95SnapDistanceM: 0, matchedCount: 0, unmatchedCount: 0, providerConfidence: 0);
    }
    
    if (points.length <= 90) {
      final completer = Completer<MatchResult>();
      _requestQueue.add(_QueuedRequest(points, completer));
      _processQueue();
      return completer.future;
    }

    // Chunking with overlap
    final results = <MatchResult>[];
    const chunkSize = 90;
    const overlap = 5;
    const stride = chunkSize - overlap;
    
    for (int i = 0; i < points.length; i += stride) {
      final end = (i + chunkSize).clamp(0, points.length);
      final chunk = points.sublist(i, end);
      
      final completer = Completer<MatchResult>();
      _requestQueue.add(_QueuedRequest(chunk, completer));
      _processQueue();
      results.add(await completer.future);
      
      if (end == points.length) break;
    }

    return _mergeChunkedResults(results, points.length, chunkSize, overlap);
  }

  MatchResult _mergeChunkedResults(List<MatchResult> chunks, int totalPoints, int chunkSize, int overlap) {
    final mergedPoints = <MatchedPoint?>[];
    int totalMatched = 0;
    int totalUnmatched = 0;
    double sumSnapDist = 0;
    final snapDists = <double>[];

    for (int c = 0; c < chunks.length; c++) {
      final chunk = chunks[c];
      final isFirstChunk = c == 0;
      final isLastChunk = c == chunks.length - 1;

      final pts = chunk.points;
      int startIdx = isFirstChunk ? 0 : 2; // Discard first 2 if not first chunk
      int endIdx = isLastChunk ? pts.length : pts.length - 3; // Discard last 3 if not last chunk (so overlap 5 -> 2 + 3)

      for (int i = startIdx; i < endIdx; i++) {
        final p = pts[i];
        mergedPoints.add(p);
        if (p != null) {
          totalMatched++;
          sumSnapDist += p.snapDistanceM;
          snapDists.add(p.snapDistanceM);
        } else {
          totalUnmatched++;
        }
      }
    }

    // Sanity check length
    while (mergedPoints.length < totalPoints) {
      mergedPoints.add(null);
      totalUnmatched++;
    }
    if (mergedPoints.length > totalPoints) {
      mergedPoints.removeRange(totalPoints, mergedPoints.length);
    }

    snapDists.sort();
    final p95 = snapDists.isNotEmpty ? snapDists[(snapDists.length * 0.95).floor().clamp(0, snapDists.length - 1)] : 0.0;
    final mean = totalMatched > 0 ? sumSnapDist / totalMatched : 0.0;
    final conf = chunks.isNotEmpty ? chunks.map((c) => c.providerConfidence).reduce((a,b) => a + b) / chunks.length : 0.0;

    return MatchResult(
      points: mergedPoints,
      meanSnapDistanceM: mean,
      p95SnapDistanceM: p95,
      matchedCount: totalMatched,
      unmatchedCount: totalUnmatched,
      providerConfidence: conf,
    );
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue || _requestQueue.isEmpty) return;
    _isProcessingQueue = true;

    try {
      while (_requestQueue.isNotEmpty) {
        final request = _requestQueue.removeFirst();

        if (_circuitBreakerUntil != null && DateTime.now().isBefore(_circuitBreakerUntil!)) {
          request.completer.completeError(StateError('OSRM provider unavailable (circuit breaker open)'));
          continue;
        }

        try {
          final result = await _executeWithRetry(request.points);
          _consecutiveFailures = 0;
          _circuitBreakerUntil = null;
          request.completer.complete(result);
        } catch (e) {
          _consecutiveFailures++;
          if (_consecutiveFailures >= 5) {
            _circuitBreakerUntil = DateTime.now().add(const Duration(minutes: 10));
          }
          request.completer.completeError(e);
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<MatchResult> _executeWithRetry(List<MatchRequest> points) async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        return await _doRequest(points);
      } catch (e) {
        attempts++;
        if (attempts >= 3) rethrow;
        await Future.delayed(Duration(seconds: 1 << (attempts - 1))); // 1s, 2s
      }
    }
    throw StateError('OSRM request failed after retries');
  }

  Future<MatchResult> _doRequest(List<MatchRequest> requests) async {
    final coords = requests.map((r) => '${r.lng},${r.lat}').join(';');
    final uri = Uri.parse(
            '${_baseUrl.replaceFirst(RegExp(r'/$'), '')}/match/v1/$_profile/$coords')
        .replace(queryParameters: {
      'timestamps': requests
          .map((r) => r.timestamp.millisecondsSinceEpoch ~/ 1000)
          .join(';'),
      'radiuses':
          requests.map((r) => r.accuracyM.clamp(5, 100).round()).join(';'),
      'tidy': 'true',
      'overview': 'false',
    });

    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body);
    if (body is! Map || body['code'] != 'Ok' || body['tracepoints'] is! List) {
       throw const FormatException('Invalid OSRM response format');
    }

    final tracepoints = body['tracepoints'] as List;
    if (tracepoints.length != requests.length) {
      throw const FormatException('OSRM returned incorrect number of tracepoints');
    }

    int matchedCount = 0;
    int unmatchedCount = 0;
    double sumSnapDist = 0;
    final snapDists = <double>[];
    final matchedPoints = <MatchedPoint?>[];

    for (var tp in tracepoints) {
      if (tp is! Map || tp['location'] is! List) {
        matchedPoints.add(null);
        unmatchedCount++;
        continue;
      }
      final l = tp['location'] as List;
      if (l.length < 2 || l[0] is! num || l[1] is! num) {
        matchedPoints.add(null);
        unmatchedCount++;
        continue;
      }
      
      final waypointName = tp['name'] as String?;
      final distance = (tp['distance'] as num?)?.toDouble() ?? 0.0;
      
      matchedPoints.add(MatchedPoint(
        lat: (l[1] as num).toDouble(),
        lng: (l[0] as num).toDouble(),
        wayId: waypointName?.isNotEmpty == true ? waypointName : null,
        snapDistanceM: distance,
      ));
      matchedCount++;
      sumSnapDist += distance;
      snapDists.add(distance);
    }

    snapDists.sort();
    final p95 = snapDists.isNotEmpty ? snapDists[(snapDists.length * 0.95).floor().clamp(0, snapDists.length - 1)] : 0.0;
    final mean = matchedCount > 0 ? sumSnapDist / matchedCount : 0.0;

    return MatchResult(
      points: matchedPoints,
      meanSnapDistanceM: mean,
      p95SnapDistanceM: p95,
      matchedCount: matchedCount,
      unmatchedCount: unmatchedCount,
      providerConfidence: body['matchings'] != null ? 0.8 : 0.5, // Rough proxy for now
    );
  }

  void close() => _client.close();
}

class _QueuedRequest {
  final List<MatchRequest> points;
  final Completer<MatchResult> completer;

  _QueuedRequest(this.points, this.completer);
}
