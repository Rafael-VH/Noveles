import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class CreateChapter {
  final ChapterRepository repository;

  CreateChapter(this.repository);

  Future<void> call(ChapterEntity chapter) async {
    return await repository.createChapter(chapter);
  }
}
