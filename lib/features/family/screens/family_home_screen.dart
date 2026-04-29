import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mix/mix.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/chore_member_colors.dart';
import '../../../core/theme/chore_mix_spacing.dart';
import '../../../core/theme/chore_mix_tokens.dart';
import '../../../widgets/design_system/assignment_card.dart';
import '../family_context.dart';
import '../../tasks/assignment_status.dart';

class FamilyHomeScreen extends ConsumerStatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  ConsumerState<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends ConsumerState<FamilyHomeScreen> {
  bool _loading = true;
  Map<String, dynamic>? _family;
  List<Map<String, dynamic>> _assignments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ctx = await FamilyContext.loadCurrent();
      if (ctx == null) {
        setState(() {
          _family = null;
          _assignments = [];
        });
        return;
      }
      setState(() => _family = ctx.family);
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 14));
      String dk(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final raw = await Supabase.instance.client
          .from('assignments')
          .select('id, status, due_date, points_earned, task_templates(title, points), members(name)')
          .eq('family_id', ctx.familyId)
          .gte('due_date', dk(start))
          .lte('due_date', dk(end))
          .order('due_date');
      setState(() {
        _assignments = List<Map<String, dynamic>>.from((raw as List).map((e) => Map<String, dynamic>.from(e as Map)));
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markDone(String assignmentId) async {
    try {
      await Supabase.instance.client.from('assignments').update({
        'status': 'done',
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', assignmentId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _randomInvite() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final buf = StringBuffer('CHART-');
    for (var i = 0; i < 6; i++) {
      buf.write(chars[r.nextInt(chars.length)]);
    }
    return buf.toString();
  }

  Future<void> _createFamily() async {
    setState(() => _error = null);
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final email = Supabase.instance.client.auth.currentUser?.email ?? 'Eltern';
      final invite = _randomInvite();
      final fam = await Supabase.instance.client
          .from('families')
          .insert({'name': 'Meine Familie', 'invite_code': invite, 'created_by': uid})
          .select()
          .single();
      final familyId = fam['id'] as String;
      await Supabase.instance.client.from('members').insert({
        'family_id': familyId,
        'user_id': uid,
        'name': email.split('@').first,
        'role': 'parent',
        'color': '#${(kChoreMemberColors[0].toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      });
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Map<String, dynamic>? _tpl(Map<String, dynamic> row) {
    final t = row['task_templates'];
    if (t is Map) return Map<String, dynamic>.from(t);
    return null;
  }

  Map<String, dynamic>? _mem(Map<String, dynamic> row) {
    final m = row['members'];
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final panel = BoxStyler()
        .color(ChoreMixTokens.colorSurface())
        .borderRadius(BorderRadiusGeometryMix.all(ChoreMixTokens.radiusLg()))
        .padding(EdgeInsetsGeometryMix.all(ChoreMixTokens.spaceLg()))
        .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.colorOutlineVariant())));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Familie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(context.space(ChoreMixTokens.spaceMd)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    if (_family == null)
                      Box(
                        style: panel,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Noch keine Familie', style: Theme.of(context).textTheme.titleMedium),
                            SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                            const Text('Lege eine Familie an, um Aufgaben und Mitglieder zu verwalten.'),
                            SizedBox(height: context.space(ChoreMixTokens.spaceLg)),
                            FilledButton(
                              onPressed: _createFamily,
                              child: const Text('Familie erstellen'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Box(
                        style: panel,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_family!['name'] as String? ?? 'Familie', style: Theme.of(context).textTheme.titleLarge),
                            SizedBox(height: context.space(ChoreMixTokens.spaceSm)),
                            SelectableText('Einladung: ${_family!['invite_code']}'),
                          ],
                        ),
                      ),
                      SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          await context.push('/templates');
                          await _load();
                        },
                        icon: const Icon(Icons.library_books_outlined),
                        label: const Text('Aufgabenvorlagen'),
                      ),
                      SizedBox(height: context.space(ChoreMixTokens.spaceSm)),
                      FilledButton.icon(
                        onPressed: () async {
                          await context.push('/assignments/new');
                          await _load();
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Aufgabe zuweisen'),
                      ),
                      SizedBox(height: context.space(ChoreMixTokens.spaceLg)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kommende Aufgaben', style: Theme.of(context).textTheme.titleMedium),
                          IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Aktualisieren'),
                        ],
                      ),
                      SizedBox(height: context.space(ChoreMixTokens.spaceMd)),
                      if (_assignments.isEmpty)
                        Text('Noch keine Zuweisungen.', style: Theme.of(context).textTheme.bodyMedium)
                      else
                        ..._assignments.map((row) {
                          final tpl = _tpl(row);
                          final mem = _mem(row);
                          final title = tpl?['title'] as String? ?? 'Aufgabe';
                          final pts = (row['points_earned'] as int? ?? 0) > 0
                              ? row['points_earned'] as int
                              : (tpl?['points'] as int? ?? 0);
                          final dueStr = row['due_date'] as String? ?? '';
                          final due = DateTime.tryParse(dueStr) ?? today;
                          final status = row['status'] as String? ?? 'pending';
                          final variant = assignmentVariantForRow(status: status, dueDate: due, today: today);
                          final sub = '${mem?['name'] ?? '?'} · $dueStr';
                          final canComplete = status == 'pending' || status == 'overdue';
                          return Padding(
                            padding: EdgeInsets.only(bottom: context.space(ChoreMixTokens.spaceSm)),
                            child: AssignmentCard(
                              title: title,
                              points: pts,
                              variant: variant,
                              subtitle: sub,
                              trailing: canComplete
                                  ? IconButton(
                                      tooltip: 'Erledigt',
                                      icon: const Icon(Icons.check_circle_outline),
                                      onPressed: () => _markDone(row['id'] as String),
                                    )
                                  : null,
                            ),
                          );
                        }),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
