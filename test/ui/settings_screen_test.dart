import 'package:chore_chart/features/settings/screens/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mix_test_harness.dart';

void main() {
  testWidgets('Einstellungen: Premium-Stub und Navigation-Hinweis', (tester) async {
    await tester.pumpWidget(
      pumpWithMixScope(const SettingsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.textContaining('RevenueCat'), findsOneWidget);
    expect(find.textContaining('Wochenansicht'), findsOneWidget);
  });
}
