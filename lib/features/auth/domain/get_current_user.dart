import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
