import 'package:noveles/features/profiles/domain/user_entity.dart';

abstract class ProfilesRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile(
      {String? displayName, String? bio, String? avatarUrl});
  Future<String> uploadAvatar(String filePath);
  Future<void> changePassword(String newPassword);
  Future<List<UserEntity>> getAllProfiles();
}
