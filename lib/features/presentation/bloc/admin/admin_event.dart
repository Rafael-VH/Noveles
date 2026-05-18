import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

// Define los eventos que el AdminBloc puede manejar, como cargar libros, géneros, subir portadas, guardar o eliminar libros, tomos y capítulos. Cada evento tiene su propia clase que extiende AdminEvent y puede contener datos relevantes para ese evento específico.
abstract class AdminEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Carga los libros y mantiene los géneros cargados si ya se han cargado
class LoadAdminBooks extends AdminEvent {}

// Carga los géneros y mantiene los libros cargados si ya se han cargado
class LoadAdminGenres extends AdminEvent {}

// Sube una portada y emite el estado con el nombre del archivo subido o un error si falla
class UploadAdminCover extends AdminEvent {
  final String filePath;

  UploadAdminCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// Guarda o actualiza un libro, luego recarga la lista de libros para reflejar los cambios
class SaveAdminBook extends AdminEvent {
  final BookEntity book;
  final bool isUpdate;

  SaveAdminBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

// Elimina un libro, luego recarga la lista de libros para reflejar los cambios
class DeleteAdminBook extends AdminEvent {
  final int bookId;

  DeleteAdminBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

// Guarda o actualiza un tomo, luego recarga la lista de libros para reflejar los cambios
class SaveAdminTook extends AdminEvent {
  final TookEntity took;
  final bool isUpdate;

  SaveAdminTook(this.took, {required this.isUpdate});

  @override
  List<Object> get props => [took, isUpdate];
}

// Elimina un tomo, luego recarga la lista de libros para reflejar los cambios
class DeleteAdminTook extends AdminEvent {
  final int tookId;

  DeleteAdminTook(this.tookId);

  @override
  List<Object> get props => [tookId];
}

// Guarda o actualiza un capítulo, luego recarga la lista de libros para reflejar los cambios
class SaveAdminChapter extends AdminEvent {
  final ChapterEntity chapter;
  final bool isUpdate;

  SaveAdminChapter(this.chapter, {required this.isUpdate});

  @override
  List<Object> get props => [chapter, isUpdate];
}

// Elimina un capítulo, luego recarga la lista de libros para reflejar los cambios
class DeleteAdminChapter extends AdminEvent {
  final int chapterId;

  DeleteAdminChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}
