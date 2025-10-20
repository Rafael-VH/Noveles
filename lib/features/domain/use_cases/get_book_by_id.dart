import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<BookEntity?> call(int id) async {
    return await repository.getBookById(id);
  }
}
