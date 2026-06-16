import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class UpdateLabel {
  final LabelRepository repository;

  UpdateLabel(this.repository);

  Future<Result<void>> call(int id, String name, String color) {
    return repository.updateLabel(id, name, color);
  }
}
