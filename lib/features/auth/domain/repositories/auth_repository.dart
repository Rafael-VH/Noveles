import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> login(String email, String password);
  Future<Result<UserEntity>> register(String email, String password);
  Future<Result<void>> logout();
  Future<Result<UserEntity?>> getCurrentUser();
  Stream<AuthEvent> onAuthStateChange();
}
