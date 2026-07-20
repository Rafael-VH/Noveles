import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/books/presentation/bloc/book_event.dart';
export 'package:noveles/features/books/presentation/bloc/book_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/get_book_by_id.dart';
import 'package:noveles/features/books/presentation/bloc/book_event.dart';
import 'package:noveles/features/books/presentation/bloc/book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;
  final GetBookById getBookById;
  final bool onlyVisible;
  static const int pageSize = 50;

  BookBloc({
    required this.getBooks,
    required this.getBookById,
    this.onlyVisible = false,
  }) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadMoreBooks>(_onLoadMoreBooks);
    on<LoadBookById>(_onLoadBookById);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    final result = await getBooks(
      onlyVisible: onlyVisible,
      page: 1,
      pageSize: pageSize,
    );
    switch (result) {
      case Ok(:final value):
        emit(BookLoaded(
          value,
          hasMore: value.length >= pageSize,
        ));
      case Err(:final error):
        emit(BookError(error.message));
    }
  }

  Future<void> _onLoadMoreBooks(
    LoadMoreBooks event,
    Emitter<BookState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookLoaded) return;

    final result = await getBooks(
      onlyVisible: onlyVisible,
      page: event.page,
      pageSize: pageSize,
    );
    switch (result) {
      case Ok(:final value):
        emit(BookLoaded(
          [...currentState.books, ...value],
          hasMore: value.length >= pageSize,
        ));
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
