import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_model.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final SupabaseClientProvider _supabase;

  FavoriteRepositoryImpl(this._supabase);

  @override
  Future<Result<bool>> toggleFavorite(String userId, int bookId) async {
    try {
      final existing = await _supabase.client
          .from('user_favorites')
          .select('user_id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      if (existing != null) {
        await _supabase.client
            .from('user_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('book_id', bookId);
        return const Ok(false);
      } else {
        await _supabase.client.from('user_favorites').insert({
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
      final response = await _supabase.client
          .from('user_favorites')
          .select('book_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) return const Ok([]);

      final bookIds = response.map((r) => r['book_id'] as int).toList();

      final booksResponse = await _supabase.client
          .from('books')
          .select(
              '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))')
          .inFilter('id', bookIds);

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
      final response = await _supabase.client
          .from('user_favorites')
          .select('user_id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      return Ok(response != null);
    } catch (e) {
      return Err(FavoriteFailure('Error al verificar favorito', cause: e));
    }
  }
}
