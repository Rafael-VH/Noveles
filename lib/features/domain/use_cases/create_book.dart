import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class CreateBook {
  final BookRepository repository;

  CreateBook(this.repository);

  Future<void> call(BookEntity book) async {
    return await repository.createBook(book);
  }
}
