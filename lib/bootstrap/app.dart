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
import 'package:noveles/features/auth/presentation/screens/suspended_screen.dart';
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(
          create: (_) => getIt<AuthBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NovelEs',
            theme: state.themeData,
            navigatorKey: navigatorKey,
            onGenerateRoute: (settings) {
              // Role guards: never trust drawer visibility alone. The AuthBloc
              // is created above (BlocProvider), so it is safe to read here.
              final authState = context.read<AuthBloc>().state;
              switch (settings.name) {
                case '/admin':
                  final user = (authState is AuthAuthenticated)
                      ? authState.user
                      : null;
                  return MaterialPageRoute(
                    builder: (_) =>
                        (user != null && user.role == UserRole.admin)
                            ? const AdminDashScreen()
                            : _homeFor(authState),
                  );
                case '/label-management':
                  final user = (authState is AuthAuthenticated)
                      ? authState.user
                      : null;
                  final allowed =
                      user?.role == UserRole.admin || user?.role == UserRole.scan;
                  return MaterialPageRoute(
                    builder: (_) => allowed
                        ? const LabelManagementScreen()
                        : _homeFor(authState),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => _homeFor(authState),
                  );
              }
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

                  if (state is AuthSuspended) {
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SuspendedScreen(),
                      ),
                      (_) => false,
                    );
                    return;
                  }

                  if (!SplashScreen.isReady) return;

                  if (state is AuthAuthenticated ||
                      state is AuthUnauthenticated) {
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => _homeFor(state)),
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

  /// Single source of truth mapping an auth state to its home screen.
  Widget _homeFor(AuthState state) {
    if (state is AuthAuthenticated) {
      if (state.user.isAdmin) return const AdminDashScreen();
      if (state.user.isScan) return const ScanMainScreen();
      if (state.user.isUser) return const MainScreen();
      // suspended/unknown should not render content; login is a safe fallback.
      return const LoginScreen();
    }
    return const LoginScreen();
  }
}
