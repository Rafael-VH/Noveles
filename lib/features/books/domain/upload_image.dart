import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class UploadImage {
  final BookRepository repository;

  UploadImage(this.repository);

  Future<Result<String>> call(String filePath) async {
    return repository.uploadImage(filePath);
  }
}
