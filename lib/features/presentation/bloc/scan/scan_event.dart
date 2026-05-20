import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class ScanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadScanBooks extends ScanEvent {}

class LoadScanGenres extends ScanEvent {}

class UploadScanCover extends ScanEvent {
  final String filePath;

  UploadScanCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class SaveScanBook extends ScanEvent {
  final BookEntity book;
  final bool isUpdate;

  SaveScanBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

class DeleteScanBook extends ScanEvent {
  final int bookId;

  DeleteScanBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class SaveScanTook extends ScanEvent {
  final TookEntity took;
  final bool isUpdate;

  SaveScanTook(this.took, {required this.isUpdate});

  @override
  List<Object> get props => [took, isUpdate];
}

class DeleteScanTook extends ScanEvent {
  final int tookId;

  DeleteScanTook(this.tookId);

  @override
  List<Object> get props => [tookId];
}

class SaveScanChapter extends ScanEvent {
  final ChapterEntity chapter;
  final bool isUpdate;

  SaveScanChapter(this.chapter, {required this.isUpdate});

  @override
  List<Object> get props => [chapter, isUpdate];
}

class DeleteScanChapter extends ScanEvent {
  final int chapterId;

  DeleteScanChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

class ToggleScanBookVisibility extends ScanEvent {
  final int bookId;
  final bool isVisible;

  ToggleScanBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
