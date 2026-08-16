import 'package:gps_pipeline/gps_pipeline.dart';

enum PostProcessingStatus { pending, matching, matched, failed, skipped }

class SessionDraft {
  final String id;
  final List<RawFix> rawFixes;
  final List<PipelineResult> filteredResults;
  final TrackVersion filterVersion;
  final ActivityProfile activityType;
  final double filteredDistanceM;
  final int durationMs;
  final int movingTimeMs;
  final double elevationGainM;
  final int calories;
  final PostProcessingStatus status;
  final String? matchStatus;
  final double? matchedDistanceM;
  final SessionQualityReport qualityReport;
  final DateTime createdAt;

  SessionDraft({
    required this.id,
    required this.rawFixes,
    required this.filteredResults,
    required this.filterVersion,
    required this.activityType,
    required this.filteredDistanceM,
    required this.durationMs,
    required this.movingTimeMs,
    required this.elevationGainM,
    required this.calories,
    required this.status,
    this.matchStatus,
    this.matchedDistanceM,
    required this.qualityReport,
    required this.createdAt,
  });
}
