import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../models/run_record.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'mwendo.db'));
    return NativeDatabase(dbFile);
  });
}

@DriftDatabase(tables: [Users, Activities, ActivityPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  static AppDatabase? _instance;
  factory AppDatabase() => _instance ??= AppDatabase._();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {},
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
    return RunRecord(
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
      route: pts.map((pt) => maplibre.LatLng(pt.lat, pt.lng)).toList(),
      elevation: pts.map((pt) => pt.elevation).toList(),
      pace: pts.map((pt) => pt.pace).toList(),
      times: pts.map((pt) => pt.timestamp).toList(),
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
    for (int i = 0; i < record.route.length; i++) {
      final latLng = record.route[i];
      pointCompanions.add(ActivityPointsCompanion(
        activityId: Value(record.id),
        pointIndex: Value(i),
        lat: Value(latLng.latitude),
        lng: Value(latLng.longitude),
        elevation: Value(record.elevation.length > i ? record.elevation[i] : 0),
        pace: Value(record.pace.length > i ? record.pace[i] : 0),
        timestamp: Value(record.times.length > i ? record.times[i] : DateTime.now()),
      ));
    }
    await batch((b) => b.insertAll(activityPoints, pointCompanions));
  }

  Future<void> deleteRun(String id) async {
    await (delete(activityPoints)..where((pt) => pt.activityId.equals(id))).go();
    await (delete(activities)..where((a) => a.id.equals(id))).go();
  }
}