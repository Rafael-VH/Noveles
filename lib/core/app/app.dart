import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/presentation/notification_listener.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/core/presentation/bloc/theme_bloc.dart';
import 'package:noveles/features/admin/presentation/screens/admin_main_screen.dart';
import 'package:noveles/features/scan/presentation/screens/scan_main_screen.dart';
import 'package:noveles/features/app/presentation/screens/main_screen.dart';
import 'package:noveles/features/auth/presentation/screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

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
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthLoading) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (authState is AuthAuthenticated) {
                      if (authState.user.isAdmin) {
                        return const AdminMainScreen();
                      }
                      if (authState.user.isScan) {
                        return const ScanMainScreen();
                      }
                      return const MainScreen();
                    }
                    return const LoginScreen();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
