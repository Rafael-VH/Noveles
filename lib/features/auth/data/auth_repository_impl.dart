import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/profiles/data/user_model.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClientProvider _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Err(AuthFailure('Error al iniciar sesión'));
      }

      final profileResult = await _getProfile(user.id);
      if (profileResult is Err<Map<String, dynamic>>) {
        return Err(profileResult.error);
      }
      final profile = (profileResult as Ok<Map<String, dynamic>>).value;
      return Ok(UserModel.fromJson({
        'id': user.id,
        'email': user.email ?? '',
        ...profile,
      }));
    } catch (e) {
      return Err(AuthFailure('Error al iniciar sesión', cause: e));
    }
  }

  @override
  Future<Result<UserEntity>> register(String email, String password) async {
    try {
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Err(AuthFailure('Error al registrarse'));
      }

      final profileResult = await _getProfile(user.id);
      if (profileResult is Err<Map<String, dynamic>>) {
        return Err(profileResult.error);
      }
      final profile = (profileResult as Ok<Map<String, dynamic>>).value;
      return Ok(UserModel.fromJson({
        'id': user.id,
        'email': user.email ?? '',
        ...profile,
      }));
    } catch (e) {
      return Err(AuthFailure('Error al registrarse', cause: e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _supabase.client.auth.signOut();
      return const Ok(null);
    } catch (e) {
      return Err(AuthFailure('Error al cerrar sesión', cause: e));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final session = _supabase.client.auth.currentSession;
      final user = _supabase.client.auth.currentUser;
      if (session == null || user == null) return const Ok(null);

      final profileResult = await _getProfile(user.id);
      if (profileResult is Err<Map<String, dynamic>>) {
        return Err(profileResult.error);
      }
      final profile = (profileResult as Ok<Map<String, dynamic>>).value;
      return Ok(UserModel.fromJson({
        'id': user.id,
        'email': user.email ?? '',
        ...profile,
      }));
    } catch (e) {
      return Err(AuthFailure('Error al obtener usuario actual', cause: e));
    }
  }

  @override
  Stream<AuthEvent> onAuthStateChange() {
    return _supabase.client.auth.onAuthStateChange
        .map((data) => switch (data.event) {
              AuthChangeEvent.signedIn => AuthEvent.signedIn,
              AuthChangeEvent.signedOut => AuthEvent.signedOut,
              AuthChangeEvent.tokenRefreshed => AuthEvent.tokenRefreshed,
              AuthChangeEvent.userUpdated => AuthEvent.userChanged,
              _ => AuthEvent.userChanged,
            })
        .transform(StreamTransformer.fromHandlers(
          handleError: (_, __, sink) => sink.add(AuthEvent.authError),
        ));
  }

  Future<Result<Map<String, dynamic>>> _getProfile(String userId) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        try {
          await _supabase.client.from('profiles').insert({
            'id': userId,
            'role': UserRole.user.name,
          });

          // Verificar que se creó correctamente
          final verify = await _supabase.client
              .from('profiles')
              .select('role')
              .eq('id', userId)
              .maybeSingle();

          if (verify == null) {
            return Err(ProfileFailure('Perfil no encontrado después de crear'));
          }

          return Ok(Map<String, dynamic>.from(verify));
        } catch (e) {
          return Err(ProfileFailure(
            'No se pudo crear el perfil automáticamente',
            cause: e,
          ));
        }
      }

      return Ok(Map<String, dynamic>.from(response));
    } catch (e) {
      return Err(ProfileFailure('Error al obtener perfil', cause: e));
    }
  }
}
