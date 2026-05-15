import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
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
  }

  @override
  Future<UserEntity> register(String email, String password) async {
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
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
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
  }

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      // Si no existe perfil (e.g. admin creado antes del trigger), crear uno
      await supabase.from('profiles').insert({
        'id': userId,
        'role': 'user',
      });
      return {'role': 'user'};
    }

    return Map<String, dynamic>.from(response);
  }
}
