import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapterContent {
  final ChapterRepository repository;

  GetChapterContent(this.repository);

  Future<Result<String>> call(String contentOrPath, {ChapterContentType contentType = ChapterContentType.storagePath}) async {
    return repository.downloadContent(contentOrPath, contentType: contentType);
  }
}
