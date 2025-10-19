import 'package:noveles/features/main/domain/repositories/repositories.dart';

class DeleteBook {
  final BookRepository repository;

  DeleteBook(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteBook(id);
  }
}