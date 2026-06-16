import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTookById {
  final TookRepository repository;

  GetTookById(this.repository);

  Future<TookEntity?> call(int id) async {
    return await repository.getTookById(id);
  }
}
