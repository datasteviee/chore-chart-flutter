/// RevenueCat-Anbindung (PRD §10): Platzhalter bis API-Keys und Store-Produkte stehen.
///
/// `--dart-define=FORCE_PREMIUM=false` simuliert fehlendes Abo (nur Lesen / eingeschränkt).
abstract final class PremiumService {
  static const _forcePremium = bool.fromEnvironment('FORCE_PREMIUM', defaultValue: true);

  static bool get hasPremiumFamily => _forcePremium;

  /// Rotation & Auto-Zuweisung laut PRD hinter Premium.
  static bool get canUseRotationEngine => hasPremiumFamily;
}
