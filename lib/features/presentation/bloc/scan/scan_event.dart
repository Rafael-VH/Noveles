import 'package:equatable/equatable.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

// This file defines the events for the ScanBloc, which manages the state of the book scanning feature in the application. Each event
// corresponds to a specific user action or operation related to books, tooks, chapters, genres, and cover uploads. The events are
// designed to trigger state changes in the ScanBloc, allowing the UI to react accordingly based on the latest data from the backend
// and user interactions.
abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

// Load the list of books and emit the loaded state with the retrieved books to update the UI with the latest data from the backend.
class LoadScanBooks extends ScanEvent {
  const LoadScanBooks();
}

// Load the list of genres and emit the loaded state with the retrieved genres to update the UI with the latest data from the backend.
class LoadScanGenres extends ScanEvent {
  const LoadScanGenres();
}

// Upload a cover image and emit the uploaded state with the filename to update the UI with the new cover image after a successful
// upload, ensuring a responsive user experience.
class UploadScanCover extends ScanEvent {
  final String filePath;

  const UploadScanCover(this.filePath);

  @override
  List<Object> get props => [filePath];
}

// Save a book (create or update) and refresh the list of books after the operation to ensure the UI reflects the latest data
// from the backend, preventing issues with stale data and ensuring a consistent user experience.
class SaveScanBook extends ScanEvent {
  final BookEntity book;
  final bool isUpdate;

  const SaveScanBook(this.book, {required this.isUpdate});

  @override
  List<Object> get props => [book, isUpdate];
}

// Delete a book by ID and refresh the list of books after deletion to ensure the UI is updated correctly with the latest data
// from the backend, avoiding potential issues with stale data.
class DeleteScanBook extends ScanEvent {
  final int bookId;

  const DeleteScanBook(this.bookId);

  @override
  List<Object> get props => [bookId];
}

// Toggle visibility of a book for users and refresh the list of books after the operation to ensure the UI reflects
// the latest data from the backend, preventing issues with stale data and ensuring a consistent user experience.
class ToggleScanBookVisibility extends ScanEvent {
  final int bookId;
  final bool isVisible;

  const ToggleScanBookVisibility(this.bookId, this.isVisible);

  @override
  List<Object> get props => [bookId, isVisible];
}
