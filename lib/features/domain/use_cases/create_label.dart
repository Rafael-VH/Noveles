import 'package:noveles/features/domain/repositories/repositories.dart';

class CreateLabel {
  final LabelRepository repository;

  CreateLabel(this.repository);

  Future<void> call(String name, String color) => repository.createLabel(name, color);
}
