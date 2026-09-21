import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/data/book_model.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final DataGateway _data;

  FavoriteRepositoryImpl(this._data);

  @override
  Future<Result<bool>> toggleFavorite(String userId, int bookId) async {
    try {
      final existing = await _data
          .from('user_favorites')
          .select('user_id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeRow();

      if (existing != null) {
        await _data
            .from('user_favorites')
            .eq('user_id', userId)
            .eq('book_id', bookId)
            .delete();
        return const Ok(false);
      } else {
        await _data.insert('user_favorites', {
          'user_id': userId,
          'book_id': bookId,
        });
        return const Ok(true);
      }
    } catch (e) {
      return Err(FavoriteFailure('Error al cambiar favorito', cause: e));
    }
  }

  @override
  Future<Result<List<BookWithRelations>>> getFavorites(String userId) async {
    try {
      final favorites = await _data
          .from('user_favorites')
          .select('book_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .rows();

      if (favorites.isEmpty) return const Ok([]);

      final bookIds = favorites.map((r) => r['book_id'] as int).toList();

      // Aggregate read: the relation tree is resolved by the backend adapter.
      final booksResponse = await _data.booksWithRelationsByIds(bookIds);

      final books = booksResponse
          .map((json) => BookModel.fromJson(json))
          .toList();

      return Ok(books);
    } catch (e) {
      return Err(FavoriteFailure('Error al obtener favoritos', cause: e));
    }
  }

  @override
  Future<Result<bool>> isFavorite(String userId, int bookId) async {
    try {
      final response = await _data
          .from('user_favorites')
          .select('user_id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeRow();

      return Ok(response != null);
    } catch (e) {
      return Err(FavoriteFailure('Error al verificar favorito', cause: e));
    }
  }
}
