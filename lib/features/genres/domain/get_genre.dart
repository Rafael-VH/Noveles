import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GetGenre {
  final GenreRepository repository;

  GetGenre(this.repository);

  Future<Result<List<GenreEntity>>> call() async {
    return repository.getGenres();
  }
}
