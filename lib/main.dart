import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noveles/bootstrap/app.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Read a value from --dart-define first (production), falling back to the
/// local .env file (development only). The .env file is NOT bundled as a
/// Flutter asset, so release builds must pass these via --dart-define.
const String _envSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _envSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In release the dart-defines are present; in dev we allow the local .env.
  if (_envSupabaseUrl.isEmpty || _envSupabaseAnonKey.isEmpty) {
    await dotenv.load(fileName: '.env');
  }

  final supabaseUrl = _envSupabaseUrl.isNotEmpty
      ? _envSupabaseUrl
      : dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = _envSupabaseAnonKey.isNotEmpty
      ? _envSupabaseAnonKey
      : dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  setupDependencies();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const App());
}
