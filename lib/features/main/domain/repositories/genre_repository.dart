import 'package:noveles/features/main/domain/entities/entities.dart';

abstract class GenreRepository {
  Future<List<GenreEntity>> getGenres();
  Future<GenreEntity?> getGenreById(int id);
  Future<void> createGenre(GenreEntity genre);
  Future<void> updateGenre(GenreEntity genre);
  Future<void> deleteGenre(int id);
}
