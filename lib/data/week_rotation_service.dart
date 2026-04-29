import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/rotation_engine.dart';

/// Lädt Daten, plant Woche, legt [assignments] und [rotation_log] an.
abstract final class WeekRotationService {
  static Future<int> fillWeekIfNeeded({
    required SupabaseClient client,
    required String familyId,
    required DateTime weekStartMonday,
  }) async {
    final monday = DateTime(weekStartMonday.year, weekStartMonday.month, weekStartMonday.day);
    final sunday = monday.add(const Duration(days: 6));
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final from28 = todayDate.subtract(const Duration(days: 28));
    final dkFrom = dateKey(from28);
    final dkHistTo = dateKey(todayDate);
    final dkMon = dateKey(monday);
    final dkSun = dateKey(sunday);

    final membersRaw = await client.from('members').select('id, birth_year').eq('family_id', familyId);
    final members = (membersRaw as List)
        .map((e) => RotationMember(
              id: (e as Map)['id'] as String,
              birthYear: (e)['birth_year'] as int?,
            ))
        .toList();
    if (members.isEmpty) return 0;

    final templatesRaw = await client.from('task_templates').select('id, min_age, max_age, points').eq('family_id', familyId);
    final templates = (templatesRaw as List)
        .map(
          (e) => RotationTemplate(
            id: (e as Map)['id'] as String,
            minAge: (e)['min_age'] as int? ?? 0,
            maxAge: (e)['max_age'] as int? ?? 99,
            points: (e)['points'] as int? ?? 5,
          ),
        )
        .toList();
    if (templates.isEmpty) return 0;

    final refYear = monday.year;
    final templatesFiltered =
        templates.where((t) => eligibleMembers(t, members, refYear).isNotEmpty).toList();
    if (templatesFiltered.isEmpty) return 0;

    final hist = await client
        .from('assignments')
        .select('member_id')
        .eq('family_id', familyId)
        .gte('due_date', dkFrom)
        .lte('due_date', dkHistTo);
    final counts = <String, int>{};
    for (final row in hist as List) {
      final mid = (row as Map)['member_id'] as String?;
      if (mid == null) continue;
      counts[mid] = (counts[mid] ?? 0) + 1;
    }

    final weekRows = await client
        .from('assignments')
        .select('template_id, due_date')
        .eq('family_id', familyId)
        .gte('due_date', dkMon)
        .lte('due_date', dkSun);
    final weekList = (weekRows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

    final planned = planWeek(
      weekStartMonday: monday,
      members: members,
      templates: templatesFiltered,
      assignmentCountPerMember28d: counts,
    );

    var inserted = 0;
    for (final p in planned) {
      if (templateScheduledInWeek(weekList, p.templateId, monday)) continue;

      await client.from('assignments').insert({
        'family_id': familyId,
        'template_id': p.templateId,
        'member_id': p.memberId,
        'due_date': dateKey(p.dueDate),
        'status': 'pending',
      });
      weekList.add({'template_id': p.templateId, 'due_date': dateKey(p.dueDate)});

      await client.from('rotation_log').insert({
        'family_id': familyId,
        'template_id': p.templateId,
        'from_member_id': null,
        'to_member_id': p.memberId,
        'week_start': dkMon,
        'reason': 'auto_rotation',
      });
      inserted++;
    }
    return inserted;
  }
}
