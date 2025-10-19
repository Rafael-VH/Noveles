import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class UpdateBook {
  final BookRepository repository;

  UpdateBook(this.repository);

  Future<void> call(BookEntity book) async {
    return await repository.updateBook(book);
  }
}
