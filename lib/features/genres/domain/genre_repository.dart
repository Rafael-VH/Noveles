import 'package:noveles/features/genres/domain/genre_entity.dart';

abstract class GenreRepository {
  Future<List<GenreEntity>> getGenres();
  Future<GenreEntity?> getGenreById(int id);
  Future<void> createGenre(GenreEntity genre);
  Future<void> updateGenre(GenreEntity genre);
  Future<void> deleteGenre(int id);
}
