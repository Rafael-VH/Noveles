import 'package:noveles/features/domain/repositories/repositories.dart';

class UploadCover {
  final BookRepository repository;

  UploadCover(this.repository);

  Future<String> call(String filePath) async {
    return await repository.uploadCover(filePath);
  }
}
