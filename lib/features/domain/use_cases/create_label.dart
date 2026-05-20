import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class CreateLabel {
  final LabelRepository repository;

  CreateLabel(this.repository);

  Future<void> call(LabelEntity label) => repository.createLabel(label);
}
