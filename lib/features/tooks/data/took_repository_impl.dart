import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class TookRepositoryImpl implements TookRepository {
  final SupabaseClientProvider _supabase;

  TookRepositoryImpl(this._supabase);

  @override
  Future<Result<List<TookEntity>>> getTooks() async {
    try {
      final response = await _supabase.client
          .from('tooks')
          .select('*, chapters(*)')
          .order('id')
          .limit(100);

      final tooks = response.map((json) => TookModel.fromJson(json)).toList();
      return Ok(tooks);
    } catch (e) {
      return Err(TookFailure('Error al obtener tomos', cause: e));
    }
  }

  @override
  Future<Result<List<TookEntity>>> getTooksByBook(int bookId) async {
    try {
      final response = await _supabase.client
          .from('tooks')
          .select('*, chapters(*)')
          .eq('book_id', bookId)
          .order('id')
          .limit(100);

      final tooks = response.map((json) => TookModel.fromJson(json)).toList();
      return Ok(tooks);
    } catch (e) {
      return Err(TookFailure('Error al obtener tomos del libro', cause: e));
    }
  }

  @override
  Future<Result<TookEntity?>> getTookById(int id) async {
    try {
      final response = await _supabase.client
          .from('tooks')
          .select('*, chapters(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return const Ok(null);
      return Ok(TookModel.fromJson(response));
    } catch (e) {
      return Err(TookFailure('Error al obtener tomo', cause: e));
    }
  }

  @override
  Future<Result<void>> createTook(TookEntity took) async {
    try {
      await _supabase.client.from('tooks').insert({
        'created_at': took.createdAt.toIso8601String(),
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'chapter_count': took.chapterCount,
        'book_id': took.bookId,
        'created_by': _supabase.client.auth.currentUser?.id,
      });
      return const Ok(null);
    } catch (e) {
      return Err(TookFailure('Error al crear tomo', cause: e));
    }
  }

  @override
  Future<Result<void>> updateTook(TookEntity took) async {
    try {
      await _supabase.client.from('tooks').update({
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'chapter_count': took.chapterCount,
        'book_id': took.bookId,
      }).eq('id', took.id);
      return const Ok(null);
    } catch (e) {
      return Err(TookFailure('Error al actualizar tomo', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteTook(int id) async {
    try {
      await _supabase.client.from('tooks').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(TookFailure('Error al eliminar tomo', cause: e));
    }
  }
}
