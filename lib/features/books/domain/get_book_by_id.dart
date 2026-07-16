import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<Result<BookWithRelations?>> call(int id) async {
    return repository.getBookById(id);
  }
}
