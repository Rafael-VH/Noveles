import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class UpdateProfile {
  final ProfilesRepository repository;

  UpdateProfile(this.repository);

  Future<UserEntity> call({String? displayName, String? bio, String? avatarUrl}) async {
    return await repository.updateProfile(displayName: displayName, bio: bio, avatarUrl: avatarUrl);
  }
}
