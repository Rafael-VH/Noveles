import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class DeleteTook {
  final TookRepository repository;

  DeleteTook(this.repository);

  Future<Result<void>> call(int id) async {
    return repository.deleteTook(id);
  }
}
