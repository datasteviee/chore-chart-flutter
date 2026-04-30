/// Supabase & build-time config (use --dart-define).
///
/// GoTrue: Für Magic Links / OAuth im Supabase-Dashboard unter Authentication
/// die **Redirect URLs** und `Site URL` setzen (z. B. Custom Scheme der Flutter-App,
/// Universal Links). Siehe PRD §6.2 (`GOTRUE_SITE_URL`).
abstract final class ChoreEnv {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sb.steviee.dev',
  );
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const revenueCatApiKeyIOS = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: 'appl_guNMCweirCHMZgDxUlOAvmPznHF',
  );
  static const revenueCatApiKeyAndroid = String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');
  static const revenueCatEntitlement = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT',
    defaultValue: 'Chore Chart: Smart Family Task Planner Pro',
  );
}
