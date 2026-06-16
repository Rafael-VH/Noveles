import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class UpdateTook {
  final TookRepository repository;

  UpdateTook(this.repository);

  Future<void> call(TookEntity took) async {
    return await repository.updateTook(took);
  }
}
