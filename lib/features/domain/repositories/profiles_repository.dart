import 'dart:io';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class ProfilesRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({String? displayName, String? bio, String? avatarUrl});
  Future<String> uploadAvatar(File file);
  Future<void> changePassword(String newPassword);
}
