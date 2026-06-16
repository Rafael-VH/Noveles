import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Result<UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}
