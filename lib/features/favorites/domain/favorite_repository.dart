import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/favorites/domain/favorite_entity.dart';

abstract class FavoriteRepository {
  Future<Result<bool>> toggleFavorite(String userId, int bookId);
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId);
  Future<Result<bool>> isFavorite(String userId, int bookId);
}
