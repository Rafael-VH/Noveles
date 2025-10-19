import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<List<BookEntity>> call() async {
    return await repository.getBooks();
  }
}