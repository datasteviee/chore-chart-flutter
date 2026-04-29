import 'package:chore_chart/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('ChoreApp baut ohne Exception', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChoreApp()));
    await tester.pump();
    expect(find.byType(ChoreApp), findsOneWidget);
  });
}
