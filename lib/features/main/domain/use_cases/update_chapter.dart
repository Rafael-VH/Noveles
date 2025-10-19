import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class UpdateChapter {
  final ChapterRepository repository;

  UpdateChapter(this.repository);

  Future<void> call(ChapterEntity chapter) async {
    return await repository.updateChapter(chapter);
  }
}
