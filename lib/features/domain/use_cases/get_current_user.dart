import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
