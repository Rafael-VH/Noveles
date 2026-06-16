import 'package:equatable/equatable.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

// This file defines the events for the ScanBloc, which manages the state of the book scanning feature in the application. Each event
// corresponds to a specific user action or operation related to books, tooks, chapters, genres, and cover uploads. The events are
// designed to trigger state changes in the ScanBloc, allowing the UI to react accordingly based on the latest data from the backend
// and user interactions.
abstract class ScanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Load the list of books and emit the loaded state with the retrieved books to update the UI with the latest data from the backend.
class LoadScanBooks extends ScanEvent {}

// Load the list of genres and emit the loaded state with the retrieved genres to update the UI with the latest data from the backend.
class LoadScanGenres extends ScanEvent {}

// Upload a cover image and emit the uploaded state with the filename to update the UI with the new cover image after a successful
// upload, ensuring a responsive user experience.
class UploadScanCover extends ScanEvent {
  final String filePath;

  UploadScanCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// Save a book (create or update) and refresh the list of books after the operation to ensure the UI reflects the latest data
// from the backend, preventing issues with stale data and ensuring a consistent user experience.
class SaveScanBook extends ScanEvent {
  final BookEntity book;
  final bool isUpdate;

  SaveScanBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

// Delete a book by ID and refresh the list of books after deletion to ensure the UI is updated correctly with the latest data
// from the backend, avoiding potential issues with stale data.
class DeleteScanBook extends ScanEvent {
  final int bookId;

  DeleteScanBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

// Save a took (create or update) and refresh the list of books after the operation to ensure the UI reflects the latest data
// from the backend, preventing issues with stale data and ensuring a consistent user experience.
class SaveScanTook extends ScanEvent {
  final TookEntity took;
  final bool isUpdate;

  SaveScanTook(this.took, {required this.isUpdate});

  @override
  List<Object> get props => [took, isUpdate];
}

// Delete a took by ID and refresh the list of books after deletion to ensure the UI is updated correctly with the latest data
// from the backend, avoiding potential issues with stale data and ensuring a consistent user experience.
class DeleteScanTook extends ScanEvent {
  final int tookId;

  DeleteScanTook(this.tookId);

  @override
  List<Object> get props => [tookId];
}

// Save a chapter (create or update) and refresh the list of books after the operation to ensure the UI reflects the latest data
// from the backend, preventing issues with stale data and ensuring a consistent user experience.
class SaveScanChapter extends ScanEvent {
  final ChapterEntity chapter;
  final bool isUpdate;

  SaveScanChapter(this.chapter, {required this.isUpdate});

  @override
  List<Object> get props => [chapter, isUpdate];
}

// Delete a chapter by ID and refresh the list of books after deletion to ensure the UI is updated correctly with the latest data
// from the backend, avoiding potential issues with stale data and ensuring a consistent user experience.
class DeleteScanChapter extends ScanEvent {
  final int chapterId;

  DeleteScanChapter(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

// Toggle visibility of a book for users and refresh the list of books after the operation to ensure the UI reflects
// the latest data from the backend, preventing issues with stale data and ensuring a consistent user experience.
class ToggleScanBookVisibility extends ScanEvent {
  final int bookId;
  final bool isVisible;

  ToggleScanBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
