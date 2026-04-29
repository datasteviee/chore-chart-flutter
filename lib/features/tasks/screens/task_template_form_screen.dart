import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../family/family_context.dart';

class TaskTemplateFormScreen extends StatefulWidget {
  const TaskTemplateFormScreen({super.key});

  @override
  State<TaskTemplateFormScreen> createState() => _TaskTemplateFormScreenState();
}

class _TaskTemplateFormScreenState extends State<TaskTemplateFormScreen> {
  final _title = TextEditingController();
  final _points = TextEditingController(text: '5');
  String _recurrence = 'weekly';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Bitte einen Titel eingeben.');
      return;
    }
    final pts = int.tryParse(_points.text.trim()) ?? 5;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final ctx = await FamilyContext.loadCurrent();
      if (ctx == null) {
        setState(() => _error = 'Keine Familie gefunden.');
        return;
      }
      await Supabase.instance.client.from('task_templates').insert({
        'family_id': ctx.familyId,
        'title': title,
        'points': pts,
        'recurrence': _recurrence,
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
      appBar: AppBar(title: const Text('Neue Vorlage')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titel', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _points,
              decoration: const InputDecoration(labelText: 'Punkte', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _recurrence,
              decoration: const InputDecoration(labelText: 'Wiederholung', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Täglich')),
                DropdownMenuItem(value: 'weekly', child: Text('Wöchentlich')),
                DropdownMenuItem(value: 'biweekly', child: Text('Alle 2 Wochen')),
                DropdownMenuItem(value: 'monthly', child: Text('Monatlich')),
              ],
              onChanged: (v) => setState(() => _recurrence = v ?? 'weekly'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
