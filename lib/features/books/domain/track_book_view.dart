import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class TrackBookView {
  final BookRepository repository;

  TrackBookView(this.repository);

  Future<Result<void>> call(int bookId) async {
    return repository.trackBookView(bookId);
  }
}
