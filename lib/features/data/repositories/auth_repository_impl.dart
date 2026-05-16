import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Error al iniciar sesión');

      final profile = await _getProfile(user.id);
      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        role: profile['role'] ?? 'user',
      );
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Error al registrarse');

      final profile = await _getProfile(user.id);
      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        role: profile['role'] ?? 'user',
      );
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;
      if (session == null || user == null) return null;

      try {
        final profile = await _getProfile(user.id);
        return UserEntity(
          id: user.id,
          email: user.email ?? '',
          role: profile['role'] ?? 'user',
        );
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        await supabase.from('profiles').insert({
          'id': userId,
          'role': 'user',
        });
        return {'role': 'user'};
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }
}
