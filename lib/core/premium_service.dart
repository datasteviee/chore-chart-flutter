import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'constants.dart';

@immutable
class PremiumSnapshot {
  const PremiumSnapshot({
    required this.configured,
    required this.loading,
    required this.isPro,
    required this.availablePackages,
    required this.error,
    required this.managementUrl,
  });

  final bool configured;
  final bool loading;
  final bool isPro;
  final List<Package> availablePackages;
  final String? error;
  final String? managementUrl;

  static const empty = PremiumSnapshot(
    configured: false,
    loading: false,
    isPro: false,
    availablePackages: <Package>[],
    error: null,
    managementUrl: null,
  );

  PremiumSnapshot copyWith({
    bool? configured,
    bool? loading,
    bool? isPro,
    List<Package>? availablePackages,
    String? error,
    String? managementUrl,
  }) {
    return PremiumSnapshot(
      configured: configured ?? this.configured,
      loading: loading ?? this.loading,
      isPro: isPro ?? this.isPro,
      availablePackages: availablePackages ?? this.availablePackages,
      error: error,
      managementUrl: managementUrl ?? this.managementUrl,
    );
  }
}

/// RevenueCat-Integration für Entitlements, Paywall und Customer Center.
abstract final class PremiumService {
  static final ValueNotifier<PremiumSnapshot> state = ValueNotifier<PremiumSnapshot>(PremiumSnapshot.empty);
  static bool _configured = false;

  static String get _entitlement => ChoreEnv.revenueCatEntitlement;

  static bool get hasPremiumFamily => state.value.isPro;
  static bool get canUseRotationEngine => hasPremiumFamily;

  static String _apiKeyForPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ChoreEnv.revenueCatApiKeyIOS.trim();
      case TargetPlatform.android:
        return ChoreEnv.revenueCatApiKeyAndroid.trim();
      default:
        return '';
    }
  }

  static Future<void> init() async {
    final apiKey = _apiKeyForPlatform();
    if (apiKey.isEmpty) {
      state.value = state.value.copyWith(
        configured: false,
        loading: false,
        isPro: false,
        availablePackages: const <Package>[],
        error: 'RevenueCat API-Key fehlt für diese Plattform.',
      );
      return;
    }

    if (!_configured) {
      try {
        await Purchases.setLogLevel(LogLevel.debug);
        final cfg = PurchasesConfiguration(apiKey);
        await Purchases.configure(cfg);
        Purchases.addCustomerInfoUpdateListener((info) {
          _applyCustomerInfo(info);
        });
        _configured = true;
      } catch (e) {
        state.value = state.value.copyWith(
          configured: false,
          error: 'RevenueCat Init fehlgeschlagen: $e',
        );
        return;
      }
    }
    await refresh();
  }

  static void _applyCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active[_entitlement] != null;
    state.value = state.value.copyWith(
      configured: true,
      isPro: active,
      managementUrl: info.managementURL,
      error: null,
    );
  }

  static Future<void> refresh() async {
    if (!_configured) return;
    state.value = state.value.copyWith(loading: true, error: null);
    try {
      final offerings = await Purchases.getOfferings();
      final currentPackages = offerings.current?.availablePackages ?? const <Package>[];
      final info = await Purchases.getCustomerInfo();
      _applyCustomerInfo(info);
      state.value = state.value.copyWith(
        configured: true,
        loading: false,
        availablePackages: currentPackages,
      );
    } catch (e) {
      state.value = state.value.copyWith(
        loading: false,
        error: 'RevenueCat Refresh fehlgeschlagen: $e',
      );
    }
  }

  static Future<void> restorePurchases() async {
    if (!_configured) return;
    state.value = state.value.copyWith(loading: true, error: null);
    try {
      final info = await Purchases.restorePurchases();
      _applyCustomerInfo(info);
      state.value = state.value.copyWith(loading: false);
    } catch (e) {
      state.value = state.value.copyWith(
        loading: false,
        error: 'Wiederherstellen fehlgeschlagen: $e',
      );
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    if (!_configured) return false;
    state.value = state.value.copyWith(loading: true, error: null);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _applyCustomerInfo(result.customerInfo);
      state.value = state.value.copyWith(loading: false);
      return state.value.isPro;
    } on PurchasesError catch (e) {
      state.value = state.value.copyWith(
        loading: false,
        error: 'Kauf fehlgeschlagen: ${e.message}',
      );
      return false;
    } catch (e) {
      state.value = state.value.copyWith(
        loading: false,
        error: 'Kauf fehlgeschlagen: $e',
      );
      return false;
    }
  }

  static Future<PaywallResult?> presentPaywallIfNeeded() async {
    if (!_configured) return null;
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(_entitlement, displayCloseButton: true);
      await refresh();
      return result;
    } catch (e) {
      state.value = state.value.copyWith(error: 'Paywall konnte nicht geöffnet werden: $e');
      return null;
    }
  }

  static Future<void> presentCustomerCenter() async {
    if (!_configured) return;
    try {
      await RevenueCatUI.presentCustomerCenter(
        onRestoreCompleted: (customerInfo) {
          _applyCustomerInfo(customerInfo);
        },
      );
      await refresh();
    } catch (e) {
      state.value = state.value.copyWith(error: 'Customer Center konnte nicht geöffnet werden: $e');
    }
  }
}
