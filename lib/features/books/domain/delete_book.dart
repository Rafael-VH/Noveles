import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class DeleteBook {
  final BookRepository repository;

  DeleteBook(this.repository);

  Future<Result<void>> call(int id) async {
    return repository.deleteBook(id);
  }
}
