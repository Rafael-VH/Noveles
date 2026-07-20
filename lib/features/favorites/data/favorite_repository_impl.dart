import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/favorites/domain/favorite_entity.dart';
import 'package:noveles/features/favorites/domain/favorite_repository.dart';

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
  Future<Result<List<FavoriteEntity>>> getFavorites(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final favorites = response
          .map((json) => FavoriteEntity(
                userId: json['user_id'] as String,
                bookId: json['book_id'] as int,
                createdAt: DateTime.parse(json['created_at'] as String),
              ))
          .toList();

      return Ok(favorites);
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
