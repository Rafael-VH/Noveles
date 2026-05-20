import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetAllProfiles {
  final ProfilesRepository repository;

  GetAllProfiles(this.repository);

  Future<List<UserEntity>> call() async {
    return await repository.getAllProfiles();
  }
}
