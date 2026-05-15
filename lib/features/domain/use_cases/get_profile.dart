import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetProfile {
  final ProfilesRepository repository;

  GetProfile(this.repository);

  Future<UserEntity> call() async {
    return await repository.getProfile();
  }
}
