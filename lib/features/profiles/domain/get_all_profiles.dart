import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';

class GetAllProfiles {
  final ProfilesRepository repository;

  GetAllProfiles(this.repository);

  Future<List<UserEntity>> call() async {
    return await repository.getAllProfiles();
  }
}
