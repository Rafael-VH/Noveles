import 'package:noveles/features/books/domain/book_repository.dart';

class GetBookLabels {
  final BookRepository repository;

  GetBookLabels(this.repository);

  Future<Map<int, Set<int>>> call() => repository.getBookLabels();
}
