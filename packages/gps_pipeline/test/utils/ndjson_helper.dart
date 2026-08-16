import 'dart:convert';
import 'dart:io';
import 'package:gps_pipeline/gps_pipeline.dart';

class NdjsonHelper {
  static List<RawFix> readFixes(String path) {
    final lines = File(path).readAsLinesSync();
    return lines.where((line) => line.trim().isNotEmpty).map((line) {
      final json = jsonDecode(line) as Map<String, dynamic>;
      return RawFix(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        elevation: (json['elevation'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
        speedMps: (json['speedMps'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toInt(),
        isMocked: json['isMocked'] as bool? ?? false,
      );
    }).toList();
  }

  static void writeFixes(String path, List<RawFix> fixes) {
    final file = File(path);
    final buffer = StringBuffer();
    for (final fix in fixes) {
      buffer.writeln(jsonEncode({
        'lat': fix.lat,
        'lng': fix.lng,
        'elevation': fix.elevation,
        'timestamp': fix.timestamp.toUtc().toIso8601String(),
        'speedMps': fix.speedMps,
        'accuracy': fix.accuracy,
        'isMocked': fix.isMocked,
      }));
    }
    file.writeAsStringSync(buffer.toString());
  }
}
