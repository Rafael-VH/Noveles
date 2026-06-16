import 'package:noveles/features/labels/domain/label_repository.dart';

class AssignLabelToBook {
  final LabelRepository repository;

  AssignLabelToBook(this.repository);

  Future<void> call(int bookId, int labelId) =>
      repository.assignLabel(bookId, labelId);
}
