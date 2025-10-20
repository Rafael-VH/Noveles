import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetChapterById {
  final ChapterRepository repository;

  GetChapterById(this.repository);

  Future<ChapterEntity?> call(int id) async {
    return await repository.getChapterById(id);
  }
}
