import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  @override
  Future<List<ChapterEntity>> getChapters() async {
    final response = await supabase.from('chapters').select('*').order('id');
    return response.map((json) => _mapToChapterEntity(json)).toList();
  }

  @override
  Future<ChapterEntity?> getChapterById(int id) async {
    final response =
        await supabase.from('chapters').select('*').eq('id', id).maybeSingle();
    if (response == null) return null;
    return _mapToChapterEntity(response);
  }

  ChapterEntity _mapToChapterEntity(Map<String, dynamic> json) {
    return ChapterEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tookId: json['took_id'] ?? 0,
    );
  }

  @override
  Future<void> createChapter(ChapterEntity chapter) async {
    await supabase.from('chapters').insert({
      'id': chapter.id,
      'created_at': chapter.createdAt.toIso8601String(),
      'number': chapter.number,
      'title': chapter.title,
      'content': chapter.content,
      'took_id': chapter.tookId,
    });
  }

  @override
  Future<void> updateChapter(ChapterEntity chapter) async {
    await supabase.from('chapters').update({
      'number': chapter.number,
      'title': chapter.title,
      'content': chapter.content,
      'took_id': chapter.tookId,
    }).eq('id', chapter.id);
  }

  @override
  Future<void> deleteChapter(int id) async {
    await supabase.from('chapters').delete().eq('id', id);
  }
}
