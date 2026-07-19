import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Result<void>> call() async {
    return await repository.logout();
  }
}
