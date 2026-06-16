import 'package:noveles/features/books/domain/book_repository.dart';

class DeleteBook {
  final BookRepository repository;

  DeleteBook(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteBook(id);
  }
}
