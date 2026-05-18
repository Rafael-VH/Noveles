import 'package:equatable/equatable.dart';

// Define los eventos que el AuthBloc puede manejar, como cargar libros, géneros, subir portadas, guardar o eliminar libros, tomos y capítulos. Cada evento tiene su propia clase que extiende AdminEvent y puede contener datos relevantes para ese evento específico.
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evento para verificar si hay una sesión de autenticación activa. Este evento se emite cuando la aplicación se inicia o cuando se necesita verificar el estado de autenticación del usuario, y el AuthBloc responderá a este evento comprobando si hay una sesión válida y emitiendo un estado de autenticado o no autenticado según corresponda.
class CheckAuthSession extends AuthEvent {}

// Evento para solicitar el inicio de sesión del usuario con correo electrónico y contraseña. Este evento se emite cuando el usuario intenta iniciar sesión, y el AuthBloc responderá a este evento verificando las credenciales proporcionadas y emitiendo un estado de autenticado o no autenticado según corresponda.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Evento para solicitar la registro
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  RegisterRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

// Evento para solicitar el cierre de sesión del usuario. Este evento se emite cuando el usuario decide cerrar sesión, y el AuthBloc responderá a este evento limpiando la sesión de autenticación y emitiendo un estado de no autenticado.
class LogoutRequested extends AuthEvent {}
