import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<BookEntity?> call(int id) async {
    return await repository.getBookById(id);
  }
}
