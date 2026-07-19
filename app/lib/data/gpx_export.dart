import 'dart:convert';

import 'package:mwendo_app/data/models/run_record.dart';

/// Serialise a [RunRecord] to a GPX 1.1 track file. Emits elevation, a UTC
/// `<time>` per point, and `<speed>` (m/s, derived from the stored pace) so the
/// export round-trips the timing/speed the app actually recorded.
String gpxFromRunRecord(RunRecord r) {
  final pts = StringBuffer();
  for (int i = 0; i < r.route.length; i++) {
    final p = r.route[i];
    final ele = i < r.elevation.length ? r.elevation[i] : 0.0;
    final time = i < r.times.length ? r.times[i].toUtc().toIso8601String() : '';
    // pace is min/km; speed in m/s = 1000 / (pace * 60).
    final pace = i < r.pace.length ? r.pace[i] : 0.0;
    final speed = pace > 0 ? (1000 / (pace * 60)) : 0.0;
    final eleXml = '<ele>${ele.toStringAsFixed(1)}</ele>';
    final timeXml = time.isNotEmpty ? '<time>$time</time>' : '';
    final speedXml = '<speed>${speed.toStringAsFixed(2)}</speed>';
    pts.writeln(
        '      <trkpt lat="${p.latitude}" lon="${p.longitude}">$eleXml$timeXml$speedXml</trkpt>');
  }
  final start = r.startedAt.toUtc().toIso8601String();
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Mwendo" xmlns="http://www.topografix.com/GPX/1/1">
  <metadata>
    <name>${_escape(r.type)}</name>
    <time>$start</time>
  </metadata>
  <trk>
    <name>${_escape(r.type)}</name>
    <trkseg>
$pts
    </trkseg>
  </trk>
</gpx>
''';
}

/// Serialise several [RunRecord]s to a single JSON document.
String jsonFromRuns(List<RunRecord> runs) =>
    jsonEncode(runs.map((r) => r.toJson()).toList());

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

typedef GpxPoint = ({
  double lat,
  double lng,
  double ele,
  DateTime? time,
  double speed,
});

/// Decode a GPX track string into points with elevation, time and speed
/// (best-effort; mirrors what [gpxFromRunRecord] emits) so an export can be
/// round-tripped without losing timing/speed.
List<GpxPoint> pointsFromGpx(String gpx) {
  final out = <GpxPoint>[];
  final trkpt = RegExp(r'<trkpt[^>]*lat="([-\d.]+)"[^>]*lon="([-\d.]+)"(.*?)</trkpt>');
  for (final m in trkpt.allMatches(gpx)) {
    final lat = double.tryParse(m.group(1)!);
    final lng = double.tryParse(m.group(2)!);
    if (lat == null || lng == null) continue;
    final body = m.group(3) ?? '';
    final ele = double.tryParse(
        RegExp(r'<ele>([-\d.]+)').firstMatch(body)?.group(1) ?? '');
    final speed = double.tryParse(
        RegExp(r'<speed>([-\d.]+)').firstMatch(body)?.group(1) ?? '');
    final timeStr = RegExp(r'<time>([^<]+)').firstMatch(body)?.group(1);
    out.add((
      lat: lat,
      lng: lng,
      ele: ele ?? 0.0,
      time: timeStr != null ? DateTime.tryParse(timeStr) : null,
      speed: speed ?? 0.0,
    ));
  }
  return out;
}
