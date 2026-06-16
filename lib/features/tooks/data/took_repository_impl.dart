import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class TookRepositoryImpl implements TookRepository {
  @override
  Future<List<TookEntity>> getTooks() async {
    try {
      final response = await supabase
          .from('tooks')
          .select('*, chapters(*)')
          .order('id')
          .limit(100);

      return response.map((json) => TookModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener tomos',
        originalException: e,
        repositoryName: 'TookRepository',
      );
    }
  }

  @override
  Future<TookEntity?> getTookById(int id) async {
    try {
      final response = await supabase
          .from('tooks')
          .select('*, chapters(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TookModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener tomo',
        originalException: e,
        repositoryName: 'TookRepository',
      );
    }
  }

  @override
  Future<void> createTook(TookEntity took) async {
    try {
      await supabase.from('tooks').insert({
        'created_at': took.createdAt.toIso8601String(),
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'chapter_count': took.chapterCount,
        'book_id': took.bookId,
        'created_by': supabase.auth.currentUser?.id,
      });
    } catch (e) {
      throw RepositoryException(
        message: 'Error al crear tomo',
        originalException: e,
        repositoryName: 'TookRepository',
      );
    }
  }

  @override
  Future<void> updateTook(TookEntity took) async {
    try {
      await supabase.from('tooks').update({
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'chapter_count': took.chapterCount,
        'book_id': took.bookId,
      }).eq('id', took.id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al actualizar tomo',
        originalException: e,
        repositoryName: 'TookRepository',
      );
    }
  }

  @override
  Future<void> deleteTook(int id) async {
    try {
      await supabase.from('chapters').delete().eq('took_id', id);
      await supabase.from('tooks').delete().eq('id', id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al eliminar tomo',
        originalException: e,
        repositoryName: 'TookRepository',
      );
    }
  }
}
