import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class GetLabels {
  final LabelRepository repository;

  GetLabels(this.repository);

  Future<Result<List<LabelEntity>>> call() => repository.getLabels();
}
