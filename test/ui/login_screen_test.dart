import 'package:chore_chart/features/auth/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mix_test_harness.dart';

void main() {
  testWidgets('Login: Titel, E-Mail-Feld und Aktionen', (tester) async {
    await tester.pumpWidget(
      pumpWithMixScope(const LoginScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chore Chart'), findsOneWidget);
    expect(find.textContaining('E-Mail'), findsWidgets);
    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.text('Registrieren'), findsOneWidget);
  });
}
