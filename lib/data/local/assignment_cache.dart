import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Offline-Cache der letzten Aufgabenliste pro Familie (PRD P5, Hive statt Isar für geringeren Boilerplate).
abstract final class AssignmentCache {
  static const _boxName = 'chore_assignments';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (Hive.isBoxOpen(_boxName)) return;
    await Hive.openBox<String>(_boxName);
  }

  static String _key(String familyId) => 'assignments_$familyId';

  static Future<void> putAssignmentsJson(String familyId, List<Map<String, dynamic>> rows) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_key(familyId), jsonEncode(rows));
  }

  static List<Map<String, dynamic>>? getAssignments(String familyId) {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_key(familyId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }
}
