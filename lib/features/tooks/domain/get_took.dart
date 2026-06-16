import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTook {
  final TookRepository repository;

  GetTook(this.repository);

  Future<List<TookEntity>> call() async {
    return await repository.getTooks();
  }
}
