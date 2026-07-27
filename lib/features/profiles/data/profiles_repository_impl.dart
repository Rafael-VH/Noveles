import 'dart:io';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/profiles/data/profiles.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  final SupabaseClientProvider _supabase;

  ProfilesRepositoryImpl(this._supabase);

  static const int _maxAvatarSize = 5 * 1024 * 1024; // 5MB
  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return Err(ProfileFailure('No hay sesión activa'));
      final response = await _supabase.client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();
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
      final user = _supabase.client.auth.currentUser;
      if (user == null) return Err(ProfileFailure('No hay sesión activa'));
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      final response = await _supabase.client
          .from('profiles')
          .update(data)
          .eq('id', user.id)
          .select()
          .maybeSingle();
      if (response == null) return Err(ProfileFailure('No se encontró el perfil'));
      return Ok(UserModel.fromJson(response));
    } catch (e) {
      return Err(ProfileFailure('Error al actualizar perfil', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String filePath) async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return Err(ProfileFailure('No hay sesión activa'));

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

      final path = '${user.id}/avatar.$ext';
      await _supabase.client.storage
          .from('avatars')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      final url = _supabase.client.storage.from('avatars').getPublicUrl(path);
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
      final response = await _supabase.client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: true)
          .limit(limit + 1);
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
      final response = await _supabase.client
          .from('profiles')
          .update({'role': role})
          .eq('id', userId)
          .select()
          .single();
      return Ok(UserModel.fromJson(response));
    } catch (e) {
      return Err(ProfileFailure('Error al cambiar rol', cause: e));
    }
  }

  @override
  Future<Result<void>> changePassword(String newPassword) async {
    try {
      await _supabase.client.auth.updateUser(UserAttributes(password: newPassword));
      return const Ok(null);
    } catch (e) {
      return Err(ProfileFailure('Error al cambiar contraseña', cause: e));
    }
  }
}
