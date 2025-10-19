import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<BookEntity?> call(int id) async {
    return await repository.getBookById(id);
  }
}
