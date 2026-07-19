import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTooksByBook {
  final TookRepository _repo;
  GetTooksByBook(this._repo);
  Future<Result<List<TookEntity>>> call(int bookId) => _repo.getTooksByBook(bookId);
}
