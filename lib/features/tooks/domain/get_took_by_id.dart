import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTookById {
  final TookRepository repository;

  GetTookById(this.repository);

  Future<Result<TookEntity?>> call(int id) async {
    return repository.getTookById(id);
  }
}
