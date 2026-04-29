import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/chore_notifications.dart';
import 'core/constants.dart';
import 'data/local/assignment_cache.dart';

/// Gemeinsame Initialisierung für [main] und Integrationstests.
/// [testHivePath]: optional, nur für Tests (siehe [AssignmentCache.init]).
/// [minimalServicesOnly]: nur Binding (+ optional Hive); kein Supabase (vermeidet Netzwerk-Hangs in Widget-Tests).
/// [skipLocalStore]: kein Hive (falls [openBox] im Test-VM hängt).
Future<void> bootstrapChoreApp({
  String? testHivePath,
  bool minimalServicesOnly = false,
  bool skipLocalStore = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!skipLocalStore) {
    await AssignmentCache.init(testRootPath: testHivePath);
  }
  if (minimalServicesOnly) return;

  await ChoreNotifications.init();

  if (ChoreEnv.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: ChoreEnv.supabaseUrl,
      anonKey: ChoreEnv.supabaseAnonKey,
    );
  }
}

void runChoreApp() {
  runApp(const ProviderScope(child: ChoreApp()));
}
