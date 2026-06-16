import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class ToggleBookVisibility {
  final BookRepository repository;

  ToggleBookVisibility(this.repository);

  Future<Result<void>> call(int bookId, bool isVisible) async {
    return repository.toggleBookVisibility(bookId, isVisible);
  }
}
