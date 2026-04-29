import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/premium_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Chore Chart'),
            subtitle: Text('PRD-Roadmap P0–P7: Kernfunktionen in der App; Store-Builds folgen (P8–P9).'),
          ),
          ListTile(
            title: const Text('Familien-Premium (RevenueCat)'),
            subtitle: Text(
              PremiumService.hasPremiumFamily
                  ? 'Stub: aktiv (FORCE_PREMIUM=true).'
                  : 'Stub: eingeschränkt — Rotation u. a. deaktiviert.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week),
            title: const Text('Wochenansicht & Kalender-Export'),
            subtitle: const Text('Unter „Familie“ → Woche öffnen, dann Teilen-Symbol für .ics.'),
            onTap: () => context.push('/week'),
          ),
        ],
      ),
    );
  }
}
