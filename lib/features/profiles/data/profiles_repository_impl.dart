import 'dart:io';
import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/profiles/data/profiles.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  @override
  Future<UserEntity> getProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener perfil',
        originalException: e,
        repositoryName: 'ProfilesRepository',
      );
    }
  }

  @override
  Future<UserEntity> updateProfile(
      {String? displayName, String? bio, String? avatarUrl}) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      final response = await supabase
          .from('profiles')
          .update(data)
          .eq('id', user.id)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al actualizar perfil',
        originalException: e,
        repositoryName: 'ProfilesRepository',
      );
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No hay sesión activa');
      final ext = filePath.split('.').last;
      final path = '${user.id}/avatar.$ext';
      final file = File(filePath);
      await supabase.storage
          .from('avatars')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      final url = supabase.storage.from('avatars').getPublicUrl(path);
      return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw RepositoryException(
        message: 'Error al subir avatar',
        originalException: e,
        repositoryName: 'ProfilesRepository',
      );
    }
  }

  @override
  Future<List<UserEntity>> getAllProfiles() async {
    try {
      final response =
          await supabase.from('profiles').select('*').order('email').limit(100);
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener perfiles',
        originalException: e,
        repositoryName: 'ProfilesRepository',
      );
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw RepositoryException(
        message: 'Error al cambiar contraseña',
        originalException: e,
        repositoryName: 'ProfilesRepository',
      );
    }
  }
}
