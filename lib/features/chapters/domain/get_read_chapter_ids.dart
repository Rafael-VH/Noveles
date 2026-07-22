import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetReadChapterIds {
  final ChapterRepository repository;
  GetReadChapterIds(this.repository);
  Future<Result<Set<int>>> call(int tookId, String userId) =>
      repository.getReadChapterIds(tookId, userId);
}
