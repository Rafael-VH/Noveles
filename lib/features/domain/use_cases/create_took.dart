import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class CreateTook {
  final TookRepository repository;

  CreateTook(this.repository);

  Future<void> call(TookEntity took) async {
    return await repository.createTook(took);
  }
}
