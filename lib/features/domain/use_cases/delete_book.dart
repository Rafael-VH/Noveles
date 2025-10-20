import 'package:noveles/features/domain/repositories/repositories.dart';

class DeleteBook {
  final BookRepository repository;

  DeleteBook(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteBook(id);
  }
}
