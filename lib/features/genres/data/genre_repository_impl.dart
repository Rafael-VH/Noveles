import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/genres/data/genre_model.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GenreRepositoryImpl implements GenreRepository {
  final SupabaseClientProvider _supabase;

  GenreRepositoryImpl(this._supabase);

  @override
  Future<Result<List<GenreEntity>>> getGenres() async {
    try {
      final response =
          await _supabase.client.from('genres').select('*').order('id').limit(100);
      final genres = response.map((json) => GenreModel.fromJson(json)).toList();
      return Ok(genres);
    } catch (e) {
      return Err(GenreFailure('Error al obtener géneros', cause: e));
    }
  }

  @override
  Future<Result<GenreEntity?>> getGenreById(int id) async {
    try {
      final response =
          await _supabase.client.from('genres').select('*').eq('id', id).maybeSingle();
      if (response == null) return const Ok(null);
      return Ok(GenreModel.fromJson(response));
    } catch (e) {
      return Err(GenreFailure('Error al obtener género', cause: e));
    }
  }

  @override
  Future<Result<void>> createGenre(GenreEntity genre) async {
    try {
      await _supabase.client.from('genres').insert({
        'created_at': genre.createdAt.toIso8601String(),
        'name': genre.name,
        'description': genre.description,
      });
      return const Ok(null);
    } catch (e) {
      return Err(GenreFailure('Error al crear género', cause: e));
    }
  }

  @override
  Future<Result<void>> updateGenre(GenreEntity genre) async {
    try {
      await _supabase.client.from('genres').update({
        'name': genre.name,
        'description': genre.description,
      }).eq('id', genre.id);
      return const Ok(null);
    } catch (e) {
      return Err(GenreFailure('Error al actualizar género', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteGenre(int id) async {
    try {
      await _supabase.client.from('genres').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(GenreFailure('Error al eliminar género', cause: e));
    }
  }
}
