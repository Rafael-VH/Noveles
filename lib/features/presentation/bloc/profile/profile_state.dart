import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// ProfileState es una clase abstracta que representa los diferentes estados relacionados con la gestión del perfil en la aplicación. Esta clase se extiende para crear estados específicos como ProfileInitial, ProfileLoading, ProfileLoaded, ProfileSaving y ProfileError, cada uno representando un estado particular del proceso de carga, actualización y manejo del perfil. La interfaz de usuario puede reaccionar a estos estados para mostrar información relevante al usuario, como el perfil cargado, un mensaje de error o un indicador de carga.
abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial del Bloc de perfil. Este estado se emite cuando el Bloc se crea por primera vez y no se ha realizado ninguna acción relacionada con el perfil. La interfaz de usuario puede mostrar un estado vacío o un mensaje de bienvenida mientras espera a que se cargue el perfil.
class ProfileInitial extends ProfileState {}

// Estado que representa la carga en progreso del perfil. Este estado se emite cuando se inicia el proceso de carga del perfil, y la interfaz de usuario puede mostrar un indicador de carga para informar al usuario que el perfil está siendo cargado.
class ProfileLoading extends ProfileState {}

// Estado que representa la carga exitosa del perfil. Este estado se emite cuando el perfil se ha cargado correctamente, y contiene una instancia de UserEntity que representa el perfil cargado. Además, puede contener un archivo opcional pendingAvatar que representa una imagen de avatar pendiente de ser guardada, y un mensaje opcional que puede ser utilizado para mostrar información adicional al usuario, como un mensaje de éxito o una advertencia.
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final File? pendingAvatar;
  final String? message;

  ProfileLoaded(this.user, {this.pendingAvatar, this.message});

  @override
  List<Object> get props => [user, pendingAvatar ?? '', message ?? ''];
}

// Estado que representa el proceso de guardado del perfil. Este estado se emite cuando se inicia el proceso de actualización del perfil, y contiene una instancia de UserEntity que representa el estado actual del perfil que se está guardando. La interfaz de usuario puede mostrar un indicador de carga o un mensaje informativo mientras se realiza la operación de guardado.
class ProfileSaving extends ProfileState {
  final UserEntity user;

  ProfileSaving(this.user);

  @override
  List<Object> get props => [user];
}

// Estado que representa un error ocurrido durante la carga o actualización del perfil. Este estado se emite cuando ocurre un error al intentar cargar o actualizar el perfil, y contiene un mensaje descriptivo del error para que la interfaz de usuario pueda mostrarlo al usuario. Además, puede contener una instancia de UserEntity opcional que representa el estado actual del perfil, lo que permite a la interfaz de usuario mostrar información relevante incluso en caso de error.
class ProfileError extends ProfileState {
  final String message;
  final UserEntity? user;

  ProfileError(this.message, {this.user});

  @override
  List<Object> get props => [message, user ?? ''];
}
