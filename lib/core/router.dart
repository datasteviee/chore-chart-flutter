import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/chores/screens/week_view_screen.dart';
import '../features/family/screens/family_home_screen.dart';
import '../features/family/screens/join_family_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/tasks/screens/new_assignment_screen.dart';
import '../features/tasks/screens/task_template_form_screen.dart';
import '../features/tasks/screens/task_templates_screen.dart';

final _authRefreshProvider = Provider<AuthRefreshNotifier>((ref) {
  final n = AuthRefreshNotifier();
  ref.onDispose(n.dispose);
  return n;
});

/// Notifies [GoRouter] when Supabase auth session changes.
final class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    if (ChoreEnv.supabaseAnonKey.isNotEmpty) {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        notifyListeners();
      });
    }
  }

  StreamSubscription<AuthState>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_authRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      if (ChoreEnv.supabaseAnonKey.isEmpty) {
        return state.matchedLocation == '/setup' ? null : '/setup';
      }
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final loc = state.matchedLocation;
      if (!loggedIn && loc != '/login' && loc != '/setup') {
        return '/login';
      }
      if (loggedIn && (loc == '/login' || loc == '/setup')) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const _SetupRequiredScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const FamilyHomeScreen(),
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TaskTemplatesScreen(),
      ),
      GoRoute(
        path: '/templates/new',
        builder: (context, state) => const TaskTemplateFormScreen(),
      ),
      GoRoute(
        path: '/assignments/new',
        builder: (context, state) => const NewAssignmentScreen(),
      ),
      GoRoute(
        path: '/week',
        builder: (context, state) => const WeekViewScreen(),
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinFamilyScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _SetupRequiredScreen extends StatelessWidget {
  const _SetupRequiredScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chore Chart')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Supabase: Bitte SUPABASE_ANON_KEY per '
            'flutter run --dart-define=SUPABASE_ANON_KEY=… setzen '
            '(URL: SUPABASE_URL, Standard: https://sb.steviee.dev).',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
