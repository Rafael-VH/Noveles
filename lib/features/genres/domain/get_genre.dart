import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GetGenre {
  final GenreRepository repository;

  GetGenre(this.repository);

  Future<List<GenreEntity>> call() async {
    return await repository.getGenres();
  }
}
