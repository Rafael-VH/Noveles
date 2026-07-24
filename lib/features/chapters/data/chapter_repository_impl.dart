import 'dart:convert';
import 'dart:io';

import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/chapter_cache.dart';
import 'package:noveles/core/constants/storage_constants.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final SupabaseClientProvider _supabase;

  ChapterRepositoryImpl(this._supabase);

  @override
  Future<Result<List<ChapterEntity>>> getChapters({int page = 1, int pageSize = 50}) async {
    try {
      final offset = (page - 1) * pageSize;
      final response = await _supabase.client
          .from('chapters')
          .select('*')
          .order('id')
          .limit(pageSize)
          .range(offset, offset + pageSize - 1);
      final chapters = response.map((json) => ChapterModel.fromJson(json)).toList();
      return Ok(chapters);
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulos', cause: e));
    }
  }

  @override
  Future<Result<ChapterEntity?>> getChapterById(int id) async {
    try {
      final response = await _supabase.client
          .from('chapters')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return const Ok(null);
      return Ok(ChapterModel.fromJson(response));
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulo', cause: e));
    }
  }

  @override
  Future<Result<int>> createChapter(ChapterEntity chapter) async {
    try {
      final result = await _supabase.client.from('chapters').insert({
        'created_at': chapter.createdAt.toIso8601String(),
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
        'created_by': _supabase.client.auth.currentUser?.id,
      }).select('id').single();
      final newChapterId = result['id'] as int;
      return Ok(newChapterId);
    } catch (e) {
      return Err(ChapterFailure('Error al crear capítulo', cause: e));
    }
  }

  @override
  Future<Result<void>> updateChapter(ChapterEntity chapter) async {
    try {
      await _supabase.client.from('chapters').update({
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
      }).eq('id', chapter.id);
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al actualizar capítulo', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteChapter(int id) async {
    try {
      await _supabase.client.from('chapters').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al eliminar capítulo', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadContent(String filePath) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last;
      final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.client.storage.from(StorageConstants.chaptersBucket).upload(filename, file);
      final url = _supabase.client.storage.from(StorageConstants.chaptersBucket).getPublicUrl(filename);
      return Ok(url);
    } catch (e) {
      return Err(ChapterFailure('Error al subir contenido: $e', cause: e));
    }
  }

  @override
  Future<Result<void>> markChapterAsRead(int chapterId, String userId) async {
    try {
      await _supabase.client.from('chapter_reads').insert({
        'user_id': userId,
        'chapter_id': chapterId,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      });
      return const Ok(null);
    } catch (e) {
      return Err(ChapterFailure('Error al marcar capítulo como leído', cause: e));
    }
  }

  @override
  Future<Result<Set<int>>> getReadChapterIds(int tookId, String userId) async {
    try {
      final chapterIds = await _supabase.client
          .from('chapters')
          .select('id')
          .eq('took_id', tookId);
      if (chapterIds.isEmpty) return const Ok({});
      final ids = chapterIds.map<int>((e) => e['id'] as int).toList();
      final response = await _supabase.client
          .from('chapter_reads')
          .select('chapter_id')
          .eq('user_id', userId)
          .inFilter('chapter_id', ids);
      return Ok(response.map<int>((e) => e['chapter_id'] as int).toSet());
    } catch (e) {
      return Err(ChapterFailure('Error al obtener capítulos leídos', cause: e));
    }
  }

  @override
  Future<Result<String>> downloadContent(String path, {ChapterContentType contentType = ChapterContentType.storagePath}) async {
    try {
      if (contentType == ChapterContentType.inline) return Ok(path);
      final cached = await ChapterCache.read(path);
      if (cached != null) return Ok(cached);
      final bytes = await _supabase.client.storage.from(StorageConstants.chaptersBucket).download(path);
      final content = utf8.decode(bytes);
      await ChapterCache.save(path, bytes);
      return Ok(content);
    } catch (e) {
      return Err(ChapterFailure('Error al descargar contenido', cause: e));
    }
  }
}
