import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
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
    try {
      final books = await getBooks(onlyVisible: onlyVisible);
      emit(BookLoaded(books));
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }

  Future<void> _onLoadBookById(
    LoadBookById event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final book = await getBookById(event.id);
      if (book != null) {
        emit(BookDetailLoaded(book));
      } else {
        emit(BookError('Libro no encontrado'));
      }
    } catch (e) {
      emit(BookError(e.toString()));
    }
  }
}
