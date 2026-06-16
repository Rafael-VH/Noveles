import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class GetProfile {
  final ProfilesRepository repository;

  GetProfile(this.repository);

  Future<Result<UserEntity>> call() async {
    return repository.getProfile();
  }
}
