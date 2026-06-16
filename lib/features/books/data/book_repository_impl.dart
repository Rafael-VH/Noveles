import 'dart:io';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_model.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final SupabaseClientProvider _supabase;

  BookRepositoryImpl(this._supabase);

  @override
  Future<Result<List<BookEntity>>> getBooks({bool onlyVisible = false}) async {
    try {
      var query = _supabase.client.from('books').select(
          '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))');

      if (onlyVisible) {
        query = query.eq('is_visible', true);
      }

      final response = await query.order('id').limit(100);
      final books = response.map((json) => BookModel.fromJson(json)).toList();
      return Ok(books);
    } catch (e) {
      return Err(BookFailure('Error al obtener libros', cause: e));
    }
  }

  @override
  Future<Result<BookEntity?>> getBookById(int id) async {
    try {
      final response = await _supabase.client
          .from('books')
          .select(
              '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return const Ok(null);
      return Ok(BookModel.fromJson(response));
    } catch (e) {
      return Err(BookFailure('Error al obtener libro', cause: e));
    }
  }

  @override
  Future<Result<void>> createBook(BookEntity book) async {
    try {
      int authorId = book.authorId;
      if (authorId == 0 && book.author.isNotEmpty) {
        final existing = await _supabase.client
            .from('authors')
            .select('id')
            .eq('name', book.author)
            .maybeSingle();
        if (existing != null) {
          authorId = existing['id'];
        } else {
          final result = await _supabase.client
              .from('authors')
              .insert({'name': book.author})
              .select('id')
              .single();
          authorId = result['id'];
        }
      }
      final result = await _supabase.client
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
            'created_by': _supabase.client.auth.currentUser?.id,
          })
          .select('id')
          .single();
      final newBookId = result['id'];
      if (book.listGenre.isNotEmpty) {
        await _supabase.client.from('books_genres').insert(
          book.listGenre.map((genre) {
            return {'book_id': newBookId, 'genre_id': genre.id};
          }).toList(),
        );
      }
      if (book.listLabel.isNotEmpty) {
        await _supabase.client.from('books_labels').insert(
          book.listLabel.map((label) {
            return {'book_id': newBookId, 'label_id': label.id};
          }).toList(),
        );
      }
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al crear libro', cause: e));
    }
  }

  @override
  Future<Result<void>> updateBook(BookEntity book) async {
    try {
      await _supabase.client.from('books').update({
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
        'is_visible': book.isVisible,
      }).eq('id', book.id);
      await _supabase.client.from('books_genres').delete().eq('book_id', book.id);
      if (book.listGenre.isNotEmpty) {
        await _supabase.client.from('books_genres').insert(
          book.listGenre.map((genre) {
            return {'book_id': book.id, 'genre_id': genre.id};
          }).toList(),
        );
      }
      await _supabase.client.from('books_labels').delete().eq('book_id', book.id);
      if (book.listLabel.isNotEmpty) {
        await _supabase.client.from('books_labels').insert(
          book.listLabel.map((label) {
            return {'book_id': book.id, 'label_id': label.id};
          }).toList(),
        );
      }
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al actualizar libro', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteBook(int id) async {
    try {
      await _supabase.client.from('books').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al eliminar libro', cause: e));
    }
  }

  @override
  Future<Result<void>> toggleBookVisibility(int bookId, bool isVisible) async {
    try {
      await _supabase.client
          .from('books')
          .update({'is_visible': isVisible}).eq('id', bookId);
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al cambiar visibilidad', cause: e));
    }
  }

  @override
  Future<Result<String>> uploadCover(String filePath) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last;
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.client.storage.from('covers').upload(filename, file);
      final url = _supabase.client.storage.from('covers').getPublicUrl(filename);
      return Ok(url);
    } catch (e) {
      return Err(BookFailure('Error al subir cover', cause: e));
    }
  }

  @override
  Future<Result<Map<int, Set<int>>>> getBookLabels() async {
    try {
      final rows = await _supabase.client.from('books_labels').select();
      final map = <int, Set<int>>{};
      for (final row in rows) {
        map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
      }
      return Ok(map);
    } catch (e) {
      return Err(BookFailure('Error al obtener etiquetas de libros', cause: e));
    }
  }
}
