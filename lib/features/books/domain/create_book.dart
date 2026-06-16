import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class CreateBook {
  final BookRepository repository;

  CreateBook(this.repository);

  Future<void> call(BookEntity book) async {
    return await repository.createBook(book);
  }
}
