import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetTook {
  final TookRepository repository;

  GetTook(this.repository);

  Future<List<TookEntity>> call() async {
    return await repository.getTooks();
  }
}
