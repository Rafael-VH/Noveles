import 'package:noveles/features/domain/repositories/repositories.dart';

class DeleteLabel {
  final LabelRepository repository;

  DeleteLabel(this.repository);

  Future<void> call(int id) => repository.deleteLabel(id);
}
