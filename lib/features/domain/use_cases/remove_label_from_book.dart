import 'package:noveles/features/domain/repositories/repositories.dart';

class RemoveLabelFromBook {
  final LabelRepository repository;

  RemoveLabelFromBook(this.repository);

  Future<void> call(int bookId, int labelId) => repository.removeLabel(bookId, labelId);
}
