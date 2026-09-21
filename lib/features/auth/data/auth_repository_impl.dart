import 'dart:async';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/data/user_model.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthGateway _auth;
  final DataGateway _data;

  AuthRepositoryImpl(this._auth, this._data);

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final identity = await _auth.signIn(email, password);
      if (identity == null) {
        return const Err(AuthFailure('Error al iniciar sesión'));
      }
      return await _userFrom(identity.id, identity.email);
    } catch (e) {
      return Err(AuthFailure('Error al iniciar sesión', cause: e));
    }
  }

  @override
  Future<Result<UserEntity>> register(String email, String password) async {
    try {
      final identity = await _auth.signUp(email, password);
      if (identity == null) {
        return const Err(AuthFailure('Error al registrarse'));
      }
      return await _userFrom(identity.id, identity.email);
    } catch (e) {
      return Err(AuthFailure('Error al registrarse', cause: e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _auth.signOut();
      return const Ok(null);
    } catch (e) {
      return Err(AuthFailure('Error al cerrar sesión', cause: e));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final identity = _auth.currentIdentity;
      if (!_auth.hasSession || identity == null) return const Ok(null);
      return await _userFrom(identity.id, identity.email);
    } catch (e) {
      return Err(AuthFailure('Error al obtener usuario actual', cause: e));
    }
  }

  @override
  Stream<AuthEvent> onAuthStateChange() {
    return _auth
        .stateChanges()
        .map((event) => switch (event) {
              AuthIdentityEvent.signedIn => AuthEvent.signedIn,
              AuthIdentityEvent.signedOut => AuthEvent.signedOut,
              AuthIdentityEvent.tokenRefreshed => AuthEvent.tokenRefreshed,
              AuthIdentityEvent.userUpdated => AuthEvent.userChanged,
              AuthIdentityEvent.unknown => AuthEvent.userChanged,
            })
        .transform(StreamTransformer.fromHandlers(
          handleError: (_, __, sink) => sink.add(AuthEvent.authError),
        ));
  }

  /// Loads the profile for [userId] and merges it onto the auth identity.
  Future<Result<UserEntity>> _userFrom(String userId, String? email) async {
    final profileResult = await _getProfile(userId);
    if (profileResult is Err<Map<String, dynamic>>) {
      return Err(profileResult.error);
    }
    final profile = (profileResult as Ok<Map<String, dynamic>>).value;
    return Ok(UserModel.fromJson({
      'id': userId,
      'email': email ?? '',
      ...profile,
    }));
  }

  Future<Result<Map<String, dynamic>>> _getProfile(String userId) async {
    try {
      final response =
          await _data.from('profiles').select('*').eq('id', userId).maybeRow();

      if (response == null) {
        try {
          await _data.insert('profiles', {
            'id': userId,
            'role': UserRole.user.name,
          });

          // Verificar que se creó correctamente
          final verify = await _data
              .from('profiles')
              .select('role')
              .eq('id', userId)
              .maybeRow();

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
