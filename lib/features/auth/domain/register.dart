import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.register(email, password);
  }
}
