import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// Define los eventos que el ScanBloc puede manejar, como cargar libros, géneros, subir portadas, guardar o eliminar libros, tomos y capítulos. Cada evento tiene su propia clase que extiende ScanEvent y puede contener datos relevantes para ese evento específico.
abstract class ScanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Carga los libros y mantiene los géneros cargados si ya se han cargado
class LoadScanBooks extends ScanEvent {}

// Carga los géneros y mantiene los libros cargados si ya se han cargado
class LoadScanGenres extends ScanEvent {}

// Sube una portada y emite el estado con el nombre del archivo subido o un error si falla
class UploadScanCover extends ScanEvent {
  final String filePath;

  UploadScanCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// Guarda o actualiza un libro, luego recarga la lista de libros para reflejar los cambios
class SaveScanBook extends ScanEvent {
  final BookEntity book;
  final bool isUpdate;

  SaveScanBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

// Elimina un libro, luego recarga la lista de libros para reflejar los cambios
class DeleteScanBook extends ScanEvent {
  final int bookId;

  DeleteScanBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

// Guarda o actualiza un tomo, luego recarga la lista de libros para reflejar los cambios
class SaveScanTook extends ScanEvent {
  final TookEntity took;
  final bool isUpdate;

  SaveScanTook(this.took, {required this.isUpdate});

  @override
  List<Object> get props => [took, isUpdate];
}

// Elimina un tomo, luego recarga la lista de libros para reflejar los cambios
class DeleteScanTook extends ScanEvent {
  final int tookId;

  DeleteScanTook(this.tookId);

  @override
  List<Object> get props => [tookId];
}

// Guarda o actualiza un capítulo, luego recarga la lista de libros para reflejar los cambios
class SaveScanChapter extends ScanEvent {
  final ChapterEntity chapter;
  final bool isUpdate;

  SaveScanChapter(this.chapter, {required this.isUpdate});

  @override
  List<Object> get props => [chapter, isUpdate];
}

// Elimina un capítulo, luego recarga la lista de libros para reflejar los cambios
class DeleteScanChapter extends ScanEvent {
  final int chapterId;

  DeleteScanChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}
