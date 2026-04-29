import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/chore_notifications.dart';
import 'core/constants.dart';
import 'data/local/assignment_cache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AssignmentCache.init();
  await ChoreNotifications.init();

  if (ChoreEnv.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: ChoreEnv.supabaseUrl,
      anonKey: ChoreEnv.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: ChoreApp()));
}
