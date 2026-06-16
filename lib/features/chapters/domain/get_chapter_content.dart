import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class GetChapterContent {
  final ChapterRepository repository;

  GetChapterContent(this.repository);

  bool _isStoragePath(String s) =>
      s.contains('/') || s.endsWith('.txt') || s.endsWith('.json');

  Future<String> call(String rawContent) async {
    if (!_isStoragePath(rawContent)) return rawContent;
    return await repository.downloadContent(rawContent);
  }
}
