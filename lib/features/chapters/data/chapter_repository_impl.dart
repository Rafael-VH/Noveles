import 'dart:convert';
import 'dart:io';

import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/core/constants/storage_constants.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/data/chapter_cache.dart';
import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final DataGateway _data;
  final StorageGateway _storage;

  ChapterRepositoryImpl(this._data, this._storage);

  static const int _maxChapterSize = 10 * 1024 * 1024; // 10MB
  static const _allowedExtensions = ['txt', 'html'];

  @override
  Future<Result<List<ChapterEntity>>> getChapters(
      {int page = 1, int pageSize = 50}) async {
    try {
      final offset = (page - 1) * pageSize;
      final rows = await _data
          .from('chapters')
          .order('id')
          .limit(pageSize)
          .range(offset, offset + pageSize - 1)
          .rows();
      final chapters =
          rows.map((json) => ChapterModel.fromJson(json)).toList();
      return Ok(chapters);
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulos', cause: e));
    }
  }

  @override
  Future<Result<ChapterEntity?>> getChapterById(int id) async {
    try {
      final row = await _data.from('chapters').eq('id', id).maybeRow();
      if (row == null) return const Ok(null);
      return Ok(ChapterModel.fromJson(row));
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulo', cause: e));
    }
  }

  @override
  Future<Result<int>> createChapter(ChapterEntity chapter) async {
    try {
      final row = await _data.insert(
        'chapters',
        {
          'created_at': chapter.createdAt.toIso8601String(),
          'number': chapter.number,
          'title': chapter.title,
          'content': chapter.content,
          'took_id': chapter.tookId,
          'created_by': _data.identity?.id,
          'content_type': chapter.contentType.name,
        },
        returning: 'id',
      );
      final newChapterId = row!['id'] as int;
      return Ok(newChapterId);
    } catch (e) {
      return Err(ChapterFailure('Error al crear capítulo', cause: e));
    }
  }

  @override
  Future<Result<void>> updateChapter(ChapterEntity chapter) async {
    try {
      await _data.from('chapters').eq('id', chapter.id).update({
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
        'content_type': chapter.contentType.name,
      });
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al actualizar capítulo', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteChapter(int id) async {
    try {
      await _data.from('chapters').eq('id', id).delete();
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al eliminar capítulo', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadContent(String filePath) async {
    try {
      // Validar extensión
      final ext = filePath.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        return Err(ChapterFailure('Formato no permitido. Usa: TXT o HTML'));
      }

      // Validar tamaño
      final file = File(filePath);
      final fileSize = await file.length();
      if (fileSize > _maxChapterSize) {
        return Err(ChapterFailure(
            'El archivo es demasiado grande. Máximo: 10MB'));
      }

      final userId = _data.identity?.id;
      if (userId == null) return Err(ChapterFailure('No hay sesión activa'));

      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _storage.upload(StorageConstants.chaptersBucket, filename, file);
      final url =
          _storage.publicUrl(StorageConstants.chaptersBucket, filename);
      return Ok(url);
    } catch (e) {
      return Err(ChapterFailure('Error al subir contenido', cause: e));
    }
  }

  @override
  Future<Result<void>> markChapterAsRead(int chapterId, String userId) async {
    try {
      await _data.insert('chapter_reads', {
        'user_id': userId,
        'chapter_id': chapterId,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      });
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al marcar capítulo como leído',
          cause: e));
    }
  }

  @override
  Future<Result<Set<int>>> getReadChapterIds(int tookId, String userId) async {
    try {
      final chapterRows = await _data
          .from('chapters')
          .select('id')
          .eq('took_id', tookId)
          .rows();
      if (chapterRows.isEmpty) return const Ok({});
      final ids = chapterRows.map<int>((e) => e['id'] as int).toList();
      final response = await _data
          .from('chapter_reads')
          .select('chapter_id')
          .eq('user_id', userId)
          .inList('chapter_id', ids)
          .rows();
      return Ok(response.map<int>((e) => e['chapter_id'] as int).toSet());
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulos leídos', cause: e));
    }
  }

  @override
  Future<Result<String>> downloadContent(String path,
      {ChapterContentType contentType = ChapterContentType.storagePath}) async {
    try {
      if (contentType == ChapterContentType.inline) return Ok(path);
      final cached = await ChapterCache.read(path);
      if (cached != null) return Ok(cached);
      final bytes =
          await _storage.download(StorageConstants.chaptersBucket, path);
      final content = utf8.decode(bytes);
      await ChapterCache.save(path, bytes);
      return Ok(content);
    } catch (e) {
      return Err(ChapterFailure('Error al descargar contenido', cause: e));
    }
  }
}
