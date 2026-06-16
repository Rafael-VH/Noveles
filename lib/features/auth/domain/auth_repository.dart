import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Stream<AuthChangeEvent> onAuthStateChange();
}
