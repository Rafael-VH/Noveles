import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class GetProfile {
  final ProfilesRepository repository;

  GetProfile(this.repository);

  Future<UserEntity> call() async {
    return await repository.getProfile();
  }
}
