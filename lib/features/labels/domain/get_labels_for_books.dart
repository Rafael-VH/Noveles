import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class GetLabelsForBooks {
  final LabelRepository repository;

  GetLabelsForBooks(this.repository);

  Future<Result<Map<int, Set<int>>>> call(List<int> bookIds) =>
      repository.getBookLabels(bookIds);
}
