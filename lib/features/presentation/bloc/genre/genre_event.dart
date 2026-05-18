import 'package:equatable/equatable.dart';

// GenreEvent es una clase abstracta que representa los diferentes eventos relacionados con la gestión de géneros en la aplicación. Esta clase se extiende para crear eventos específicos como LoadGenres, que representa la solicitud de carga de géneros. Este evento se emite cuando se desea obtener la lista de géneros disponibles, y el Bloc puede cargar los géneros correspondientes y emitir el estado adecuado.
abstract class GenreEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evento que representa la solicitud de carga de géneros. Este evento se emite cuando se desea obtener la lista de géneros disponibles, y el Bloc puede cargar los géneros correspondientes y emitir el estado adecuado.
class LoadGenres extends GenreEvent {}
