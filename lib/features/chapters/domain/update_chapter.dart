import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class UpdateChapter {
  final ChapterRepository repository;

  UpdateChapter(this.repository);

  Future<void> call(ChapterEntity chapter) async {
    return await repository.updateChapter(chapter);
  }
}
