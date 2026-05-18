import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// GenreState es una clase abstracta que representa los diferentes estados relacionados con la gestión de géneros en la aplicación. Esta clase se extiende para crear estados específicos como GenreInitial, GenreLoading, GenreLoaded y GenreError, cada uno representando un estado particular del proceso de carga y manejo de géneros. La interfaz de usuario puede reaccionar a estos estados para mostrar información relevante al usuario, como una lista de géneros cargados o un mensaje de error.
abstract class GenreState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial del Bloc de géneros. Este estado se emite cuando el Bloc se crea por primera vez y no se ha realizado ninguna acción relacionada con los géneros. La interfaz de usuario puede mostrar un estado vacío o un mensaje de bienvenida mientras espera a que se carguen los géneros.
class GenreInitial extends GenreState {}

// Estado que representa la carga en progreso de los géneros. Este estado se emite cuando se inicia el proceso de carga de géneros, y la interfaz de usuario puede mostrar un indicador de carga para informar al usuario que los géneros están siendo cargados.
class GenreLoading extends GenreState {}

// Estado que representa la carga exitosa de una lista de géneros. Este estado se emite cuando los géneros se han cargado correctamente, y contiene una lista de GenreEntity que representa los géneros cargados para que la interfaz de usuario pueda mostrarlos al usuario.
class GenreLoaded extends GenreState {
  final List<GenreEntity> genres;

  GenreLoaded(this.genres);

  @override
  List<Object> get props => [genres];
}

// Estado que representa un error ocurrido durante la carga de géneros. Este estado se emite cuando ocurre un error al intentar cargar los géneros, y contiene un mensaje descriptivo del error para que la interfaz de usuario pueda mostrarlo al usuario.
class GenreError extends GenreState {
  final String message;

  GenreError(this.message);

  @override
  List<Object> get props => [message];
}
