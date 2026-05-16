import 'package:noveles/features/domain/repositories/repositories.dart';

class UploadAvatar {
  final ProfilesRepository repository;

  UploadAvatar(this.repository);

  Future<String> call(String filePath) async {
    return await repository.uploadAvatar(filePath);
  }
}
