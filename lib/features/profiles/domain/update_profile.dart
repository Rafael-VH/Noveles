import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class UpdateProfile {
  final ProfilesRepository repository;

  UpdateProfile(this.repository);

  Future<Result<UserEntity>> call(
      {String? displayName, String? bio, String? avatarUrl}) async {
    return repository.updateProfile(
        displayName: displayName, bio: bio, avatarUrl: avatarUrl);
  }
}
