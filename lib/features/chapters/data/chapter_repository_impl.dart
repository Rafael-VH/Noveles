import 'dart:convert';

import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/chapter_cache.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/chapters/data/chapter_model.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final SupabaseClientProvider _supabase;

  ChapterRepositoryImpl(this._supabase);

  @override
  Future<Result<List<ChapterEntity>>> getChapters() async {
    try {
      final response =
          await _supabase.client.from('chapters').select('*').order('id').limit(100);
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
  Future<Result<void>> createChapter(ChapterEntity chapter) async {
    try {
      await _supabase.client.from('chapters').insert({
        'created_at': chapter.createdAt.toIso8601String(),
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
        'created_by': _supabase.client.auth.currentUser?.id,
      });
      return const Ok(null);
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

  bool _isStoragePath(String s) =>
      s.contains('/') || s.endsWith('.txt') || s.endsWith('.json');

  @override
  Future<Result<String>> downloadContent(String path) async {
    try {
      if (!_isStoragePath(path)) return Ok(path);
      final cached = await ChapterCache.read(path);
      if (cached != null) return Ok(cached);
      final bytes = await _supabase.client.storage.from('chapters').download(path);
      final content = utf8.decode(bytes);
      await ChapterCache.save(path, bytes);
      return Ok(content);
    } catch (e) {
      return Err(ChapterFailure('Error al descargar contenido', cause: e));
    }
  }
}
