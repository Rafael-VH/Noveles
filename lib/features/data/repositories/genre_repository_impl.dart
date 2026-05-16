import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GenreRepositoryImpl implements GenreRepository {
  @override
  Future<List<GenreEntity>> getGenres() async {
    try {
      final response = await supabase.from('genres').select('*').order('id').limit(100);
      return response.map((json) => _mapToGenreEntity(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener géneros: $e');
    }
  }

  @override
  Future<GenreEntity?> getGenreById(int id) async {
    try {
      final response =
          await supabase.from('genres').select('*').eq('id', id).maybeSingle();
      if (response == null) return null;
      return _mapToGenreEntity(response);
    } catch (e) {
      throw Exception('Error al obtener género: $e');
    }
  }

  GenreEntity _mapToGenreEntity(Map<String, dynamic> json) {
    return GenreEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  Future<void> createGenre(GenreEntity genre) async {
    try {
      await supabase.from('genres').insert({
        'id': genre.id,
        'created_at': genre.createdAt.toIso8601String(),
        'name': genre.name,
        'description': genre.description,
      });
    } catch (e) {
      throw Exception('Error al crear género: $e');
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
      throw Exception('Error al actualizar género: $e');
    }
  }

  @override
  Future<void> deleteGenre(int id) async {
    try {
      await supabase.from('genres').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar género: $e');
    }
  }
}
