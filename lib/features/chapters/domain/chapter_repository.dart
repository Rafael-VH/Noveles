import 'package:noveles/features/chapters/domain/chapter_entity.dart';

abstract class ChapterRepository {
  Future<List<ChapterEntity>> getChapters();
  Future<ChapterEntity?> getChapterById(int id);
  Future<void> createChapter(ChapterEntity chapter);
  Future<void> updateChapter(ChapterEntity chapter);
  Future<void> deleteChapter(int id);
  Future<String> downloadContent(String path);
}
