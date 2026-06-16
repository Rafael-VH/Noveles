import 'package:noveles/features/labels/domain/label_entity.dart';

abstract class LabelRepository {
  Future<List<LabelEntity>> getLabels();
  Future<void> createLabel(LabelEntity label);
  Future<void> updateLabel(int id, String name, String color);
  Future<void> deleteLabel(int id);
  Future<void> assignLabel(int bookId, int labelId);
  Future<void> removeLabel(int bookId, int labelId);
}
