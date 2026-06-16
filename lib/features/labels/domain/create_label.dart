import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class CreateLabel {
  final LabelRepository repository;

  CreateLabel(this.repository);

  Future<Result<void>> call(LabelEntity label) => repository.createLabel(label);
}
