import 'package:flutter_test/flutter_test.dart';

import 'package:chore_chart/domain/rotation_engine.dart';

void main() {
  test('mondayOfWeekContaining returns Monday', () {
    final wed = DateTime(2026, 4, 29);
    final mon = mondayOfWeekContaining(wed);
    expect(mon.weekday, 1);
    expect(mon.day, 27);
    expect(mon.month, 4);
  });

  test('planWeek assigns each template and balances load', () {
    final mon = DateTime(2026, 4, 27);
    final members = [
      const RotationMember(id: 'a', birthYear: 2015),
      const RotationMember(id: 'b', birthYear: 1990),
    ];
    final templates = [
      const RotationTemplate(id: 't1', minAge: 0, maxAge: 99, points: 5),
      const RotationTemplate(id: 't2', minAge: 18, maxAge: 99, points: 10),
    ];
    final counts = <String, int>{'a': 5, 'b': 0};
    final planned = planWeek(
      weekStartMonday: mon,
      members: members,
      templates: templates,
      assignmentCountPerMember28d: counts,
    );
    expect(planned.length, 2);
    expect(planned[0].templateId, 't1');
    expect(planned[1].templateId, 't2');
    final adultOnly = planned.where((p) => p.templateId == 't2').single;
    expect(adultOnly.memberId, 'b');
  });

  test('templateScheduledInWeek detects overlap', () {
    final mon = DateTime(2026, 4, 27);
    final rows = [
      {'template_id': 'x', 'due_date': '2026-04-28'},
    ];
    expect(templateScheduledInWeek(rows, 'x', mon), true);
    expect(templateScheduledInWeek(rows, 'y', mon), false);
  });
}
