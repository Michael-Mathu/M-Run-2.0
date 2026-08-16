import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:mwendo_app/data/database/app_database.dart';
import 'package:mwendo_app/data/models/session_draft.dart';

final sessionDraftRepositoryProvider = Provider<SessionDraftRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionDraftRepository(db);
});

class SessionDraftRepository {
  final AppDatabase _db;

  SessionDraftRepository(this._db);

  Future<void> saveDraft(SessionDraft draft) async {
    await _db.into(_db.sessionDrafts).insertOnConflictUpdate(SessionDraftsCompanion(
      id: Value(draft.id),
      status: Value(draft.status.name),
      filterVersion: Value(draft.filterVersion.id),
      distanceM: Value(draft.filteredDistanceM),
      durationMs: Value(draft.durationMs),
      movingTimeMs: Value(draft.movingTimeMs),
      elevationGainM: Value(draft.elevationGainM),
      calories: Value(draft.calories),
      createdAt: Value(draft.createdAt),
      matchStatus: Value(draft.matchStatus),
      matchedDistanceM: Value(draft.matchedDistanceM),
      schemaVersion: const Value(3),
    ));

    await (_db.delete(_db.sessionPoints)..where((pt) => pt.draftId.equals(draft.id))).go();

    final pointCompanions = <SessionPointsCompanion>[];
    
    // Insert raw fixes
    for (int i = 0; i < draft.rawFixes.length; i++) {
      final fix = draft.rawFixes[i];
      pointCompanions.add(SessionPointsCompanion(
        draftId: Value(draft.id),
        seq: Value(i),
        kind: const Value('raw'),
        lat: Value(fix.lat),
        lng: Value(fix.lng),
        elevation: Value(fix.elevation),
        timestamp: Value(fix.timestamp),
        accuracy: Value(fix.accuracy.toInt()),
        hdop: Value(fix.hdop),
        speedMps: Value(fix.speedMps),
      ));
    }
    
    // Insert filtered results
    for (int i = 0; i < draft.filteredResults.length; i++) {
      final result = draft.filteredResults[i];
      final seq = draft.rawFixes.length + i; // Continue sequence
      pointCompanions.add(SessionPointsCompanion(
        draftId: Value(draft.id),
        seq: Value(seq),
        kind: const Value('filtered'),
        lat: Value(result.raw.lat),
        lng: Value(result.raw.lng),
        elevation: Value(result.raw.elevation),
        timestamp: Value(result.raw.timestamp),
        accuracy: Value(result.raw.accuracy.toInt()),
        hdop: Value(result.raw.hdop),
        speedMps: Value(result.raw.speedMps),
        filterStatus: Value(result.isAccepted ? 'accepted' : 'rejected'),
        rejectReason: Value(result.rejectReason?.name),
        smoothedLat: Value(result.smoothedLat),
        smoothedLng: Value(result.smoothedLng),
      ));
    }
    
    await _db.batch((b) => b.insertAll(_db.sessionPoints, pointCompanions));
  }
}
