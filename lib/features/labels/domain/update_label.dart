import 'package:noveles/features/labels/domain/label_repository.dart';

class UpdateLabel {
  final LabelRepository repository;

  UpdateLabel(this.repository);

  Future<void> call(int id, String name, String color) {
    return repository.updateLabel(id, name, color);
  }
}
