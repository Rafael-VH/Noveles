import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noveles/bootstrap/app.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/backend/backend_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackend();
  setupDependencies();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const App());
}
