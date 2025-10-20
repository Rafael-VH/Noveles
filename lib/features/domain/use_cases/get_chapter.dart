import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetChapter {
  final ChapterRepository repository;

  GetChapter(this.repository);

  Future<List<ChapterEntity>> call() async {
    return await repository.getChapters();
  }
}
