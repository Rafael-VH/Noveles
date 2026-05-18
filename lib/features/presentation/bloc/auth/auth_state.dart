import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// Define los estados que el AuthBloc puede emitir, como el estado inicial, estado de carga, estado de autenticado, estado de no autenticado y estado de error. Cada estado tiene su propia clase que extiende AuthState y puede contener datos relevantes para ese estado específico.
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial para el AuthBloc, que se emite cuando no se ha realizado ninguna acción de autenticación. Este estado puede ser utilizado por la interfaz de usuario para mostrar una pantalla de inicio de sesión o un mensaje de bienvenida antes de que el usuario intente autenticarse.
class AuthInitial extends AuthState {}

// Estado de carga para el AuthBloc, que se emite cuando se están realizando operaciones de autenticación, como iniciar sesión o registrarse. Este estado puede ser utilizado por la interfaz de usuario para mostrar un indicador de carga mientras se procesa la autenticación del usuario.
class AuthLoading extends AuthState {}

// Estado que representa que el usuario está autenticado, conteniendo la información del usuario autenticado. Este estado se emite después de que el usuario ha iniciado sesión correctamente, y puede ser utilizado por la interfaz de usuario para mostrar información personalizada o para permitir el acceso a funciones restringidas solo para usuarios autenticados.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

// Estado que representa que el usuario no está autenticado. Este estado se emite cuando el usuario ha cerrado sesión o cuando la autenticación ha fallado, y puede ser utilizado por la interfaz de usuario para mostrar una pantalla de inicio de sesión o un mensaje indicando que el usuario no tiene acceso a ciertas funciones hasta que inicie sesión nuevamente.
class AuthUnauthenticated extends AuthState {}

// Estado de error para el AuthBloc, que contiene un mensaje de error que se puede mostrar en la interfaz de usuario. Este estado se emite cuando ocurre un error durante cualquier operación de autenticación, como iniciar sesión, registrarse o cerrar sesión.
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
