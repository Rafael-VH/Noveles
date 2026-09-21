import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase credentials, resolved once at startup.
///
/// Values come from `--dart-define` first (production), falling back to the
/// local `.env` file (development only). The `.env` file is NOT bundled as a
/// Flutter asset, so release builds must pass these via `--dart-define`.
class SupabaseConfig {
  final String url;
  final String anonKey;

  const SupabaseConfig({required this.url, required this.anonKey});

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<SupabaseConfig> resolve() async {
    if (_envUrl.isEmpty || _envAnonKey.isEmpty) {
      await dotenv.load(fileName: '.env');
    }

    final url = _envUrl.isNotEmpty ? _envUrl : dotenv.env['SUPABASE_URL']!;
    final anonKey =
        _envAnonKey.isNotEmpty ? _envAnonKey : dotenv.env['SUPABASE_ANON_KEY']!;

    return SupabaseConfig(url: url, anonKey: anonKey);
  }
}
