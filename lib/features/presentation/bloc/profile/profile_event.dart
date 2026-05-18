import 'dart:io';
import 'package:equatable/equatable.dart';

// ProfileEvent es una clase abstracta que representa los diferentes eventos relacionados con la gestión del perfil en la aplicación. Esta clase se extiende para crear eventos específicos como LoadProfile, UpdateProfile, PickAvatar y ChangePassword, cada uno representando una acción particular que el usuario puede realizar en relación con su perfil. La interfaz de usuario puede emitir estos eventos para iniciar procesos como cargar el perfil, actualizar la información del perfil, seleccionar un nuevo avatar o cambiar la contraseña, y el Bloc de perfil reaccionará a estos eventos para actualizar el estado de la aplicación en consecuencia.
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evento para cargar el perfil del usuario. Este evento se emite cuando se desea obtener la información del perfil del usuario, como su nombre de usuario, biografía y avatar. La interfaz de usuario puede reaccionar a este evento mostrando un indicador de carga mientras se obtiene la información del perfil, y luego mostrando los datos del perfil una vez que se hayan cargado correctamente.
class LoadProfile extends ProfileEvent {}

// Evento para actualizar el perfil. Este evento se emite cuando el usuario realiza cambios en su perfil, como actualizar su nombre de usuario (displayName) o su biografía (bio). Contiene campos opcionales para el nombre de usuario y la biografía, lo que permite al usuario actualizar solo una de estas propiedades si lo desea. La interfaz de usuario puede reaccionar a este evento mostrando un indicador de carga mientras se actualiza el perfil, y luego mostrando un mensaje de éxito o error según el resultado de la operación.
class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? bio;

  UpdateProfile({this.displayName, this.bio});

  @override
  List<Object> get props => [displayName ?? '', bio ?? ''];
}

// Evento para seleccionar un nuevo avatar para el perfil. Este evento se emite cuando el usuario elige una nueva imagen de avatar, y contiene un archivo que representa la imagen seleccionada. La interfaz de usuario puede reaccionar a este evento mostrando una vista previa del nuevo avatar antes de que se guarden los cambios en el perfil, y luego actualizando el avatar mostrado una vez que se complete la operación de guardado.
class PickAvatar extends ProfileEvent {
  final File file;

  PickAvatar(this.file);

  @override
  List<Object> get props => [file.path];
}

// Evento para guardar el perfil, que puede incluir cambios en el nombre de usuario, biografía y avatar. Este evento se emite cuando el usuario decide guardar los cambios realizados en su perfil. Contiene campos opcionales para el nombre de usuario (displayName), la biografía (bio) y un archivo de imagen (avatar) que representa el nuevo avatar del usuario. La interfaz de usuario puede reaccionar a este evento mostrando un indicador de carga mientras se guarda el perfil, y luego actualizando la información mostrada al usuario una vez que se complete la operación.
class ChangePassword extends ProfileEvent {
  final String newPassword;

  ChangePassword(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}
