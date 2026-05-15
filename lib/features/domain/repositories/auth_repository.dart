import 'package:noveles/features/domain/entities/entities.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
