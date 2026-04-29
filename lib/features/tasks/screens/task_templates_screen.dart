import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../family/family_context.dart';

class TaskTemplatesScreen extends StatefulWidget {
  const TaskTemplatesScreen({super.key});

  @override
  State<TaskTemplatesScreen> createState() => _TaskTemplatesScreenState();
}

class _TaskTemplatesScreenState extends State<TaskTemplatesScreen> {
  bool _loading = true;
  FamilyContext? _ctx;
  List<Map<String, dynamic>> _rows = [];
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
          _ctx = null;
          _rows = [];
        });
        return;
      }
      final list = await Supabase.instance.client
          .from('task_templates')
          .select()
          .eq('family_id', ctx.familyId)
          .order('title');
      setState(() {
        _ctx = ctx;
        _rows = List<Map<String, dynamic>>.from(
          (list as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aufgabenvorlagen'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _ctx == null
                ? const Center(child: Text('Zuerst eine Familie anlegen.'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          ),
                        if (_rows.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Noch keine Vorlagen. Lege die erste mit + an.'),
                          )
                        else
                          ..._rows.map(
                            (r) => Card(
                              child: ListTile(
                                title: Text(r['title'] as String? ?? ''),
                                subtitle: Text(
                                  '${r['points'] ?? 0} Pkt. · ${r['recurrence'] ?? 'weekly'}',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: _ctx == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await context.push('/templates/new');
                await _load();
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}
