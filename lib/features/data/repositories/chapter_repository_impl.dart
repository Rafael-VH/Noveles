import 'dart:convert';

import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/chapter_cache.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/data/models/models.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  @override
  Future<List<ChapterEntity>> getChapters() async {
    try {
      final response =
          await supabase.from('chapters').select('*').order('id').limit(100);
      return response.map((json) => ChapterModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener capítulos',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }

  @override
  Future<ChapterEntity?> getChapterById(int id) async {
    try {
      final response = await supabase
          .from('chapters')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return ChapterModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener capítulo',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }

  @override
  Future<void> createChapter(ChapterEntity chapter) async {
    try {
      await supabase.from('chapters').insert({
        'created_at': chapter.createdAt.toIso8601String(),
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
      });
    } catch (e) {
      throw RepositoryException(
        message: 'Error al crear capítulo',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }

  @override
  Future<void> updateChapter(ChapterEntity chapter) async {
    try {
      await supabase.from('chapters').update({
        'number': chapter.number,
        'title': chapter.title,
        'content': chapter.content,
        'took_id': chapter.tookId,
      }).eq('id', chapter.id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al actualizar capítulo',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }

  @override
  Future<void> deleteChapter(int id) async {
    try {
      await supabase.from('chapters').delete().eq('id', id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al eliminar capítulo',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }

  @override
  Future<String> downloadContent(String path) async {
    try {
      final cached = await ChapterCache.read(path);
      if (cached != null) return cached;
      final bytes = await supabase.storage.from('chapters').download(path);
      final content = utf8.decode(bytes);
      await ChapterCache.save(path, bytes);
      return content;
    } catch (e) {
      throw RepositoryException(
        message: 'Error al descargar contenido',
        originalException: e,
        repositoryName: 'ChapterRepository',
      );
    }
  }
}
