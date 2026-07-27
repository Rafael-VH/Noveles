import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class GetFavorites {
  final FavoriteRepository repository;

  GetFavorites(this.repository);

  Future<Result<List<BookWithRelations>>> call(String userId) async {
    return await repository.getFavorites(userId);
  }
}
