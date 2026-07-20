import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class CreateTook {
  final TookRepository repository;

  CreateTook(this.repository);

  Future<Result<int>> call(TookEntity took) async {
    return repository.createTook(took);
  }
}
