import 'package:noveles/features/main/domain/entities/entities.dart';
import 'package:noveles/features/main/domain/repositories/repositories.dart';

class GetChapterById {
  final ChapterRepository repository;

  GetChapterById(this.repository);

  Future<ChapterEntity?> call(int id) async {
    return await repository.getChapterById(id);
  }
}
