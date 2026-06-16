import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Result<UserEntity>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
