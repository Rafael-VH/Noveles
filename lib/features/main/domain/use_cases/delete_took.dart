import 'package:noveles/features/main/domain/repositories/repositories.dart';

class DeleteTook {
  final TookRepository repository;

  DeleteTook(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteTook(id);
  }
}
