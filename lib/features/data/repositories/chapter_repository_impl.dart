import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  @override
  Future<List<ChapterEntity>> getChapters() async {
    final response = await supabase.from('chapters').select('*').order('id');
    return response.map((json) => ChapterEntity.fromMap(Map<String, dynamic>.from(json))).toList();
  }

  @override
  Future<ChapterEntity> getChapterById(int id) async {
    final response = await supabase.from('chapters').select('*').eq('id', id).single();
    return ChapterEntity.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> createChapter(ChapterEntity chapter) async {
    await supabase.from('chapters').insert(chapter.toMap());
  }

  @override
  Future<void> updateChapter(ChapterEntity chapter) async {
    await supabase.from('chapters').update(chapter.toMap()).eq('id', chapter.id);
  }

  @override
  Future<void> deleteChapter(int id) async {
    await supabase.from('chapters').delete().eq('id', id);
  }
}
