import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// ChapterState es una clase abstracta que representa los diferentes estados relacionados con la gestión de capítulos en la aplicación. Esta clase se extiende para crear estados específicos como ChapterInitial, ChapterLoading, ChapterLoaded y ChapterError, cada uno representando un estado particular del proceso de carga y manejo de capítulos. La interfaz de usuario puede reaccionar a estos estados para mostrar información relevante al usuario, como una lista de capítulos cargados, un mensaje de error o el capítulo específico que se está mostrando.
abstract class ChapterState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial del Bloc de capítulos. Este estado se emite cuando el Bloc se crea por primera vez y no se ha realizado ninguna acción relacionada con los capítulos. La interfaz de usuario puede mostrar un estado vacío o un mensaje de bienvenida mientras espera a que se carguen los capítulos.
class ChapterInitial extends ChapterState {}

// Estado que representa la carga en progreso de los capítulos. Este estado se emite cuando se inicia el proceso de carga de capítulos, y la interfaz de usuario puede mostrar un indicador de carga para informar al usuario que los capítulos están siendo cargados.
class ChapterLoading extends ChapterState {}

// Estado que representa la carga exitosa de una lista de capítulos. Este estado se emite cuando los capítulos se han cargado correctamente, y contiene una lista de ChapterEntity que representa los capítulos cargados para que la interfaz de usuario pueda mostrarlos al usuario. Además, se incluye un índice inicial opcional para indicar cuál capítulo se debe mostrar primero en la interfaz de usuario.
class ChapterLoaded extends ChapterState {
  final List<ChapterEntity> chapters;
  final int initialIndex;

  ChapterLoaded(this.chapters, {this.initialIndex = 0});

  @override
  List<Object> get props => [chapters, initialIndex];
}

// Estado que representa un error ocurrido durante la carga de capítulos. Este estado se emite cuando ocurre un error al intentar cargar los capítulos, y contiene un mensaje descriptivo del error para que la interfaz de usuario pueda mostrarlo al usuario.
class ChapterError extends ChapterState {
  final String message;

  ChapterError(this.message);

  @override
  List<Object> get props => [message];
}
