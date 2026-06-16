import 'package:noveles/features/tooks/domain/took_repository.dart';

class DeleteTook {
  final TookRepository repository;

  DeleteTook(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteTook(id);
  }
}
