import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapterContent {
  final ChapterRepository repository;

  GetChapterContent(this.repository);

  Future<Result<String>> call(String contentOrPath) async {
    return repository.downloadContent(contentOrPath);
  }
}
