import 'dart:io';
import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/data/models/models.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class BookRepositoryImpl implements BookRepository {
  @override
  Future<List<BookEntity>> getBooks({bool onlyVisible = false}) async {
    try {
      var query = supabase.from('books').select(
          '*, authors!inner(*), books_genres!inner(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))');

      if (onlyVisible) {
        query = query.eq('is_visible', true);
      }

      final response = await query.order('id').limit(100);
      return response.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener libros',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<BookEntity?> getBookById(int id) async {
    try {
      final response = await supabase
          .from('books')
          .select(
              '*, authors!inner(*), books_genres!inner(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return BookModel.fromJson(response);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener libro',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<void> createBook(BookEntity book) async {
    try {
      int authorId = book.authorId;
      if (authorId == 0 && book.author.isNotEmpty) {
        final existing = await supabase
            .from('authors')
            .select('id')
            .eq('name', book.author)
            .maybeSingle();
        if (existing != null) {
          authorId = existing['id'];
        } else {
          final result = await supabase
              .from('authors')
              .insert({'name': book.author})
              .select('id')
              .single();
          authorId = result['id'];
        }
      }
      final result = await supabase
          .from('books')
          .insert({
            'created_at': book.createdAt.toIso8601String(),
            'cover': book.cover,
            'name': book.name,
            'short': book.short,
            'alternative': book.alternative,
            'description': book.description,
            'author_id': authorId,
            'country': book.country,
            'state': book.state,
            'type': book.type,
            'release': book.release,
            'took_count': book.tookCount,
            'chapter_count': book.chapterCount,
            'source': book.source,
            'link': book.link,
            'is_favorite': book.isFavorite,
            'created_by': supabase.auth.currentUser?.id,
          })
          .select('id')
          .single();
      final newBookId = result['id'];
      for (final genre in book.listGenre) {
        await supabase.from('books_genres').insert({
          'book_id': newBookId,
          'genre_id': genre.id,
        });
      }
      for (final label in book.listLabel) {
        await supabase.from('books_labels').insert({
          'book_id': newBookId,
          'label_id': label.id,
        });
      }
    } catch (e) {
      throw RepositoryException(
        message: 'Error al crear libro',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    try {
      await supabase.from('books').update({
        'cover': book.cover,
        'name': book.name,
        'short': book.short,
        'alternative': book.alternative,
        'description': book.description,
        'author_id': book.authorId,
        'country': book.country,
        'state': book.state,
        'type': book.type,
        'release': book.release,
        'took_count': book.tookCount,
        'chapter_count': book.chapterCount,
        'source': book.source,
        'link': book.link,
        'is_favorite': book.isFavorite,
      }).eq('id', book.id);
      await supabase.from('books_genres').delete().eq('book_id', book.id);
      for (final genre in book.listGenre) {
        await supabase.from('books_genres').insert({
          'book_id': book.id,
          'genre_id': genre.id,
        });
      }
      await supabase.from('books_labels').delete().eq('book_id', book.id);
      for (final label in book.listLabel) {
        await supabase.from('books_labels').insert({
          'book_id': book.id,
          'label_id': label.id,
        });
      }
    } catch (e) {
      throw RepositoryException(
        message: 'Error al actualizar libro',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<void> deleteBook(int id) async {
    try {
      await supabase.from('books').delete().eq('id', id);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al eliminar libro',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<void> toggleBookVisibility(int bookId, bool isVisible) async {
    try {
      await supabase
          .from('books')
          .update({'is_visible': isVisible}).eq('id', bookId);
    } catch (e) {
      throw RepositoryException(
        message: 'Error al cambiar visibilidad',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<String> uploadCover(String filePath) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last;
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      await supabase.storage.from('covers').upload(filename, file);
      return filename;
    } catch (e) {
      throw RepositoryException(
        message: 'Error al subir cover',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }

  @override
  Future<Map<int, Set<int>>> getBookLabels() async {
    try {
      final rows = await supabase.from('books_labels').select();
      final map = <int, Set<int>>{};
      for (final row in rows) {
        map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
      }
      return map;
    } catch (e) {
      throw RepositoryException(
        message: 'Error al obtener etiquetas de libros',
        originalException: e,
        repositoryName: 'BookRepository',
      );
    }
  }
}
