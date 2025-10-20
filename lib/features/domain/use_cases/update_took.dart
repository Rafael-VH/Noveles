import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class UpdateTook {
  final TookRepository repository;

  UpdateTook(this.repository);

  Future<void> call(TookEntity took) async {
    return await repository.updateTook(took);
  }
}
