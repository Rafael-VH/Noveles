import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class UpdateGenre {
  final GenreRepository repository;

  UpdateGenre(this.repository);

  Future<void> call(GenreEntity genre) async {
    return await repository.updateGenre(genre);
  }
}
