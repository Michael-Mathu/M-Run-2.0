import 'package:xml/xml.dart';

class GpxParser {
  Future<GpxParseResult> parseGpx(String xmlString) async {
    final xmlDoc = XmlDocument.parse(xmlString);
    final trackpoints = <GpxTrackpoint>[];

    final trkpts = xmlDoc.findAllElements('trkpt');
    for (final trkpt in trkpts) {
      final lat = double.parse(trkpt.getAttribute('lat') ?? '0');
      final lng = double.parse(trkpt.getAttribute('lon') ?? '0');
      final time = trkpt.getElement('time')?.innerText ?? '';
      final elev = trkpt.getElement('ele')?.innerText ?? '0';

      trackpoints.add(GpxTrackpoint(
        lat: lat,
        lng: lng,
        elevation: double.parse(elev),
        timestamp: DateTime.parse(time),
      ));
    }

    return GpxParseResult(trackpoints: trackpoints);
  }

  String generateGpx(GpxParseResult result) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0"?>');
    buffer.writeln('<gpx version="1.1" creator="Mwendo">');
    buffer.writeln('  <trk>');
    buffer.writeln('    <trkseg>');
    for (final tp in result.trackpoints) {
      buffer.writeln('      <trkpt lat="${tp.lat}" lon="${tp.lng}">');
      buffer.writeln('        <ele>${tp.elevation}</ele>');
      buffer.writeln('        <time>${tp.timestamp.toIso8601String()}</time>');
      buffer.writeln('      </trkpt>');
    }
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    return buffer.toString();
  }
}

class GpxParseResult {
  final List<GpxTrackpoint> trackpoints;
  GpxParseResult({required this.trackpoints});
}

class GpxTrackpoint {
  final double lat;
  final double lng;
  final double elevation;
  final DateTime timestamp;

  GpxTrackpoint({
    required this.lat,
    required this.lng,
    required this.elevation,
    required this.timestamp,
  });
}