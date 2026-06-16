import 'package:noveles/features/labels/domain/label_repository.dart';

class DeleteLabel {
  final LabelRepository repository;

  DeleteLabel(this.repository);

  Future<void> call(int id) => repository.deleteLabel(id);
}
