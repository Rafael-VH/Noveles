import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
