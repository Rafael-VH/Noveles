import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class CreateBook {
  final BookRepository repository;

  CreateBook(this.repository);

  Future<void> call(BookEntity book) async {
    return await repository.createBook(book);
  }
}
