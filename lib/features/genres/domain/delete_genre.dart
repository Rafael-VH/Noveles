import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class DeleteGenre {
  final GenreRepository repository;

  DeleteGenre(this.repository);

  Future<Result<void>> call(int id) async {
    return repository.deleteGenre(id);
  }
}
