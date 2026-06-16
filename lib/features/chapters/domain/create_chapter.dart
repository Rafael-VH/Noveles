import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class CreateChapter {
  final ChapterRepository repository;

  CreateChapter(this.repository);

  Future<void> call(ChapterEntity chapter) async {
    return await repository.createChapter(chapter);
  }
}
