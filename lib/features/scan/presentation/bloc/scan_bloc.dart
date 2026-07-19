import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/scan/presentation/bloc/scan_event.dart';
export 'package:noveles/features/scan/presentation/bloc/scan_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/upload_cover.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final GetBooks getBooks;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final GetGenre getGenres;
  final UploadCover uploadCover;
  final ToggleBookVisibility toggleBookVisibility;

  ScanBloc({
    required this.getBooks,
    required this.createBook,
    required this.updateBook,
    required this.deleteBook,
    required this.getGenres,
    required this.uploadCover,
    required this.toggleBookVisibility,
  }) : super(ScanInitial()) {
    on<LoadScanBooks>(_onLoadBooks);
    on<LoadScanGenres>(_onLoadGenres);
    on<UploadScanCover>(_onUploadCover);
    on<SaveScanBook>(_onSaveBook);
    on<DeleteScanBook>(_onDeleteBook);
    on<ToggleScanBookVisibility>(_onToggleVisibility);
  }

  // Upload a cover image and emit the uploaded state with the filename to update the UI with the new cover image after a successful
  // upload, ensuring a responsive user experience.
  Future<void> _onUploadCover(
    UploadScanCover event,
    Emitter<ScanState> emit,
  ) async {
    final result = await uploadCover(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanCoverUploaded(value));
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }

  // Load the list of genres and emit the loaded state with the retrieved genres to update the UI with the latest data from the backend.
  Future<void> _onLoadGenres(
    LoadScanGenres event,
    Emitter<ScanState> emit,
  ) async {
    final result = await getGenres();
    switch (result) {
      case Ok(:final value):
        final currentState = state;
        final books = switch (currentState) {
          ScanLoaded(:final books) => books,
          ScanGenresLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        emit(ScanGenresLoaded(books, value));
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }

  // Load the list of books and emit the loaded state with the retrieved books to update the UI with the latest data from the backend.
  Future<void> _onLoadBooks(
    LoadScanBooks event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    final result = await getBooks();
    switch (result) {
      case Ok(:final value):
        emit(ScanLoaded(value));
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }

  // Save a book (create or update) and refresh the list of books after the operation to ensure the UI reflects the latest data
  // from the backend, preventing issues with stale data and ensuring a consistent user experience.
  Future<void> _onSaveBook(
    SaveScanBook event,
    Emitter<ScanState> emit,
  ) async {
    final saveResult = event.isUpdate
        ? await updateBook(event.book)
        : await createBook(event.book);
    switch (saveResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanLoaded(value,
                message: event.isUpdate ? 'Libro guardado' : 'Libro creado'));
          case Err(:final error):
            emit(ScanLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }

  // Delete a book by ID and refresh the list of books after deletion to ensure the UI is updated correctly with the latest data
  // from the backend, avoiding potential issues with stale data.
  Future<void> _onDeleteBook(
    DeleteScanBook event,
    Emitter<ScanState> emit,
  ) async {
    final deleteResult = await deleteBook(event.bookId);
    switch (deleteResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanLoaded(value, message: 'Libro eliminado'));
          case Err(:final error):
            emit(ScanLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }

  // Toggle visibility of a book for users and refresh the list of books after the operation to ensure the UI reflects the latest
  // data from the backend, preventing issues with stale data and ensuring a consistent user experience.
  Future<void> _onToggleVisibility(
    ToggleScanBookVisibility event,
    Emitter<ScanState> emit,
  ) async {
    final toggleResult =
        await toggleBookVisibility(event.bookId, event.isVisible);
    switch (toggleResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanLoaded(value,
                message: event.isVisible
                    ? 'Novela visible para usuarios'
                    : 'Novela oculta'));
          case Err(:final error):
            emit(ScanLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanError(error.message));
    }
  }
}
