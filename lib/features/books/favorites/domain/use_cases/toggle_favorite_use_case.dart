import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';

class ToggleFavorite {
  final FavoriteRepository repository;

  ToggleFavorite(this.repository);

  Future<Result<bool>> call(String userId, int bookId) async {
    return await repository.toggleFavorite(userId, bookId);
  }
}
