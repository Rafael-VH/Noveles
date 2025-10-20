import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetTookById {
  final TookRepository repository;

  GetTookById(this.repository);

  Future<TookEntity?> call(int id) async {
    return await repository.getTookById(id);
  }
}
