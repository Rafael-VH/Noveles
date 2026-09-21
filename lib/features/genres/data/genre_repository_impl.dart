import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/data/genre_model.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';

class GenreRepositoryImpl implements GenreRepository {
  final DataGateway _data;

  GenreRepositoryImpl(this._data);

  @override
  Future<Result<List<GenreEntity>>> getGenres() async {
    try {
      final rows =
          await _data.from('genres').order('id').limit(100).rows();
      final genres = rows.map((json) => GenreModel.fromJson(json)).toList();
      return Ok(genres);
    } catch (e) {
      return Err(GenreFailure('Error al obtener géneros', cause: e));
    }
  }

  @override
  Future<Result<GenreEntity?>> getGenreById(int id) async {
    try {
      final row = await _data.from('genres').eq('id', id).maybeRow();
      if (row == null) return const Ok(null);
      return Ok(GenreModel.fromJson(row));
    } catch (e) {
      return Err(GenreFailure('Error al obtener género', cause: e));
    }
  }

  @override
  Future<Result<void>> createGenre(GenreEntity genre) async {
    try {
      await _data.insert('genres', {
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
      await _data.from('genres').eq('id', genre.id).update({
        'name': genre.name,
        'description': genre.description,
      });
      return const Ok(null);
    } catch (e) {
      return Err(GenreFailure('Error al actualizar género', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteGenre(int id) async {
    try {
      await _data.from('genres').eq('id', id).delete();
      return const Ok(null);
    } catch (e) {
      return Err(GenreFailure('Error al eliminar género', cause: e));
    }
  }
}
