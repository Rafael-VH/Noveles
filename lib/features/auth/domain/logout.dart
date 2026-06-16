import 'package:noveles/features/auth/domain/auth_repository.dart';

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
