import 'package:noveles/features/main/domain/entities/entities.dart';

abstract class TookRepository {
  Future<List<TookEntity>> getTooks();
  Future<TookEntity?> getTookById(int id);
  Future<void> createTook(TookEntity took);
  Future<void> updateTook(TookEntity took);
  Future<void> deleteTook(int id);
}
