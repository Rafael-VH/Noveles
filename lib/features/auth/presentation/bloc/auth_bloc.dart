import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/auth/presentation/bloc/auth_event.dart';
export 'package:noveles/features/auth/presentation/bloc/auth_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart' as domain;
import 'package:noveles/features/auth/domain/use_cases/login.dart';
import 'package:noveles/features/auth/domain/use_cases/register.dart';
import 'package:noveles/features/auth/domain/use_cases/logout.dart';
import 'package:noveles/features/auth/domain/use_cases/get_current_user.dart';
import 'package:noveles/features/auth/domain/use_cases/listen_auth_state.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
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
    on<RefreshUser>(_onRefreshUser);
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    _authSubscription = listenAuthState().listen((event) {
      switch (event) {
        case domain.AuthEvent.signedOut:
          if (!_manualLogoutInProgress) {
            add(LogoutRequested());
          }
        case domain.AuthEvent.tokenRefreshed:
        case domain.AuthEvent.userChanged:
        case domain.AuthEvent.signedIn:
          // Re-fetch the profile: role changes (suspension, promotion) only
          // propagate here, since the auth token itself does not carry the role.
          add(const RefreshUser());
        case domain.AuthEvent.authError:
          // The stream hiccuped; this is NOT a sign-out. Re-check the session
          // instead of logging the user out.
          add(const CheckAuthSession());
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
        await _emitForUser(value, emit);
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
        await _emitForUser(value, emit);
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
        await _emitForUser(value, emit);
      case Err(:final error):
        emit(AuthError(error.message));
    }
  }

  Future<void> _onRefreshUser(
    RefreshUser event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUser();
    switch (result) {
      case Ok(:final value):
        await _emitForUser(value, emit);
      case Err(:final error):
        // A transient failure refreshing the profile should not sign the user
        // out; keep the current session and surface the error.
        emit(AuthError(error.message));
    }
  }

  /// Central mapping from a fetched profile to an auth state. A suspended or
  /// unknown role must never reach an authenticated screen: sign out and emit
  /// [AuthSuspended] so the UI can show a blocking message.
  Future<void> _emitForUser(
    UserEntity? value,
    Emitter<AuthState> emit,
  ) async {
    if (value == null) {
      emit(AuthUnauthenticated());
      return;
    }
    if (value.isSuspended || value.role == UserRole.unknown) {
      emit(AuthSuspended());
      if (!_manualLogoutInProgress) {
        _manualLogoutInProgress = true;
        await logout();
        _manualLogoutInProgress = false;
      }
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(value));
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_manualLogoutInProgress) return;
    _manualLogoutInProgress = true;
    try {
      emit(AuthLoading());
      final result = await logout();
      switch (result) {
        case Ok():
          emit(AuthUnauthenticated());
        case Err(:final error):
          emit(AuthError(error.message));
      }
    } finally {
      _manualLogoutInProgress = false;
    }
  }
}
