import 'package:bloc/bloc.dart';
import 'package:noveles/features/main/domain/use_cases/use_cases.dart';
import 'package:noveles/features/main/presentation/bloc/book_event.dart';
import 'package:noveles/features/main/presentation/bloc/book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;
  final GetBookById getBookById;

  BookBloc(this.getBooks, this.getBookById) : super(BookInitial());

  @override
  // ignore: override_on_non_overriding_member
  Stream<BookState> mapEventToState(BookEvent event) async* {
    if (event is LoadBooks) {
      yield BookLoading();
      try {
        final books = await getBooks();
        yield BookLoaded(books);
      } catch (e) {
        yield BookError(e.toString());
      }
    } else if (event is LoadBookById) {
      yield BookLoading();
      try {
        final book = await getBookById(event.id);
        if (book != null) {
          yield BookDetailLoaded(book);
        } else {
          yield BookError('Book not found');
        }
      } catch (e) {
        yield BookError(e.toString());
      }
    }
  }
}
