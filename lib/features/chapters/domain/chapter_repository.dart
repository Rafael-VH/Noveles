import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

abstract class ChapterRepository {
  Future<Result<List<ChapterEntity>>> getChapters();
  Future<Result<ChapterEntity?>> getChapterById(int id);
  Future<Result<void>> createChapter(ChapterEntity chapter);
  Future<Result<void>> updateChapter(ChapterEntity chapter);
  Future<Result<void>> deleteChapter(int id);
  /// Downloads content from a storage path, or returns inline content as-is.
  /// The implementation determines if [path] is a storage reference or inline text.
  Future<Result<String>> downloadContent(String path);
}
