import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class UpdateBook {
  final BookRepository repository;

  UpdateBook(this.repository);

  Future<void> call(BookEntity book) async {
    return await repository.updateBook(book);
  }
}
