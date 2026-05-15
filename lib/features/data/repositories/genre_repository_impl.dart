import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GenreRepositoryImpl implements GenreRepository {
  @override
  Future<List<GenreEntity>> getGenres() async {
    final response = await supabase.from('genres').select('*').order('id');
    return response.map((json) => GenreEntity.fromMap(Map<String, dynamic>.from(json))).toList();
  }

  @override
  Future<GenreEntity?> getGenreById(int id) async {
    final response = await supabase.from('genres').select('*').eq('id', id).maybeSingle();
    if (response == null) return null;
    return GenreEntity.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> createGenre(GenreEntity genre) async {
    await supabase.from('genres').insert(genre.toMap());
  }

  @override
  Future<void> updateGenre(GenreEntity genre) async {
    await supabase.from('genres').update(genre.toMap()).eq('id', genre.id);
  }

  @override
  Future<void> deleteGenre(int id) async {
    await supabase.from('genres').delete().eq('id', id);
  }
}
