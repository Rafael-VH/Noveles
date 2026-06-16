import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class UploadAvatar {
  final ProfilesRepository repository;

  UploadAvatar(this.repository);

  Future<String> call(String filePath) async {
    return await repository.uploadAvatar(filePath);
  }
}
