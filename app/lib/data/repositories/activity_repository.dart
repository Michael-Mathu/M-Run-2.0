import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/run_record.dart';

class ActivityRepository {
  final AppDatabase _db;
  ActivityRepository(this._db);

  Future<List<RunRecord>> list() async {
    try {
      final runs = await _db.getAllRuns();
      return runs;
    } catch (e) {
      debugPrint('DB list error: $e');
      return [];
    }
  }

  Future<RunRecord?> get(String id) async {
    try {
      return await _db.getRun(id);
    } catch (e) {
      debugPrint('DB get error: $e');
      return null;
    }
  }

  Future<void> save(RunRecord record) async {
    try {
      await _db.saveRun(record);
      debugPrint('Saved run to DB: ${record.id}');
    } catch (e, st) {
      debugPrint('DB save failed: $e\n$st');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.deleteRun(id);
    } catch (e) {
      debugPrint('DB delete error: $e');
    }
  }

}

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ActivityRepository(db);
});

final activitiesProvider = FutureProvider<List<RunRecord>>((ref) async {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.list();
});

final activityByIdProvider =
    FutureProvider.family<RunRecord?, String>((ref, id) async {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.get(id);
});