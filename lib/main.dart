import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noveles/core/app/app.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Inicializando Widgets

  await Supabase.initialize(
    url: 'https://xozqqjcuuesxcqwhillr.supabase.co',
    anonKey: 'sb_publishable_4KI-2PHTvKTReCqx2xbU2A_8TgtzItJ',
  );

  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive); //  Abarcando toda la pantalla

  setupDependencies();

  //  Lanzando la aplicación
  runApp(
    const App(),
  );
}
