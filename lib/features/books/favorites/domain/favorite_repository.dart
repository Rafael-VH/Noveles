import 'package:noveles/core/errors/result.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class FavoriteRepository {
  Future<Result<bool>> toggleFavorite(String userId, int bookId);
  Future<Result<List<BookWithRelations>>> getFavorites(String userId);
  Future<Result<bool>> isFavorite(String userId, int bookId);
}
