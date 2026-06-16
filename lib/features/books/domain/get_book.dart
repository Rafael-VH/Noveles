import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<List<BookEntity>> call({bool onlyVisible = false}) async {
    return await repository.getBooks(onlyVisible: onlyVisible);
  }
}
