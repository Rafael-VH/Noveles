import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

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
        displayName: profile['display_name'] as String?,
        bio: profile['bio'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
      );
    } catch (e) {
      throw RepositoryException(
        message: 'Error al iniciar sesión',
        originalException: e,
        repositoryName: 'AuthRepository',
      );
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
      if (user == null) throw const RepositoryException(message: 'Error al registrarse');

      final profile = await _getProfile(user.id);
      return UserEntity(
        id: user.id,
        email: user.email ?? '',
        role: profile['role'] ?? 'user',
        displayName: profile['display_name'] as String?,
        bio: profile['bio'] as String?,
        avatarUrl: profile['avatar_url'] as String?,
      );
    } catch (e) {
      throw RepositoryException(
        message: 'Error al registrarse',
        originalException: e,
        repositoryName: 'AuthRepository',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al cerrar sesión',
        originalException: e,
        repositoryName: 'AuthRepository',
      );
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
          displayName: profile['display_name'] as String?,
          bio: profile['bio'] as String?,
          avatarUrl: profile['avatar_url'] as String?,
        );
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener usuario actual',
        originalException: e,
        repositoryName: 'AuthRepository',
      );
    }
  }

  @override
  Stream<AuthChangeEvent> onAuthStateChange() =>
      supabase.auth.onAuthStateChange.map((data) => data.event);

  Future<Map<String, dynamic>> _getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('*')
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
      throw RepositoryException(
        message: 'Error al obtener perfil',
        originalException: e,
        repositoryName: 'AuthRepository',
      );
    }
  }
}
