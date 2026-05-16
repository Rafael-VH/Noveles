import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadAdminBooks extends AdminEvent {}

class LoadAdminGenres extends AdminEvent {}

class UploadAdminCover extends AdminEvent {
  final String filePath;

  UploadAdminCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class SaveAdminBook extends AdminEvent {
  final BookEntity book;
  final bool isUpdate;

  SaveAdminBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

class DeleteAdminBook extends AdminEvent {
  final int bookId;

  DeleteAdminBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class SaveAdminTook extends AdminEvent {
  final TookEntity took;
  final bool isUpdate;

  SaveAdminTook(this.took, {required this.isUpdate});

  @override
  List<Object> get props => [took, isUpdate];
}

class DeleteAdminTook extends AdminEvent {
  final int tookId;

  DeleteAdminTook(this.tookId);

  @override
  List<Object> get props => [tookId];
}

class SaveAdminChapter extends AdminEvent {
  final ChapterEntity chapter;
  final bool isUpdate;

  SaveAdminChapter(this.chapter, {required this.isUpdate});

  @override
  List<Object> get props => [chapter, isUpdate];
}

class DeleteAdminChapter extends AdminEvent {
  final int chapterId;

  DeleteAdminChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}
