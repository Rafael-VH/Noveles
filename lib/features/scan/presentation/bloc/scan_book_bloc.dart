import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:noveles/core/errors/result.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_state.dart';

export 'package:noveles/features/scan/presentation/bloc/scan_book_event.dart';
export 'package:noveles/features/scan/presentation/bloc/scan_book_state.dart';

class ScanBookBloc extends Bloc<ScanBookEvent, ScanBookState> {
  final GetBooks getBooks;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final ToggleBookVisibility toggleBookVisibility;

  ScanBookBloc({
    required this.getBooks,
    required this.createBook,
    required this.updateBook,
    required this.deleteBook,
    required this.toggleBookVisibility,
  }) : super(ScanBookInitial()) {
    on<LoadScanBooks>(_onLoadBooks);
    on<SaveScanBook>(_onSaveBook);
    on<DeleteScanBook>(_onDeleteBook);
    on<ToggleScanBookVisibility>(_onToggleVisibility);
  }

  Future<void> _onLoadBooks(
    LoadScanBooks event,
    Emitter<ScanBookState> emit,
  ) async {
    emit(ScanBookLoading());
    final result = await getBooks();
    switch (result) {
      case Ok(:final value):
        emit(ScanBookLoaded(value));
      case Err(:final error):
        emit(ScanBookError(error.message));
    }
  }

  Future<void> _onSaveBook(
    SaveScanBook event,
    Emitter<ScanBookState> emit,
  ) async {
    final saveResult = event.isUpdate
        ? await updateBook(event.book)
        : await createBook(event.book);
    switch (saveResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanBookLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanBookLoaded(value,
                message: event.isUpdate ? 'Libro guardado' : 'Libro creado'));
          case Err(:final error):
            emit(ScanBookLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanBookError(error.message));
    }
  }

  Future<void> _onDeleteBook(
    DeleteScanBook event,
    Emitter<ScanBookState> emit,
  ) async {
    final deleteResult = await deleteBook(event.bookId);
    switch (deleteResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanBookLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanBookLoaded(value, message: 'Libro eliminado'));
          case Err(:final error):
            emit(ScanBookLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanBookError(error.message));
    }
  }

  Future<void> _onToggleVisibility(
    ToggleScanBookVisibility event,
    Emitter<ScanBookState> emit,
  ) async {
    final toggleResult =
        await toggleBookVisibility(event.bookId, event.isVisible);
    switch (toggleResult) {
      case Ok():
        final previousBooks = switch (state) {
          ScanBookLoaded(:final books) => books,
          _ => <BookWithRelations>[],
        };
        final booksResult = await getBooks();
        switch (booksResult) {
          case Ok(:final value):
            emit(ScanBookLoaded(value,
                message: event.isVisible
                    ? 'Novela visible para usuarios'
                    : 'Novela oculta'));
          case Err(:final error):
            emit(ScanBookLoaded(previousBooks,
                message: 'Error al refrescar: ${error.message}'));
        }
      case Err(:final error):
        emit(ScanBookError(error.message));
    }
  }
}
