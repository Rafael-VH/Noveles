import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/get_book_by_id.dart';
import 'package:noveles/features/presentation/bloc/book/book_event.dart';
import 'package:noveles/features/presentation/bloc/book/book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;
  final GetBookById getBookById;
  final bool onlyVisible;

  BookBloc({
    required this.getBooks,
    required this.getBookById,
    this.onlyVisible = false,
  }) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadBookById>(_onLoadBookById);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    final result = await getBooks(onlyVisible: onlyVisible);
    switch (result) {
      case Ok(:final value):
        emit(BookLoaded(value));
      case Err(:final error):
        emit(BookError(error.message));
    }
  }

  Future<void> _onLoadBookById(
    LoadBookById event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    final result = await getBookById(event.id);
    switch (result) {
      case Ok(:final value):
        if (value != null) {
          emit(BookDetailLoaded(value));
        } else {
          emit(BookError('Libro no encontrado'));
        }
      case Err(:final error):
        emit(BookError(error.message));
    }
  }
}
