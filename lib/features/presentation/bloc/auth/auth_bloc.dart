import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/auth/domain/login.dart';
import 'package:noveles/features/auth/domain/register.dart';
import 'package:noveles/features/auth/domain/logout.dart';
import 'package:noveles/features/auth/domain/get_current_user.dart';
import 'package:noveles/features/auth/domain/listen_auth_state.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_event.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

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

  /// Listens for auth state changes (signedOut) and emits LogoutRequested
  /// unless the logout was initiated manually (to avoid double-fire).
  void _listenAuthChanges() {
    _authSubscription = listenAuthState().listen((event) {
      if (event == AuthChangeEvent.signedOut && !_manualLogoutInProgress) {
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
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await register(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _manualLogoutInProgress = true;
    emit(AuthLoading());
    try {
      await logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    } finally {
      _manualLogoutInProgress = false;
    }
  }
}
