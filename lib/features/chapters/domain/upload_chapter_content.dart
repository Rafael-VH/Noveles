import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class UploadChapterContent {
  final ChapterRepository repository;

  UploadChapterContent(this.repository);

  Future<Result<String>> call(String filePath) async {
    return repository.uploadContent(filePath);
  }
}
