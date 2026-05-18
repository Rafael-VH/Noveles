import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// BookState es una clase abstracta que representa los diferentes estados relacionados con la gestión de libros en la aplicación. Esta clase se extiende para crear estados específicos como BookInitial, BookLoading, BookLoaded, BookError y BookDetailLoaded, cada uno representando un estado particular del proceso de carga y manejo de libros. La interfaz de usuario puede reaccionar a estos estados para mostrar información relevante al usuario, como una lista de libros cargados, un mensaje de error o los detalles de un libro específico.
abstract class BookState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial del Bloc de libros. Este estado se emite cuando el Bloc se crea por primera vez y no se ha realizado ninguna acción relacionada con los libros. La interfaz de usuario puede mostrar un estado vacío o un mensaje de bienvenida mientras espera a que se carguen los libros.
class BookInitial extends BookState {}

// Estado que representa la carga en progreso de los libros. Este estado se emite cuando se inicia el proceso de carga de libros, y la interfaz de usuario puede mostrar un indicador de carga para informar al usuario que los libros están siendo cargados.
class BookLoading extends BookState {}

// Estado que representa la carga exitosa de una lista de libros. Este estado se emite cuando los libros se han cargado correctamente, y contiene una lista de BookEntity que representa los libros cargados para que la interfaz de usuario pueda mostrarlos al usuario.
class BookLoaded extends BookState {
  final List<BookEntity> books;

  BookLoaded(this.books);

  @override
  List<Object> get props => [books];
}

// Estado que representa un error ocurrido durante la carga de libros. Este estado se emite cuando ocurre un error al intentar cargar los libros, y contiene un mensaje descriptivo del error para que la interfaz de usuario pueda mostrarlo al usuario.
class BookError extends BookState {
  final String message;

  BookError(this.message);

  @override
  List<Object> get props => [message];
}

// Estado que representa la carga de los detalles de un libro específico. Este estado se emite cuando se solicita la información detallada de un libro, y contiene una instancia de BookEntity que representa el libro cuyos detalles
class BookDetailLoaded extends BookState {
  final BookEntity book;

  BookDetailLoaded(this.book);

  @override
  List<Object> get props => [book];
}
