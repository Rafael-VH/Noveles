import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class UpdateBook {
  final BookRepository repository;

  UpdateBook(this.repository);

  Future<Result<void>> call(BookEntity book) async {
    return repository.updateBook(book);
  }
}
