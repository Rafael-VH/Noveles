import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class CreateChapter {
  final ChapterRepository repository;

  CreateChapter(this.repository);

  Future<Result<int>> call(ChapterEntity chapter) async {
    return repository.createChapter(chapter);
  }
}
