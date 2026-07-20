import 'dart:io';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/constants/storage_constants.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_model.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class BookRepositoryImpl implements BookRepository {
  final SupabaseClientProvider _supabase;

  BookRepositoryImpl(this._supabase);

  @override
  Future<Result<List<BookWithRelations>>> getBooks({
    bool onlyVisible = false,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final offset = (page - 1) * pageSize;

      var query = _supabase.client.from('books').select(
          '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))');

      if (onlyVisible) {
        query = query.eq('is_visible', true);
      }

      final response = await query
          .order('id')
          .limit(pageSize)
          .range(offset, offset + pageSize - 1);

      final books = response.map((json) => BookModel.fromJson(json)).toList();
      return Ok(books);
    } catch (e) {
      return Err(BookFailure('Error al obtener libros', cause: e));
    }
  }

  @override
  Future<Result<BookWithRelations?>> getBookById(int id) async {
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
  Future<Result<int>> createBook(BookEntity book) async {
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
      final newBookId = result['id'] as int;
      if (book.listGenreIds.isNotEmpty) {
        await _supabase.client.from('books_genres').insert(
              book.listGenreIds.map((genreId) {
                return {'book_id': newBookId, 'genre_id': genreId};
              }).toList(),
            );
      }
      if (book.listLabelIds.isNotEmpty) {
        await _supabase.client.from('books_labels').insert(
              book.listLabelIds.map((labelId) {
                return {'book_id': newBookId, 'label_id': labelId};
              }).toList(),
            );
      }
      return Ok(newBookId);
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
      await _supabase.client
          .from('books_genres')
          .delete()
          .eq('book_id', book.id);
      if (book.listGenreIds.isNotEmpty) {
        await _supabase.client.from('books_genres').insert(
              book.listGenreIds.map((genreId) {
                return {'book_id': book.id, 'genre_id': genreId};
              }).toList(),
            );
      }
      await _supabase.client
          .from('books_labels')
          .delete()
          .eq('book_id', book.id);
      if (book.listLabelIds.isNotEmpty) {
        await _supabase.client.from('books_labels').insert(
              book.listLabelIds.map((labelId) {
                return {'book_id': book.id, 'label_id': labelId};
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
      // 1. Get book data to know cover and tooks/chapters
      final bookData = await _supabase.client
          .from('books')
          .select('cover, tooks(chapters(content), cover)')
          .eq('id', id)
          .maybeSingle();

      // 2. Clean up storage files
      if (bookData != null) {
        // Clean took covers
        for (final took in (bookData['tooks'] as List? ?? [])) {
          if (took['cover'] != null && (took['cover'] as String).isNotEmpty) {
            await _safeDeleteStorage(StorageConstants.coversBucket, took['cover'] as String);
          }
          // Clean chapter content files
          for (final chapter in (took['chapters'] as List? ?? [])) {
            final content = chapter['content'] as String?;
            if (content != null && content.startsWith('http')) {
              await _safeDeleteStorageFromUrl(StorageConstants.chaptersBucket, content);
            }
          }
        }
        // Clean book cover
        final cover = bookData['cover'] as String?;
        if (cover != null && cover.isNotEmpty) {
          await _safeDeleteStorage(StorageConstants.coversBucket, cover);
        }
      }

      // 3. Delete book record (CASCADE deletes tooks, chapters, etc.)
      await _supabase.client.from('books').delete().eq('id', id);
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al eliminar libro', cause: e));
    }
  }

  Future<void> _safeDeleteStorage(String bucket, String path) async {
    try {
      await _supabase.client.storage.from(bucket).remove([path]);
    } catch (_) {
      // Log but don't fail — file may not exist
    }
  }

  Future<void> _safeDeleteStorageFromUrl(String bucket, String url) async {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex != -1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _safeDeleteStorage(bucket, filePath);
      }
    } catch (_) {}
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

  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  @override
  Future<Result<String>> uploadImage(String filePath) async {
    try {
      final file = File(filePath);

      // Validar tamaño
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        return Err(BookFailure(
          'El archivo es demasiado grande. Máximo: 5MB',
        ));
      }

      // Validar extensión
      final ext =
          filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!allowedExtensions.contains(ext)) {
        return Err(BookFailure(
          'Formato no permitido. Usa: JPG, PNG, o WebP',
        ));
      }

      final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.client.storage
          .from(StorageConstants.coversBucket)
          .upload(filename, file);
      return Ok(filename);
    } catch (e) {
      return Err(BookFailure('Error al subir cover', cause: e));
    }
  }

  @override
  Future<Result<Map<int, Set<int>>>> getBookLabels(
      List<BookEntity> books) async {
    try {
      if (books.isEmpty) return const Ok({});
      final ids = books.map((b) => b.id).toList();
      final rows = await _supabase.client
          .from('books_labels')
          .select()
          .filter('book_id', 'in', ids);
      final map = <int, Set<int>>{};
      for (final row in rows) {
        map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
      }
      return Ok(map);
    } catch (e) {
      return Err(BookFailure('Error al obtener etiquetas de libros', cause: e));
    }
  }

  @override
  Future<Result<void>> trackBookView(int bookId) async {
    try {
      await _supabase.client.from('book_views').insert({
        'book_id': bookId,
        'viewed_at': DateTime.now().toUtc().toIso8601String(),
        'user_id': _supabase.client.auth.currentUser?.id,
      });
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error tracking view', cause: e));
    }
  }
}
