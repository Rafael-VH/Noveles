import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';

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
        BlocProvider(create: (_) => getIt<BookBloc>()..add(LoadBooks())),
        BlocProvider(create: (_) => getIt<GenreBloc>()..add(LoadGenres())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NovelEs',
            theme: state.themeData,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (authState is AuthAuthenticated) {
                  return const MainScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
