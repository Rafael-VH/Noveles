import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

abstract class ProfilesRepository {
  Future<Result<UserEntity>> getProfile();
  Future<Result<UserEntity>> updateProfile(
      {String? displayName, String? bio, String? avatarUrl});
  Future<Result<String>> uploadAvatar(String filePath);
  Future<Result<void>> changePassword(String newPassword);
  Future<Result<List<UserEntity>>> getAllProfiles({
    int limit = 50,
  });
  Future<Result<UserEntity>> updateUserRole({
    required String userId,
    required String role,
  });
}
