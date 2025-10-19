import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noveles/core/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //  Inicializando Widgets

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); //  Abarcando toda la pantalla

  //  Lanzando la aplicación
  runApp(
    const App(),
  );
}
