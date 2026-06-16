import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapterById {
  final ChapterRepository repository;

  GetChapterById(this.repository);

  Future<Result<ChapterEntity?>> call(int id) async {
    return repository.getChapterById(id);
  }
}
