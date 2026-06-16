import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class DeleteLabel {
  final LabelRepository repository;

  DeleteLabel(this.repository);

  Future<Result<void>> call(int id) => repository.deleteLabel(id);
}
