import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../models/run_record.dart';

class ActivityRepository {
  final AppDatabase _db;
  final File? _jsonFile;

  ActivityRepository(this._db, this._jsonFile);

  Future<List<RunRecord>> list() async {
    try {
      final runs = await _db.getAllRuns();
      if (runs.isNotEmpty) return runs;
    } catch (e) {
      debugPrint('DB list error, falling back to JSON: $e');
    }
    return _migrateFromJson();
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

  Future<List<RunRecord>> _migrateFromJson() async {
    try {
      final file = _jsonFile;
      if (file == null || !await file.exists()) return [];
      final raw = await file.readAsString();
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final runs = list.map(RunRecord.fromJson).toList();
      
      for (final run in runs) {
        try {
          await _db.saveRun(run);
        } catch (_) {}
      }
      
      final backup = File('${file.path}.bak');
      await file.rename(backup.path);
      
      return runs;
    } catch (_) {
      return [];
    }
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final activityRepositoryProvider = FutureProvider<ActivityRepository>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  if (kIsWeb) {
    return ActivityRepository(db, null);
  }
  final dir = await getApplicationDocumentsDirectory();
  final jsonFile = File(p.join(dir.path, 'activities.json'));
  return ActivityRepository(db, jsonFile);
});

final activitiesProvider = FutureProvider<List<RunRecord>>((ref) async {
  final repo = await ref.watch(activityRepositoryProvider.future);
  return repo.list();
});

final activityByIdProvider =
    FutureProvider.family<RunRecord?, String>((ref, id) async {
  final repo = await ref.watch(activityRepositoryProvider.future);
  return repo.get(id);
});