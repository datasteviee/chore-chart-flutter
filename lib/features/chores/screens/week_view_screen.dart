import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/calendar_export.dart';
import '../../../core/premium_service.dart';
import '../../../core/theme/chore_mix_spacing.dart';
import '../../../core/theme/chore_mix_tokens.dart';
import '../../../data/week_rotation_service.dart';
import '../../../domain/rotation_engine.dart';
import '../../../widgets/design_system/assignment_card.dart';
import '../../family/family_context.dart';
import '../../tasks/assignment_status.dart';

class WeekViewScreen extends ConsumerStatefulWidget {
  const WeekViewScreen({super.key});

  @override
  ConsumerState<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends ConsumerState<WeekViewScreen> {
  int _weekOffset = 0;
  bool _loading = true;
  FamilyContext? _ctx;
  List<Map<String, dynamic>> _rows = [];
  String? _error;

  static const _weekdayDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  DateTime get _monday => mondayOfWeekContaining(DateTime.now()).add(Duration(days: _weekOffset * 7));

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
          _ctx = null;
          _rows = [];
        });
        return;
      }
      final mon = _monday;
      final sun = mon.add(const Duration(days: 6));
      final raw = await Supabase.instance.client
          .from('assignments')
          .select(
            'id, status, due_date, points_earned, member_id, template_id, task_templates(title, points), assignee:members!assignments_member_id_fkey(name)',
          )
          .eq('family_id', ctx.familyId)
          .gte('due_date', dateKey(mon))
          .lte('due_date', dateKey(sun))
          .order('due_date');
      setState(() {
        _ctx = ctx;
        _rows = List<Map<String, dynamic>>.from((raw as List).map((e) => Map<String, dynamic>.from(e as Map)));
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _autoFill() async {
    if (_ctx == null) return;
    await PremiumService.refresh();
    if (!PremiumService.canUseRotationEngine) {
      await PremiumService.presentPaywallIfNeeded();
      if (!mounted) return;
      await PremiumService.refresh();
      if (!PremiumService.canUseRotationEngine) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rotation ist mit aktivem Familien-Abo freigeschaltet.')),
        );
        return;
      }
    }
    setState(() => _error = null);
    try {
      final n = await WeekRotationService.fillWeekIfNeeded(
        client: Supabase.instance.client,
        familyId: _ctx!.familyId,
        weekStartMonday: _monday,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n == 0 ? 'Woche war schon vollständig.' : '$n neue Zuweisungen.')));
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _shareIcs() async {
    if (_ctx == null) return;
    final name = _ctx!.family['name'] as String? ?? 'Familie';
    final ics = CalendarExport.buildVCalendar(familyName: name, assignmentRows: _rows);
    final file = XFile.fromData(
      Uint8List.fromList(utf8.encode(ics)),
      mimeType: 'text/calendar',
      name: 'chore-chart-woche.ics',
    );
    await Share.shareXFiles([file], subject: 'Chore Chart — $name');
  }

  Map<String, dynamic>? _tpl(Map<String, dynamic> row) {
    final t = row['task_templates'];
    if (t is Map) return Map<String, dynamic>.from(t);
    return null;
  }

  Map<String, dynamic>? _assignee(Map<String, dynamic> row) {
    final m = row['assignee'];
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mon = _monday;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final title = '${dateKey(mon)} – ${dateKey(mon.add(const Duration(days: 6)))}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Woche $title'),
        actions: [
          IconButton(onPressed: _ctx == null || _rows.isEmpty ? null : _shareIcs, icon: const Icon(Icons.ios_share), tooltip: 'Kalender (.ics)'),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _ctx == null
                ? const Center(child: Text('Keine Familie.'))
                : Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.space(ChoreMixTokens.spaceMd), vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() => _weekOffset--);
                                _load();
                              },
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _weekOffset++);
                                _load();
                              },
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.space(ChoreMixTokens.spaceMd)),
                        child: FilledButton.tonalIcon(
                          onPressed: _autoFill,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Woche automatisch füllen'),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(context.space(ChoreMixTokens.spaceMd)),
                          itemCount: 7,
                          itemBuilder: (context, i) {
                            final day = mon.add(Duration(days: i));
                            final dk = dateKey(day);
                            final dayRows = _rows.where((r) => r['due_date'] == dk).toList();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_weekdayDe[i]} · $dk${day == today ? ' (heute)' : ''}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  if (dayRows.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4, left: 4),
                                      child: Text('Keine Aufgaben', style: Theme.of(context).textTheme.bodySmall),
                                    )
                                  else
                                    ...dayRows.map((row) {
                                      final tpl = _tpl(row);
                                      final mem = _assignee(row);
                                      final title0 = tpl?['title'] as String? ?? 'Aufgabe';
                                      final pts = (row['points_earned'] as int? ?? 0) > 0
                                          ? row['points_earned'] as int
                                          : (tpl?['points'] as int? ?? 0);
                                      final dueStr = row['due_date'] as String? ?? '';
                                      final due = DateTime.tryParse(dueStr) ?? today;
                                      final status = row['status'] as String? ?? 'pending';
                                      final variant = assignmentVariantForRow(status: status, dueDate: due, today: today);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: AssignmentCard(
                                          title: title0,
                                          points: pts,
                                          variant: variant,
                                          subtitle: mem?['name'] as String?,
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
