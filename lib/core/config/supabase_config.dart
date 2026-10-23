class SupabaseConfig {
  SupabaseConfig._();

  static const String url =
      'https://zbzymcimiafhrvapetku.supabase.co';

  static const String publishableKey =
      'sb_publishable_wqrd0QG3Bn8Lhr80MFsZhw_GqkAUFJH';

  static bool get isConfigured =>
      url.startsWith('https://') &&
          !url.contains('YOUR_SUPABASE_URL') &&
          publishableKey.isNotEmpty &&
          !publishableKey.contains('YOUR_SUPABASE_PUBLISHABLE_KEY');
}