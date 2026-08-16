import 'package:drift/drift.dart';
import 'package:gps_pipeline/gps_pipeline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection/connection.dart' as impl;
import 'tables.dart';
import '../models/run_record.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

@DriftDatabase(tables: [Users, Activities, ActivityPoints, SessionDrafts, SessionPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(impl.connect());
  static AppDatabase? _instance;
  factory AppDatabase() => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(activityPoints, activityPoints.accuracy);
            await m.addColumn(activityPoints, activityPoints.hdop);
            await m.addColumn(activityPoints, activityPoints.satelliteCount);
            await m.addColumn(activityPoints, activityPoints.provider);
            await m.addColumn(activityPoints, activityPoints.isMocked);
            await m.addColumn(activityPoints, activityPoints.fixType);
            await m.addColumn(activityPoints, activityPoints.state);
          }
          if (from < 3) {
            await m.addColumn(activities, activities.metricSource);
            await m.createTable(sessionDrafts);
            await m.createTable(sessionPoints);
          }
        },
      );

  Future<List<RunRecord>> getAllRuns() async {
    final activityMaps = await select(activities).get();
    final runs = <RunRecord>[];
    for (final a in activityMaps) {
      final points = await (select(activityPoints)..where((pt) => pt.activityId.equals(a.id))).get();
      runs.add(_runRecordFromActivity(a, points));
    }
    runs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return runs;
  }

  Future<RunRecord?> getRun(String id) async {
    final a = await (select(activities)..where((t) => t.id.equals(id))).get().then((l) => l.firstOrNull);
    if (a == null) return null;
    final points = await (select(activityPoints)..where((pt) => pt.activityId.equals(id))).get();
    return _runRecordFromActivity(a, points);
  }

  RunRecord _runRecordFromActivity(Activity activity, List<ActivityPoint> points) {
    final pts = points.toList(growable: false);
    return RunRecord.fromLegacy(
      id: activity.id,
      type: activity.type,
      startedAt: activity.startedAt,
      distanceM: activity.distanceM,
      durationMs: activity.durationMs,
      movingTimeMs: activity.movingTimeMs,
      calories: activity.calories,
      elevationGainM: activity.elevationGainM,
      avgHeartRate: activity.avgHeartRate,
      avgCadence: activity.avgCadence,
      rawFixes: pts.map((pt) => RawFix(
        lat: pt.lat,
        lng: pt.lng,
        elevation: pt.elevation,
        timestamp: pt.timestamp,
        speedMps: pt.pace > 0 ? 1000 / (pt.pace * 60) : 0.0,
        accuracy: (pt.accuracy ?? 10.0).toInt(),
        hdop: pt.hdop,
        satelliteCount: pt.satelliteCount,
        provider: pt.provider,
        isMocked: pt.isMocked,
        fixType: pt.fixType ?? 'unknown',
      )).toList(),
    );
  }

  Future<void> saveRun(RunRecord record) async {
    await into(activities).insertOnConflictUpdate(ActivitiesCompanion(
      id: Value(record.id),
      userId: const Value('local'),
      type: Value(record.type),
      startedAt: Value(record.startedAt),
      distanceM: Value(record.distanceM),
      durationMs: Value(record.durationMs),
      movingTimeMs: Value(record.movingTimeMs),
      calories: Value(record.calories),
      elevationGainM: Value(record.elevationGainM),
      avgHeartRate: Value(record.avgHeartRate),
      avgCadence: Value(record.avgCadence),
    ));

    await (delete(activityPoints)..where((pt) => pt.activityId.equals(record.id))).go();

    final pointCompanions = <ActivityPointsCompanion>[];
    for (int i = 0; i < record.rawFixes.length; i++) {
      final fix = record.rawFixes[i];
      pointCompanions.add(ActivityPointsCompanion(
        activityId: Value(record.id),
        pointIndex: Value(i),
        lat: Value(fix.lat),
        lng: Value(fix.lng),
        elevation: Value(fix.elevation),
        pace: Value(fix.speedMps > 0.3 ? 1000 / (fix.speedMps * 60) : 0.0),
        timestamp: Value(fix.timestamp),
        accuracy: Value(fix.accuracy.toInt()),
        hdop: Value(fix.hdop),
        satelliteCount: Value(fix.satelliteCount),
        provider: Value(fix.provider),
        isMocked: Value(fix.isMocked),
        fixType: Value(fix.fixType),
      ));
    }
    await batch((b) => b.insertAll(activityPoints, pointCompanions));
  }

  Future<void> deleteRun(String id) async {
    await (delete(activityPoints)..where((pt) => pt.activityId.equals(id))).go();
    await (delete(activities)..where((a) => a.id.equals(id))).go();
  }
}