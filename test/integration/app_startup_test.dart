import 'package:chore_chart/app.dart';
import 'package:chore_chart/app_bootstrap.dart';
import 'package:chore_chart/core/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-Smoke: GoRouter-Setup ohne Supabase und ohne Hive (stabiler in `flutter test`).
void main() {
  testWidgets(
    'Nach minimalem Bootstrap zeigt ChoreApp die Setup-Hilfe (ohne Anon-Key)',
    (tester) async {
      await bootstrapChoreApp(minimalServicesOnly: true, skipLocalStore: true);
      await tester.pumpWidget(const ProviderScope(child: ChoreApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Chore Chart'), findsWidgets);
      expect(find.textContaining('SUPABASE_ANON_KEY'), findsOneWidget);
    },
    skip: ChoreEnv.supabaseAnonKey.isNotEmpty,
  );
}
