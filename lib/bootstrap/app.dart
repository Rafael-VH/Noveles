import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/presentation/notification_listener.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/core/presentation/bloc/theme_bloc.dart';
import 'package:noveles/features/admin/presentation/screens/admin_dash_screen.dart';
import 'package:noveles/features/scan/presentation/screens/scan_main_screen.dart';
import 'package:noveles/features/app/presentation/screens/main_screen.dart';
import 'package:noveles/features/app/presentation/screens/splash_screen.dart';
import 'package:noveles/features/auth/presentation/screens/login_screen.dart';
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    SplashScreen.onReady = _navigateIfNeeded;
  }

  @override
  void dispose() {
    SplashScreen.onReady = null;
    super.dispose();
  }

  void _navigateIfNeeded() {
    if (!mounted) return;
    final state = context.read<AuthBloc>().state;
    if (state is AuthLoading || state is AuthInitial) return;
    _navigateTo(state);
  }

  void _navigateTo(AuthState state) {
    final destination = _resolveDestination(state);
    if (destination != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  Widget? _resolveDestination(AuthState state) {
    if (state is AuthAuthenticated) {
      if (state.user.isAdmin) return const AdminDashScreen();
      if (state.user.isScan) return const ScanMainScreen();
      if (state.user.isUser) return const MainScreen();
    }
    if (state is AuthUnauthenticated) {
      return const LoginScreen();
    }
    return null;
  }

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
            routes: {
              '/label-management': (_) => const LabelManagementScreen(),
              '/admin': (_) => const AdminDashScreen(),
            },
            home: NotificationListenerWidget(
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }

                  if (SplashScreen.isReady) {
                    _navigateTo(state);
                  }
                },
                child: const SplashScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
