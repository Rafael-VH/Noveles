import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class CreateBook {
  final BookRepository repository;

  CreateBook(this.repository);

  Future<Result<int>> call(BookEntity book) async {
    return repository.createBook(book);
  }
}
