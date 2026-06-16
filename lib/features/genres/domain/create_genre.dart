import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class CreateGenre {
  final GenreRepository repository;

  CreateGenre(this.repository);

  Future<Result<void>> call(GenreEntity genre) async {
    return repository.createGenre(genre);
  }
}
