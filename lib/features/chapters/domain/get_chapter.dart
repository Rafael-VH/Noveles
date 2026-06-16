import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapter {
  final ChapterRepository repository;

  GetChapter(this.repository);

  Future<Result<List<ChapterEntity>>> call() async {
    return repository.getChapters();
  }
}
