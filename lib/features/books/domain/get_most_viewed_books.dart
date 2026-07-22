import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class GetMostViewedBooks {
  final BookRepository repository;
  GetMostViewedBooks(this.repository);
  Future<Result<List<BookWithRelations>>> call() =>
      repository.getMostViewedBooks();
}
