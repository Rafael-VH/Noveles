import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GenreRepositoryImpl implements GenreRepository {
  @override
  Future<List<GenreEntity>> getGenres() async {
    final response = await supabase.from('genres').select('*').order('id');
    return response.map((json) => _mapToGenreEntity(json)).toList();
  }

  @override
  Future<GenreEntity?> getGenreById(int id) async {
    final response =
        await supabase.from('genres').select('*').eq('id', id).maybeSingle();
    if (response == null) return null;
    return _mapToGenreEntity(response);
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
    await supabase.from('genres').insert({
      'id': genre.id,
      'created_at': genre.createdAt.toIso8601String(),
      'name': genre.name,
      'description': genre.description,
    });
  }

  @override
  Future<void> updateGenre(GenreEntity genre) async {
    await supabase.from('genres').update({
      'name': genre.name,
      'description': genre.description,
    }).eq('id', genre.id);
  }

  @override
  Future<void> deleteGenre(int id) async {
    await supabase.from('genres').delete().eq('id', id);
  }
}
