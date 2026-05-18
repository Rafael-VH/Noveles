import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class GetLabels {
  final LabelRepository repository;

  GetLabels(this.repository);

  Future<List<LabelEntity>> call() => repository.getLabels();
}
