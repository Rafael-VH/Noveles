import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<Result<BookEntity?>> call(int id) async {
    return repository.getBookById(id);
  }
}
