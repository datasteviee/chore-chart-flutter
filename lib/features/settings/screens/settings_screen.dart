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
          ValueListenableBuilder<PremiumSnapshot>(
            valueListenable: PremiumService.state,
            builder: (context, premium, _) {
              return Column(
                children: [
                  ListTile(
                    title: const Text('Familien-Premium (RevenueCat)'),
                    subtitle: Text(
                      !premium.configured
                          ? 'RevenueCat noch nicht konfiguriert.'
                          : premium.isPro
                              ? 'Pro aktiv'
                              : 'Pro nicht aktiv',
                    ),
                    trailing: premium.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  if (premium.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          premium.error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                  OverflowBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await PremiumService.refresh();
                        },
                        child: const Text('Status aktualisieren'),
                      ),
                      TextButton(
                        onPressed: premium.configured
                            ? () async {
                                await PremiumService.presentPaywallIfNeeded();
                              }
                            : null,
                        child: const Text('Paywall öffnen'),
                      ),
                      TextButton(
                        onPressed: premium.configured
                            ? () async {
                                await PremiumService.restorePurchases();
                              }
                            : null,
                        child: const Text('Käufe wiederherstellen'),
                      ),
                      TextButton(
                        onPressed: premium.configured
                            ? () async {
                                await PremiumService.presentCustomerCenter();
                              }
                            : null,
                        child: const Text('Customer Center'),
                      ),
                    ],
                  ),
                  if (premium.availablePackages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Verfügbare Pakete'),
                          const SizedBox(height: 4),
                          ...premium.availablePackages.map((pkg) {
                            final product = pkg.storeProduct;
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(product.title),
                              subtitle: Text(product.identifier),
                              trailing: Text(product.priceString),
                              onTap: () async {
                                await PremiumService.purchasePackage(pkg);
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              );
            },
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
