import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (ChoreEnv.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: ChoreEnv.supabaseUrl,
      anonKey: ChoreEnv.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: ChoreApp()));
}
