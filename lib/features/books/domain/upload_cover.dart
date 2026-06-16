import 'package:noveles/features/books/domain/book_repository.dart';

class UploadCover {
  final BookRepository repository;

  UploadCover(this.repository);

  Future<String> call(String filePath) async {
    return await repository.uploadCover(filePath);
  }
}
