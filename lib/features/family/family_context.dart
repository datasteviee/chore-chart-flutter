import 'package:supabase_flutter/supabase_flutter.dart';

/// Current user's primary family (first membership row).
class FamilyContext {
  FamilyContext({required this.familyId, required this.family});

  final String familyId;
  final Map<String, dynamic> family;

  static Future<FamilyContext?> loadCurrent() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return null;
    final rows = await Supabase.instance.client
        .from('members')
        .select('family_id, families(*)')
        .eq('user_id', uid)
        .maybeSingle();
    if (rows == null) return null;
    return FamilyContext(
      familyId: rows['family_id'] as String,
      family: Map<String, dynamic>.from(rows['families'] as Map),
    );
  }
}
