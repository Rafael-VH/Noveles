import 'package:noveles/features/tooks/domain/took_entity.dart';

abstract class TookRepository {
  Future<List<TookEntity>> getTooks();
  Future<TookEntity?> getTookById(int id);
  Future<void> createTook(TookEntity took);
  Future<void> updateTook(TookEntity took);
  Future<void> deleteTook(int id);
}
