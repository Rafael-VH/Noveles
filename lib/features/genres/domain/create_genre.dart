import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class CreateGenre {
  final GenreRepository repository;

  CreateGenre(this.repository);

  Future<void> call(GenreEntity genre) async {
    return await repository.createGenre(genre);
  }
}
