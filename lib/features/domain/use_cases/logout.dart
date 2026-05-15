import 'package:noveles/features/domain/repositories/repositories.dart';

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
