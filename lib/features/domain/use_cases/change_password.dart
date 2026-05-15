import 'package:noveles/features/domain/repositories/repositories.dart';

class ChangePassword {
  final ProfilesRepository repository;

  ChangePassword(this.repository);

  Future<void> call(String newPassword) async {
    return await repository.changePassword(newPassword);
  }
}
