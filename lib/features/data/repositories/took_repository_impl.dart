import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class TookRepositoryImpl implements TookRepository {
  @override
  Future<List<TookEntity>> getTooks() async {
    try {
      final response = await supabase
          .from('tooks')
          .select('*, chapters(*)')
          .order('id')
          .limit(100);

      return response
          .map((json) => _mapToTookEntity(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tomos: $e');
    }
  }

  @override
  Future<TookEntity?> getTookById(int id) async {
    try {
      final response = await supabase
          .from('tooks')
          .select('*, chapters(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapToTookEntity(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Error al obtener tomo: $e');
    }
  }

  TookEntity _mapToTookEntity(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? []).map((ch) {
      return ChapterEntity(
        id: ch['id'],
        createdAt: DateTime.parse(ch['created_at']),
        number: ch['number'] ?? '',
        title: ch['title'] ?? '',
        content: ch['content'] ?? '',
        tookId: ch['took_id'] ?? 0,
      );
    }).toList();

    return TookEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      cover: json['cover'] ?? '',
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      chapterCount: json['content'] ?? '',
      bookId: json['book_id'] ?? 0,
      listChapter: chapters,
    );
  }

  @override
  Future<void> createTook(TookEntity took) async {
    try {
      await supabase.from('tooks').insert({
        'id': took.id,
        'created_at': took.createdAt.toIso8601String(),
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'content': took.chapterCount,
        'book_id': took.bookId,
      });
    } catch (e) {
      throw Exception('Error al crear tomo: $e');
    }
  }

  @override
  Future<void> updateTook(TookEntity took) async {
    try {
      await supabase.from('tooks').update({
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'content': took.chapterCount,
        'book_id': took.bookId,
      }).eq('id', took.id);
    } catch (e) {
      throw Exception('Error al actualizar tomo: $e');
    }
  }

  @override
  Future<void> deleteTook(int id) async {
    try {
      await supabase.from('chapters').delete().eq('took_id', id);
      await supabase.from('tooks').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar tomo: $e');
    }
  }
}
