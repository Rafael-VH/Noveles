import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// Define los estados que el ScanBloc puede emitir, como el estado inicial, estado de carga, estado de carga exitosa con libros o géneros, estado de portada subida exitosamente y estado de error. Cada estado tiene su propia clase que extiende ScanState y puede contener datos relevantes para ese estado específico.
abstract class ScanState extends Equatable {
  @override
  List<Object> get props => [];
}

// Estado inicial para el ScanBloc, que se emite cuando no se ha realizado ninguna acción administrativa. Este estado puede ser utilizado por la interfaz de usuario para mostrar una pantalla vacía o un mensaje de bienvenida antes de que se carguen los datos administrativos.
class ScanInitial extends ScanState {}

// Estado de carga para el ScanBloc, que se emite cuando se están cargando los datos administrativos, como libros o géneros. Este estado puede ser utilizado por la interfaz de usuario para mostrar un indicador de carga mientras se obtienen los datos necesarios para la administración.
class ScanLoading extends ScanState {}

// Estado que representa la carga exitosa de libros, manteniendo los géneros cargados si ya se han cargado
class ScanLoaded extends ScanState {
  final List<BookEntity> books;
  final String? message;

  ScanLoaded(this.books, {this.message});

  @override
  List<Object> get props => [books, message ?? ''];
}

// Estado que representa la carga exitosa de una portada, conteniendo el nombre del archivo subido. Este estado se emite después de que se haya subido una portada correctamente, y puede ser utilizado por la interfaz de usuario para mostrar el nombre del archivo o para realizar otras acciones relacionadas con la portada recién subida.
class ScanCoverUploaded extends ScanState {
  final String filename;

  ScanCoverUploaded(this.filename);

  @override
  List<Object> get props => [filename];
}

// Estado que representa la carga exitosa de géneros, manteniendo los libros cargados si ya se han cargado. Contiene una lista de libros y una lista de géneros, lo que permite a la interfaz de usuario mostrar ambos conjuntos de datos sin perder ninguno de ellos. Este estado se emite después de cargar los géneros, y si los libros ya se han cargado previamente, se mantienen en el estado para evitar recargas innecesarias.
class ScanGenresLoaded extends ScanState {
  final List<BookEntity> books;
  final List<GenreEntity> genres;

  ScanGenresLoaded(this.books, this.genres);

  @override
  List<Object> get props => [books, genres];
}

// Estado de error para el ScanBloc, que contiene un mensaje de error que se puede mostrar en la interfaz de usuario. Este estado se emite cuando ocurre un error durante cualquier operación administrativa, como cargar libros, géneros, subir portadas, guardar o eliminar libros, tomos o capítulos.
class ScanError extends ScanState {
  final String message;

  ScanError(this.message);

  @override
  List<Object> get props => [message];
}
