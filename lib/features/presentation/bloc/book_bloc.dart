import 'package:bloc/bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/book_event.dart';
import 'package:noveles/features/presentation/bloc/book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;
  final GetBookById getBookById;

  BookBloc(this.getBooks, this.getBookById) : super(BookInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<LoadBookById>(_onLoadBookById);
  }

  Future<void> _onLoadBooks(
    LoadBooks event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    try {
      final books = await getBooks();
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
