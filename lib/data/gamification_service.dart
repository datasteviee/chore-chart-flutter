import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/rotation_engine.dart';

/// Punkte + Streaks bei erledigter Zuweisung (PRD §9.2).
abstract final class GamificationService {
  static Future<void> completeAssignment(
    SupabaseClient client,
    Map<String, dynamic> assignmentRow, {
    String? completedByMemberId,
  }) async {
    final id = assignmentRow['id'] as String;
    final memberId = assignmentRow['member_id'] as String;
    final tpl = assignmentRow['task_templates'];
    var points = 5;
    if (tpl is Map) {
      points = (tpl['points'] as num?)?.toInt() ?? 5;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final by = completedByMemberId ?? memberId;

    await client.from('assignments').update({
      'status': 'done',
      'completed_at': nowIso,
      'points_earned': points,
      'completed_by': by,
    }).eq('id', id);

    await _applyStreak(client, memberId, points);
  }

  static Future<void> _applyStreak(SupabaseClient client, String memberId, int pointsEarned) async {
    final today = dateKey(DateTime.now());
    final yesterday = dateKey(DateTime.now().subtract(const Duration(days: 1)));

    final existing = await client.from('streaks').select().eq('member_id', memberId).maybeSingle();

    if (existing == null) {
      await client.from('streaks').insert({
        'member_id': memberId,
        'current_streak': 1,
        'longest_streak': 1,
        'total_points': pointsEarned,
        'last_activity_date': today,
      });
      return;
    }

    final last = existing['last_activity_date'] as String?;
    final cur = (existing['current_streak'] as num?)?.toInt() ?? 0;
    final longest = (existing['longest_streak'] as num?)?.toInt() ?? 0;
    final total = (existing['total_points'] as num?)?.toInt() ?? 0;

    int newStreak;
    if (last == today) {
      newStreak = cur;
    } else if (last == yesterday) {
      newStreak = cur + 1;
    } else {
      newStreak = 1;
    }

    final newLongest = newStreak > longest ? newStreak : longest;

    await client.from('streaks').update({
      'current_streak': newStreak,
      'longest_streak': newLongest,
      'total_points': total + pointsEarned,
      'last_activity_date': today,
    }).eq('member_id', memberId);
  }
}
