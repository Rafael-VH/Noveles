import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/genres/data/genre_model.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GenreRepositoryImpl implements GenreRepository {
  @override
  Future<List<GenreEntity>> getGenres() async {
    try {
      final response =
          await supabase.from('genres').select('*').order('id').limit(100);
      return response.map((json) => GenreModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener géneros',
        originalException: e,
        repositoryName: 'GenreRepository',
      );
    }
  }

  @override
  Future<GenreEntity?> getGenreById(int id) async {
    try {
      final response =
          await supabase.from('genres').select('*').eq('id', id).maybeSingle();
      if (response == null) return null;
      return GenreModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener género',
        originalException: e,
        repositoryName: 'GenreRepository',
      );
    }
  }

  @override
  Future<void> createGenre(GenreEntity genre) async {
    try {
      await supabase.from('genres').insert({
        'created_at': genre.createdAt.toIso8601String(),
        'name': genre.name,
        'description': genre.description,
      });
    } catch (e) {
      throw RepositoryException(
        message: 'Error al crear género',
        originalException: e,
        repositoryName: 'GenreRepository',
      );
    }
  }

  @override
  Future<void> updateGenre(GenreEntity genre) async {
    try {
      await supabase.from('genres').update({
        'name': genre.name,
        'description': genre.description,
      }).eq('id', genre.id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al actualizar género',
        originalException: e,
        repositoryName: 'GenreRepository',
      );
    }
  }

  @override
  Future<void> deleteGenre(int id) async {
    try {
      await supabase.from('genres').delete().eq('id', id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al eliminar género',
        originalException: e,
        repositoryName: 'GenreRepository',
      );
    }
  }
}
