import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class MarkChapterAsRead {
  final ChapterRepository repository;
  MarkChapterAsRead(this.repository);
  Future<Result<void>> call(int chapterId, String userId) =>
      repository.markChapterAsRead(chapterId, userId);
}
