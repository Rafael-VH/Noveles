import 'dart:io';
import 'package:noveles/features/domain/repositories/repositories.dart';

class UploadAvatar {
  final ProfilesRepository repository;

  UploadAvatar(this.repository);

  Future<String> call(File file) async {
    return await repository.uploadAvatar(file);
  }
}
