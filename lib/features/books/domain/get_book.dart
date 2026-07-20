import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<Result<List<BookWithRelations>>> call({
    bool onlyVisible = false,
    int page = 1,
    int pageSize = 50,
  }) async {
    return repository.getBooks(
      onlyVisible: onlyVisible,
      page: page,
      pageSize: pageSize,
    );
  }
}
