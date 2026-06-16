import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';

abstract class LabelRepository {
  Future<Result<List<LabelEntity>>> getLabels();
  Future<Result<void>> createLabel(LabelEntity label);
  Future<Result<void>> updateLabel(int id, String name, String color);
  Future<Result<void>> deleteLabel(int id);
  Future<Result<void>> assignLabel(int bookId, int labelId);
  Future<Result<void>> removeLabel(int bookId, int labelId);
}
