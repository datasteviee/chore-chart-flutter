import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../family/family_context.dart';

class NewAssignmentScreen extends StatefulWidget {
  const NewAssignmentScreen({super.key});

  @override
  State<NewAssignmentScreen> createState() => _NewAssignmentScreenState();
}

class _NewAssignmentScreenState extends State<NewAssignmentScreen> {
  bool _loading = true;
  FamilyContext? _ctx;
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _members = [];
  String? _templateId;
  String? _memberId;
  DateTime _due = DateTime.now();
  bool _saving = false;
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
        setState(() => _ctx = null);
        return;
      }
      final t = await Supabase.instance.client.from('task_templates').select().eq('family_id', ctx.familyId).order('title');
      final m = await Supabase.instance.client.from('members').select().eq('family_id', ctx.familyId).order('name');
      setState(() {
        _ctx = ctx;
        _templates = List<Map<String, dynamic>>.from((t as List).map((e) => Map<String, dynamic>.from(e as Map)));
        _members = List<Map<String, dynamic>>.from((m as List).map((e) => Map<String, dynamic>.from(e as Map)));
        _templateId = _templates.isNotEmpty ? _templates.first['id'] as String? : null;
        _memberId = _members.isNotEmpty ? _members.first['id'] as String? : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _save() async {
    if (_ctx == null || _templateId == null || _memberId == null) {
      setState(() => _error = 'Vorlage und Mitglied wählen.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.from('assignments').insert({
        'family_id': _ctx!.familyId,
        'template_id': _templateId,
        'member_id': _memberId,
        'due_date': _dateKey(_due),
        'status': 'pending',
      });
      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aufgabe zuweisen')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _ctx == null
                ? const Center(child: Text('Keine Familie.'))
                : _templates.isEmpty
                    ? const Center(child: Text('Lege zuerst eine Aufgabenvorlage an.'))
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ),
                          DropdownButtonFormField<String>(
                            initialValue: _templateId,
                            decoration: const InputDecoration(labelText: 'Vorlage', border: OutlineInputBorder()),
                            items: _templates
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r['id'] as String,
                                    child: Text(r['title'] as String? ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _templateId = v),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _memberId,
                            decoration: const InputDecoration(labelText: 'Mitglied', border: OutlineInputBorder()),
                            items: _members
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r['id'] as String,
                                    child: Text(r['name'] as String? ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _memberId = v),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Fällig am'),
                            subtitle: Text(_dateKey(_due)),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _saving || _members.isEmpty ? null : _save,
                            child: _saving
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Zuweisen'),
                          ),
                        ],
                      ),
      ),
    );
  }
}
