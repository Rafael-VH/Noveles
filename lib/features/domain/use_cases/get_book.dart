import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<List<BookEntity>> call({bool onlyVisible = false}) async {
    return await repository.getBooks(onlyVisible: onlyVisible);
  }
}
