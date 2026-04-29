import 'package:flutter/foundation.dart';

/// Lokale Erinnerungen (PRD §5 / P7): Initialisierung folgt, sobald iOS/Android-Konfiguration festliegt.
abstract final class ChoreNotifications {
  static Future<void> init() async {
    if (kDebugMode) {
      debugPrint('ChoreNotifications: Stub (keine geplanten Notifications).');
    }
  }
}
