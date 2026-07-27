import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/admin/presentation/screens/admin_dash_screen.dart';
import 'package:noveles/features/scan/presentation/screens/scan_main_screen.dart';
import 'package:noveles/features/app/presentation/screens/main_screen.dart';
import 'package:noveles/features/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _authResolved = false;
  bool _timerDone = false;
  AuthState? _finalAuthState;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      setState(() => _timerDone = true);
      _navigateIfNeeded();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onAuthState(AuthState state) {
    if (state is AuthLoading || state is AuthInitial) return;
    _finalAuthState = state;
    _authResolved = true;
    _navigateIfNeeded();
  }

  void _navigateIfNeeded() {
    if (!_authResolved || !_timerDone || !mounted) return;

    final destination = _resolveDestination(_finalAuthState);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Widget _resolveDestination(AuthState? state) {
    if (state is AuthAuthenticated) {
      if (state.user.isAdmin) return const AdminDashScreen();
      if (state.user.isScan) return const ScanMainScreen();
      if (state.user.isUser) return const MainScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _onAuthState(state),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories,
                size: 80,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                'NovelEs',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
