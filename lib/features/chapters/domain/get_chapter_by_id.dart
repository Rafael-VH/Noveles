import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapterById {
  final ChapterRepository repository;

  GetChapterById(this.repository);

  Future<ChapterEntity?> call(int id) async {
    return await repository.getChapterById(id);
  }
}
