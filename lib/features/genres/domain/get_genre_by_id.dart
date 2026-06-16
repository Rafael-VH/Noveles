import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GetGenreById {
  final GenreRepository repository;

  GetGenreById(this.repository);

  Future<GenreEntity?> call(int id) async {
    return await repository.getGenreById(id);
  }
}
