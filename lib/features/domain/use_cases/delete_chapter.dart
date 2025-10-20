import 'package:noveles/features/domain/repositories/repositories.dart';

class DeleteChapter {
  final ChapterRepository repository;

  DeleteChapter(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteChapter(id);
  }
}
