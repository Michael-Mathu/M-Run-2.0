import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/safety/safety_service.dart';

/// Persisted list of emergency contacts used by the SOS flow. Offline-first:
/// stored in SharedPreferences so it survives restarts.
class SafetyContacts extends Notifier<List<EmergencyContact>> {
  static const _key = 'safety_contacts_v1';

  @override
  List<EmergencyContact> build() {
    _restore();
    return const [];
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        state = list.map(EmergencyContact.fromJson).toList();
      }
    } catch (_) {
      // offline-first: start with no contacts
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(state.map((c) => c.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> add(EmergencyContact contact) async {
    state = [...state, contact];
    await _persist();
  }

  Future<void> update(int index, EmergencyContact contact) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state];
    next[index] = contact;
    state = next;
    await _persist();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
    await _persist();
  }
}

final safetyContactsProvider =
    NotifierProvider<SafetyContacts, List<EmergencyContact>>(SafetyContacts.new);
