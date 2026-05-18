import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_event.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// AuthBloc es un Bloc que maneja los eventos y estados relacionados con la autenticación de usuarios en la aplicación. Utiliza casos de uso para interactuar con el dominio y actualizar el estado en consecuencia. El AuthBloc escucha eventos como verificar la sesión de autenticación, iniciar sesión, registrarse y cerrar sesión, y emite estados que reflejan el resultado de esas operaciones, como autenticado, no autenticado, carga en progreso o error.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  StreamSubscription? _authSubscription;
  bool _manualLogoutInProgress = false;

  AuthBloc({
    required this.login,
    required this.register,
    required this.logout,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<CheckAuthSession>(_onCheckSession);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    _listenAuthChanges();
  }

  // Escucha los cambios en el estado de autenticación utilizando la función onAuthStateChange de Supabase. Si se detecta un evento de cierre de sesión (signedOut) y no se está realizando un cierre de sesión manual, se agrega el evento LogoutRequested al Bloc para manejar el cierre de sesión de manera adecuada.
  void _listenAuthChanges() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut && !_manualLogoutInProgress) {
        add(LogoutRequested());
      }
    });
  }

  // Asegura que la suscripción al cambio de autenticación se cancele correctamente cuando el Bloc se cierre para evitar fugas de memoria.
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  // Maneja el evento de verificación de sesión, asegurándose de que el estado se actualice correctamente según si hay una sesión de autenticación activa o no. Este método también maneja errores que puedan ocurrir durante la verificación de la sesión y emite un estado de no autenticado si ocurre algún error.
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

  // Maneja el evento de inicio de sesión, asegurándose de que el estado se actualice correctamente durante el proceso de autenticación. Este método también maneja errores que puedan ocurrir durante el inicio de sesión y emite un estado de error con un mensaje descriptivo.
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

  // Maneja el evento de registro, asegurándose de que el estado se actualice correctamente según el resultado del intento de registro. Este método también maneja cualquier error que pueda ocurrir durante el proceso de registro y emite un estado de error con un mensaje descriptivo para que la interfaz de usuario pueda mostrarlo al usuario.
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

  // Maneja el evento de cierre de sesión, asegurándose de que el estado se actualice correctamente y que la sesión de autenticación se limpie. Este método también maneja un indicador para evitar que el cierre de sesión manual desencadene eventos adicionales no deseados.
  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _manualLogoutInProgress = true;
    emit(AuthLoading());
    try {
      if (supabase.auth.currentUser != null) {
        await logout();
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    } finally {
      _manualLogoutInProgress = false;
    }
  }
}
