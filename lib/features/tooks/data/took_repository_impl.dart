import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class TookRepositoryImpl implements TookRepository {
  final DataGateway _data;

  TookRepositoryImpl(this._data);

  @override
  Future<Result<List<TookEntity>>> getTooks() async {
    try {
      // Aggregate read: the chapters relation is resolved by the adapter.
      final rows = await _data.tooksWithChapters(limit: 100);
      final tooks = rows.map((json) => TookModel.fromJson(json)).toList();
      return Ok(tooks);
    } catch (e) {
      return Err(TookFailure('Error al obtener tomos', cause: e));
    }
  }

  @override
  Future<Result<List<TookEntity>>> getTooksByBook(int bookId) async {
    try {
      final rows = await _data.tooksWithChapters(bookId: bookId, limit: 100);
      final tooks = rows.map((json) => TookModel.fromJson(json)).toList();
      return Ok(tooks);
    } catch (e) {
      return Err(TookFailure('Error al obtener tomos del libro', cause: e));
    }
  }

  @override
  Future<Result<TookEntity?>> getTookById(int id) async {
    try {
      final row = await _data.tookWithChaptersById(id);
      if (row == null) return const Ok(null);
      return Ok(TookModel.fromJson(row));
    } catch (e) {
      return Err(TookFailure('Error al obtener tomo', cause: e));
    }
  }

  @override
  Future<Result<int>> createTook(TookEntity took) async {
    try {
      final row = await _data.insert(
        'tooks',
        {
          'created_at': took.createdAt.toIso8601String(),
          'cover': took.cover,
          'number': took.number,
          'title': took.title,
          'chapter_count': took.chapterCount,
          'book_id': took.bookId,
          // Ownership comes from the acting identity, not from a vendor SDK.
          'created_by': _data.identity?.id,
        },
        returning: 'id',
      );
      final newTookId = row!['id'] as int;
      return Ok(newTookId);
    } catch (e) {
      return Err(TookFailure('Error al crear tomo', cause: e));
    }
  }

  @override
  Future<Result<void>> updateTook(TookEntity took) async {
    try {
      await _data.from('tooks').eq('id', took.id).update({
        'cover': took.cover,
        'number': took.number,
        'title': took.title,
        'chapter_count': took.chapterCount,
        'book_id': took.bookId,
      });
      return const Ok(null);
    } catch (e) {
      return Err(TookFailure('Error al actualizar tomo', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteTook(int id) async {
    try {
      await _data.from('tooks').eq('id', id).delete();
      return const Ok(null);
    } catch (e) {
      return Err(TookFailure('Error al eliminar tomo', cause: e));
    }
  }
}
