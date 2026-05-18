import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/book/book_event.dart';
import 'package:noveles/features/presentation/bloc/book/book_state.dart';

// BookBloc es una clase que extiende Bloc y se encarga de manejar los eventos relacionados con los libros y emitir los estados correspondientes. Este Bloc utiliza los casos de uso GetBooks y GetBookById para obtener la lista de libros y los detalles de un libro específico, respectivamente. El Bloc escucha los eventos LoadBooks y LoadBookById, y en respuesta a estos eventos, realiza las operaciones necesarias para cargar los libros o los detalles del libro, emitiendo estados como BookLoading, BookLoaded, BookDetailLoaded o BookError según corresponda.
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

  // Método que maneja el evento LoadBooks, que se encarga de cargar la lista de libros. Este método emite un estado de carga mientras se realiza la operación, y luego emite un estado de éxito con la lista de libros o un estado de error si ocurre algún problema durante la carga.
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

  // Método que maneja el evento LoadBookById, que se encarga de cargar los detalles de un libro específico. Este método emite un estado de carga mientras se realiza la operación, y luego emite un estado de éxito con los detalles del libro o un estado de error si ocurre algún problema durante la carga.
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
