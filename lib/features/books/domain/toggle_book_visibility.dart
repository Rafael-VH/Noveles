import 'package:noveles/features/books/domain/book_repository.dart';

class ToggleBookVisibility {
  final BookRepository repository;

  ToggleBookVisibility(this.repository);

  Future<void> call(int bookId, bool isVisible) async {
    return await repository.toggleBookVisibility(bookId, isVisible);
  }
}
