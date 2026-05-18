import 'package:noveles/features/domain/repositories/repositories.dart';

class AssignLabelToBook {
  final LabelRepository repository;

  AssignLabelToBook(this.repository);

  Future<void> call(int bookId, int labelId) => repository.assignLabel(bookId, labelId);
}
