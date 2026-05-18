import 'package:noveles/features/domain/repositories/repositories.dart';

class ToggleBookVisibility {
  final BookRepository repository;

  ToggleBookVisibility(this.repository);

  Future<void> call(int bookId, bool isVisible) async {
    return await repository.toggleBookVisibility(bookId, isVisible);
  }
}
