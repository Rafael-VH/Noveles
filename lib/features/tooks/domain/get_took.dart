import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTook {
  final TookRepository repository;

  GetTook(this.repository);

  Future<Result<List<TookEntity>>> call() async {
    return repository.getTooks();
  }
}
