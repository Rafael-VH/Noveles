import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// ThemeState es una clase que representa el estado del tema en la aplicación. Contiene una propiedad themeData que almacena la configuración actual del tema, como los colores, las fuentes y otros aspectos visuales. Esta clase extiende Equatable para facilitar la comparación de estados y evitar emisiones innecesarias cuando el estado no ha cambiado. La interfaz de usuario puede reaccionar a los cambios en el estado del tema para actualizar la apariencia de la aplicación en consecuencia.
class ThemeState extends Equatable {
  final ThemeData themeData;

  const ThemeState(this.themeData);

  @override
  List<Object> get props => [themeData];
}
