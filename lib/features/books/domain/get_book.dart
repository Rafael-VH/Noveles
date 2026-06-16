import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<Result<List<BookEntity>>> call({bool onlyVisible = false}) async {
    return repository.getBooks(onlyVisible: onlyVisible);
  }
}
