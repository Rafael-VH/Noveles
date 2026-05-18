import 'package:noveles/features/domain/entities/entities.dart';

abstract class LabelRepository {
  Future<List<LabelEntity>> getLabels();
  Future<void> createLabel(String name, String color);
  Future<void> deleteLabel(int id);
  Future<void> assignLabel(int bookId, int labelId);
  Future<void> removeLabel(int bookId, int labelId);
}
