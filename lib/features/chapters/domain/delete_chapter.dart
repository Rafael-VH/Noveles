import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class DeleteChapter {
  final ChapterRepository repository;

  DeleteChapter(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteChapter(id);
  }
}
