import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class ChangePassword {
  final ProfilesRepository repository;

  ChangePassword(this.repository);

  Future<Result<void>> call(String newPassword) async {
    return repository.changePassword(newPassword);
  }
}
