import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class CreateTook {
  final TookRepository repository;

  CreateTook(this.repository);

  Future<void> call(TookEntity took) async {
    return await repository.createTook(took);
  }
}
