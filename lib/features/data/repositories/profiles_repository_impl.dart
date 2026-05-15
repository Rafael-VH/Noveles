import 'dart:io';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilesRepositoryImpl implements ProfilesRepository {
  @override
  Future<UserEntity> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();
    return _mapToEntity(response);
  }

  @override
  Future<UserEntity> updateProfile({String? displayName, String? bio, String? avatarUrl}) async {
    final userId = supabase.auth.currentUser!.id;
    final data = <String, dynamic>{};
    if (displayName != null) data['display_name'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    final response = await supabase
        .from('profiles')
        .update(data)
        .eq('id', userId)
        .single();
    return _mapToEntity(response);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final userId = supabase.auth.currentUser!.id;
    final path = '$userId/avatar.jpg';
    await supabase.storage.from('avatars').upload(path, file, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<void> changePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
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
