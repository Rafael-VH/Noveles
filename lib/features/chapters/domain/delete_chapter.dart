import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class DeleteChapter {
  final ChapterRepository repository;

  DeleteChapter(this.repository);

  Future<Result<void>> call(int id) async {
    return repository.deleteChapter(id);
  }
}
