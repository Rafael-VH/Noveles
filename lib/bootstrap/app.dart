import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/core/presentation/bloc/theme_bloc.dart';
import 'package:noveles/features/admin/presentation/screens/admin_dash_screen.dart';
import 'package:noveles/features/scan/presentation/screens/scan_main_screen.dart';
import 'package:noveles/features/app/presentation/screens/main_screen.dart';
import 'package:noveles/features/app/presentation/screens/splash_screen.dart';
import 'package:noveles/features/auth/presentation/screens/login_screen.dart';
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthSession()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NovelEs',
            theme: state.themeData,
            navigatorKey: navigatorKey,
            routes: {
              '/label-management': (_) => const LabelManagementScreen(),
              '/admin': (_) => const AdminDashScreen(),
            },
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  final nav = App.navigatorKey.currentState;
                  if (nav == null) return;

                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  if (!SplashScreen.isReady) return;

                  if (state is AuthAuthenticated) {
                    Widget destination;
                    if (state.user.isAdmin) {
                      destination = const AdminDashScreen();
                    } else if (state.user.isScan) {
                      destination = const ScanMainScreen();
                    } else if (state.user.isUser) {
                      destination = const MainScreen();
                    } else {
                      destination = const LoginScreen();
                    }
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => destination),
                      (_) => false,
                    );
                  } else if (state is AuthUnauthenticated) {
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                child: child,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
