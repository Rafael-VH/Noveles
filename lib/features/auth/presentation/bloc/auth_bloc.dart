import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/login.dart';
import 'package:noveles/features/auth/domain/register.dart';
import 'package:noveles/features/auth/domain/logout.dart';
import 'package:noveles/features/auth/domain/get_current_user.dart';
import 'package:noveles/features/auth/domain/listen_auth_state.dart';
import 'package:noveles/features/auth/domain/auth_event.dart' as domain;
import 'package:noveles/features/auth/presentation/bloc/auth_event.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ListenAuthState listenAuthState;
  StreamSubscription? _authSubscription;
  bool _manualLogoutInProgress = false;

  AuthBloc({
    required this.login,
    required this.register,
    required this.logout,
    required this.getCurrentUser,
    required this.listenAuthState,
  }) : super(AuthInitial()) {
    on<CheckAuthSession>(_onCheckSession);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    _authSubscription = listenAuthState().listen((event) {
      if (event == domain.AuthEvent.signedOut && !_manualLogoutInProgress) {
        add(LogoutRequested());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckSession(
    CheckAuthSession event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    switch (result) {
      case Ok(:final value):
        if (value != null) {
          emit(AuthAuthenticated(value));
        } else {
          emit(AuthUnauthenticated());
        }
      case Err(:final error):
        emit(AuthError(error.message));
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await login(event.email, event.password);
    switch (result) {
      case Ok(:final value):
        emit(AuthAuthenticated(value));
      case Err(:final error):
        emit(AuthError(error.message));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await register(event.email, event.password);
    switch (result) {
      case Ok(:final value):
        emit(AuthAuthenticated(value));
      case Err(:final error):
        emit(AuthError(error.message));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _manualLogoutInProgress = true;
    emit(AuthLoading());
    final result = await logout();
    switch (result) {
      case Ok():
        emit(AuthUnauthenticated());
      case Err(:final error):
        emit(AuthError(error.message));
    }
    _manualLogoutInProgress = false;
  }
}
