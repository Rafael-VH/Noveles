import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class ChangePassword {
  final ProfilesRepository repository;

  ChangePassword(this.repository);

  Future<void> call(String newPassword) async {
    return await repository.changePassword(newPassword);
  }
}
