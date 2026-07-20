import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

class UpdateUserRole {
  final ProfilesRepository repository;

  UpdateUserRole(this.repository);

  Future<Result<UserEntity>> call(String userId, String role) async {
    return repository.updateUserRole(userId: userId, role: role);
  }
}
