import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class RemoveLabelFromBook {
  final LabelRepository repository;

  RemoveLabelFromBook(this.repository);

  Future<Result<void>> call(int bookId, int labelId) =>
      repository.removeLabel(bookId, labelId);
}
