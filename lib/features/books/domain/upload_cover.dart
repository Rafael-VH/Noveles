import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class UploadCover {
  final BookRepository repository;

  UploadCover(this.repository);

  Future<Result<String>> call(String filePath) async {
    return repository.uploadCover(filePath);
  }
}
