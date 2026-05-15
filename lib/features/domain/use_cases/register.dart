import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.register(email, password);
  }
}
