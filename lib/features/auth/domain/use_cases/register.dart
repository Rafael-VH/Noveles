import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Result<UserEntity>> call(String email, String password) async {
    return await repository.register(email, password);
  }
}
