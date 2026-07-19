import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

abstract class TookRepository {
  Future<Result<List<TookEntity>>> getTooks();
  Future<Result<List<TookEntity>>> getTooksByBook(int bookId);
  Future<Result<TookEntity?>> getTookById(int id);
  Future<Result<void>> createTook(TookEntity took);
  Future<Result<void>> updateTook(TookEntity took);
  Future<Result<void>> deleteTook(int id);
}
