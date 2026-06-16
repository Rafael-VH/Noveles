import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapter {
  final ChapterRepository repository;

  GetChapter(this.repository);

  Future<List<ChapterEntity>> call() async {
    return await repository.getChapters();
  }
}
