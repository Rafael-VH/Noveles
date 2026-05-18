import 'package:equatable/equatable.dart';

// ThemeEvent es una clase abstracta que representa los diferentes eventos relacionados con el tema en la aplicación
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

// Evento para cambiar el tema. Este evento se emite cuando el usuario decide cambiar entre el modo claro y el modo oscuro en la aplicación. Contiene un campo booleano isDarkMode que indica si el nuevo tema debe ser oscuro o claro. La interfaz de usuario puede reaccionar a este evento actualizando la apariencia de la aplicación para reflejar el nuevo tema seleccionado por el usuario.
class ThemeChanged extends ThemeEvent {
  final bool isDarkMode;

  const ThemeChanged(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}
