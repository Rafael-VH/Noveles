import 'package:equatable/equatable.dart';

// Define los eventos que el BookBloc puede manejar, como cargar libros, géneros, subir portadas, guardar o eliminar libros, tomos y capítulos
abstract class BookEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Evento que representa la solicitud de carga de la lista de libros. Este evento se emite cuando se desea obtener la lista completa de libros disponibles, y el Bloc responderá a este evento cargando los libros y emitiendo el estado correspondiente.
class LoadBooks extends BookEvent {}

// Evento que representa la solicitud de carga de los detalles de un libro específico. Este evento se emite cuando se desea obtener la información detallada de un libro en particular, y contiene el ID del libro para identificar cuál es el libro cuyos detalles se deben cargar.
class LoadBookById extends BookEvent {
  final int id;

  LoadBookById(this.id);

  @override
  List<Object> get props => [id];
}
