import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noveles/core/app/app.dart';
import 'package:noveles/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Inicializando Widgets

  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive); //  Abarcando toda la pantalla

  setupDependencies();

  //  Lanzando la aplicación
  runApp(
    const App(),
  );
}
