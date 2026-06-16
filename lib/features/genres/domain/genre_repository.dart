import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

abstract class GenreRepository {
  Future<Result<List<GenreEntity>>> getGenres();
  Future<Result<GenreEntity?>> getGenreById(int id);
  Future<Result<void>> createGenre(GenreEntity genre);
  Future<Result<void>> updateGenre(GenreEntity genre);
  Future<Result<void>> deleteGenre(int id);
}
