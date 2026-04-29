// Wochen-Rotation (PRD §9.1): je Vorlage eine Zuweisung pro Woche, Fairness über
// bisherige Last (28 Tage), Altersfilter aus [min_age, max_age].

class RotationMember {
  const RotationMember({required this.id, this.birthYear});
  final String id;
  final int? birthYear;
}

class RotationTemplate {
  const RotationTemplate({
    required this.id,
    required this.minAge,
    required this.maxAge,
    required this.points,
  });
  final String id;
  final int minAge;
  final int maxAge;
  final int points;
}

class PlannedAssignment {
  const PlannedAssignment({
    required this.templateId,
    required this.memberId,
    required this.dueDate,
  });
  final String templateId;
  final String memberId;
  final DateTime dueDate;
}

int? _ageAt(int? birthYear, int referenceYear) {
  if (birthYear == null) return null;
  return referenceYear - birthYear;
}

bool memberEligibleForTemplate(RotationMember m, RotationTemplate t, int referenceYear) {
  final age = _ageAt(m.birthYear, referenceYear);
  if (age == null) return true;
  return age >= t.minAge && age <= t.maxAge;
}

List<RotationMember> eligibleMembers(RotationTemplate t, List<RotationMember> members, int referenceYear) {
  return members.where((m) => memberEligibleForTemplate(m, t, referenceYear)).toList();
}

/// Wählt Mitglied mit geringster Last; bei Gleichstand stabile ID-Sortierung.
String pickMemberForTemplate(
  RotationTemplate t,
  List<RotationMember> members,
  Map<String, int> assignmentCount28d,
  int referenceYear,
) {
  final elig = eligibleMembers(t, members, referenceYear);
  if (elig.isEmpty) {
    throw StateError('Kein passendes Alter für Vorlage ${t.id} (${t.minAge}-${t.maxAge}).');
  }
  elig.sort((a, b) {
    final la = assignmentCount28d[a.id] ?? 0;
    final lb = assignmentCount28d[b.id] ?? 0;
    final c = la.compareTo(lb);
    if (c != 0) return c;
    return a.id.compareTo(b.id);
  });
  return elig.first.id;
}

/// [weekStartMonday] Kalendertag des Montags (lokal). Pro Vorlage ein Slot, über 7 Tage verteilt.
List<PlannedAssignment> planWeek({
  required DateTime weekStartMonday,
  required List<RotationMember> members,
  required List<RotationTemplate> templates,
  required Map<String, int> assignmentCountPerMember28d,
}) {
  final monday = DateTime(weekStartMonday.year, weekStartMonday.month, weekStartMonday.day);
  final refYear = monday.year;
  final load = Map<String, int>.from(assignmentCountPerMember28d);
  final out = <PlannedAssignment>[];
  for (var i = 0; i < templates.length; i++) {
    final t = templates[i];
    final memberId = pickMemberForTemplate(t, members, load, refYear);
    load[memberId] = (load[memberId] ?? 0) + 1;
    final dayOffset = i % 7;
    final due = monday.add(Duration(days: dayOffset));
    out.add(PlannedAssignment(templateId: t.id, memberId: memberId, dueDate: due));
  }
  return out;
}

DateTime mondayOfWeekContaining(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final wd = d.weekday;
  return d.subtract(Duration(days: wd - 1));
}

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool dateInInclusiveRange(DateTime d, DateTime start, DateTime end) {
  final x = DateTime(d.year, d.month, d.day);
  final a = DateTime(start.year, start.month, start.day);
  final b = DateTime(end.year, end.month, end.day);
  return !x.isBefore(a) && !x.isAfter(b);
}

bool templateScheduledInWeek(List<Map<String, dynamic>> weekAssignments, String templateId, DateTime monday) {
  final sunday = monday.add(const Duration(days: 6));
  for (final r in weekAssignments) {
    if (r['template_id'] != templateId) continue;
    final ds = r['due_date'] as String?;
    if (ds == null) continue;
    final d = DateTime.tryParse(ds);
    if (d == null) continue;
    if (dateInInclusiveRange(d, monday, sunday)) return true;
  }
  return false;
}
