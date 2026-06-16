import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class GetBookLabels {
  final BookRepository repository;

  GetBookLabels(this.repository);

  Future<Result<Map<int, Set<int>>>> call() => repository.getBookLabels();
}
