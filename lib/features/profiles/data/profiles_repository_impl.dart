import 'dart:io';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/core/constants/storage_constants.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/data/profiles.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final DataGateway _data;
  final StorageGateway _storage;
  final AuthGateway _auth;

  ProfilesRepositoryImpl(this._data, this._storage, this._auth);

  static const int _maxAvatarSize = 5 * 1024 * 1024; // 5MB
  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final userId = _data.identity?.id;
      if (userId == null) return Err(ProfileFailure('No hay sesión activa'));
      final response =
          await _data.from('profiles').select('*').eq('id', userId).maybeRow();
      if (response == null) return Err(ProfileFailure('No se encontró el perfil'));
      return Ok(UserModel.fromJson(response));
    } catch (e) {
      return Err(ProfileFailure('Error al obtener perfil', cause: e));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile(
      {String? displayName, String? bio, String? avatarUrl}) async {
    try {
      final userId = _data.identity?.id;
      if (userId == null) return Err(ProfileFailure('No hay sesión activa'));
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      final response = await _data
          .from('profiles')
          .eq('id', userId)
          .updateReturning(data);
      if (response == null) return Err(ProfileFailure('No se encontró el perfil'));
      return Ok(UserModel.fromJson(response));
    } catch (e) {
      return Err(ProfileFailure('Error al actualizar perfil', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String filePath) async {
    try {
      final userId = _data.identity?.id;
      if (userId == null) return Err(ProfileFailure('No hay sesión activa'));

      // Validar extensión
      final ext = filePath.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        return Err(ProfileFailure('Formato no permitido. Usa: JPG, PNG, o WebP'));
      }

      // Validar tamaño
      final file = File(filePath);
      final fileSize = await file.length();
      if (fileSize > _maxAvatarSize) {
        return Err(ProfileFailure('El archivo es demasiado grande. Máximo: 5MB'));
      }

      final path = '$userId/avatar.$ext';
      await _storage.upload(
        StorageConstants.avatarsBucket,
        path,
        file,
        upsert: true,
      );
      final url = _storage.publicUrl(StorageConstants.avatarsBucket, path);
      return Ok('$url?v=${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      return Err(ProfileFailure('Error al subir avatar', cause: e));
    }
  }

  @override
  Future<Result<List<UserEntity>>> getAllProfiles({
    int limit = 50,
  }) async {
    try {
      final response = await _data
          .from('profiles')
          .select('*')
          .order('created_at', ascending: true)
          .limit(limit + 1)
          .rows();
      // ignore: unused_local_variable
      final hasMore = response.length > limit;
      final profiles = response
          .take(limit)
          .map((json) => UserModel.fromJson(json))
          .toList();
      return Ok(profiles);
    } catch (e) {
      return Err(ProfileFailure('Error al obtener perfiles', cause: e));
    }
  }

  @override
  Future<Result<UserEntity>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      // Route role changes through the admin RPCs so suspending also revokes
      // the user's active sessions server-side (see migration
      // enforce_suspended_all_tables). Direct UPDATE of profiles.role is
      // blocked by RLS column-level REVOKE anyway.
      final Map<String, dynamic> response;
      if (role == UserRole.suspended.name) {
        await _data.rpc('admin_suspend_user', params: {
          'target_uid': userId,
        });
      } else {
        await _data.rpc('admin_reactivate_user', params: {
          'target_uid': userId,
          'new_role': role,
        });
      }

      final profile =
          await _data.from('profiles').select('*').eq('id', userId).oneRow();
      response = Map<String, dynamic>.from(profile);
      return Ok(UserModel.fromJson(response));
    } catch (e) {
      return Err(ProfileFailure('Error al cambiar rol', cause: e));
    }
  }

  @override
  Future<Result<void>> changePassword(String newPassword) async {
    try {
      await _auth.updatePassword(newPassword);
      return const Ok(null);
    } catch (e) {
      return Err(ProfileFailure('Error al cambiar contraseña', cause: e));
    }
  }
}
