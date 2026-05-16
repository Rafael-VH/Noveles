import 'dart:io';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';
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
      return _mapToEntity(response);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
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
      return _mapToEntity(response);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
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
      throw Exception('Error al subir avatar: $e');
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  UserEntity _mapToEntity(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'],
      email: supabase.auth.currentUser?.email ?? '',
      role: data['role'] ?? 'user',
      displayName: data['display_name'],
      bio: data['bio'],
      avatarUrl: data['avatar_url'],
    );
  }
}
