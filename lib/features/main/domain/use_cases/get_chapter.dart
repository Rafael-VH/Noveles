import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetChapter {
  final ChapterRepository repository;

  GetChapter(this.repository);

  Future<List<ChapterEntity>> call() async {
    return await repository.getChapters();
  }
}