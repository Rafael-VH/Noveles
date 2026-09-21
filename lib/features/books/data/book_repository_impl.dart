import 'dart:io';

import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/core/constants/storage_constants.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/data/book_model.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class BookRepositoryImpl implements BookRepository {
  final DataGateway _data;
  final StorageGateway _storage;

  BookRepositoryImpl(this._data, this._storage);

  @override
  Future<Result<List<BookWithRelations>>> getBooks({
    bool onlyVisible = false,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      // Aggregate read: the relation tree is resolved by the adapter.
      final rows = await _data.booksWithRelations(
        onlyVisible: onlyVisible,
        limit: pageSize,
        offset: offset,
      );
      final books = rows.map((json) => BookModel.fromJson(json)).toList();
      return Ok(books);
    } catch (e) {
      return Err(BookFailure('Error al obtener libros', cause: e));
    }
  }

  @override
  Future<Result<BookWithRelations?>> getBookById(int id) async {
    try {
      final row = await _data.bookWithRelationsById(id);
      if (row == null) return const Ok(null);
      return Ok(BookModel.fromJson(row));
    } catch (e) {
      return Err(BookFailure('Error al obtener libro', cause: e));
    }
  }

  @override
  Future<Result<int>> createBook(BookEntity book) async {
    try {
      final bookJson = {
        'created_at': book.createdAt.toIso8601String(),
        'cover': book.cover,
        'name': book.name,
        'short': book.short,
        'alternative': book.alternative,
        'description': book.description,
        'author_id': book.authorId,
        'author': book.author,
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
        // created_by is set server-side by auth.uid() — never send from client
      };

      // Server-side function: creating a book also inserts its genres and
      // labels atomically.
      final newBookId = await _data.rpc(
        'create_book_with_relations',
        params: {
          'p_book': bookJson,
          'p_genre_ids': book.listGenreIds,
          'p_label_ids': book.listLabelIds,
        },
      ) as int;

      return Ok(newBookId);
    } catch (e) {
      return Err(BookFailure('Error al crear libro', cause: e));
    }
  }

  @override
  Future<Result<void>> updateBook(BookEntity book) async {
    try {
      final bookJson = {
        'id': book.id,
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
      };

      await _data.rpc(
        'update_book_with_relations',
        params: {
          'p_book': bookJson,
          'p_genre_ids': book.listGenreIds,
          'p_label_ids': book.listLabelIds,
        },
      );

      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al actualizar libro', cause: e));
    }
  }

  @override
  Future<Result<void>> deleteBook(int id) async {
    try {
      // 1. Get book data to know cover and tooks/chapters
      final bookData = await _data.bookContentTree(id);

      // 2. Clean up storage files
      if (bookData != null) {
        // Clean took covers
        for (final took in (bookData['tooks'] as List? ?? [])) {
          if (took['cover'] != null && (took['cover'] as String).isNotEmpty) {
            await _safeRemove(StorageConstants.coversBucket, took['cover'] as String);
          }
          // Clean chapter content files
          for (final chapter in (took['chapters'] as List? ?? [])) {
            final content = chapter['content'] as String?;
            if (content != null && content.startsWith('http')) {
              await _safeRemoveFromUrl(StorageConstants.chaptersBucket, content);
            }
          }
        }
        // Clean book cover
        final cover = bookData['cover'] as String?;
        if (cover != null && cover.isNotEmpty) {
          await _safeRemove(StorageConstants.coversBucket, cover);
        }
      }

      // 3. Delete book record (CASCADE deletes tooks, chapters, etc.)
      await _data.from('books').eq('id', id).delete();
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error al eliminar libro', cause: e));
    }
  }

  Future<void> _safeRemove(String bucket, String path) async {
    try {
      await _storage.remove(bucket, [path]);
    } catch (_) {
      // Log but don't fail — file may not exist
    }
  }

  Future<void> _safeRemoveFromUrl(String bucket, String url) async {
    try {
      // The adapter knows its own URL shape, so parsing stays out of here.
      final path = _storage.pathFromUrl(bucket, url);
      if (path != null) await _safeRemove(bucket, path);
    } catch (_) {}
  }

  @override
  Future<Result<void>> toggleBookVisibility(int bookId, bool isVisible) async {
    try {
      await _data
          .from('books')
          .eq('id', bookId)
          .update({'is_visible': isVisible});
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

      final userId = _data.identity?.id ?? 'unknown';
      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _storage.upload(StorageConstants.coversBucket, filename, file);
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
      final rows =
          await _data.from('books_labels').inList('book_id', ids).rows();
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
      await _data.insert('book_views', {
        'book_id': bookId,
        'viewed_at': DateTime.now().toUtc().toIso8601String(),
        'user_id': _data.identity?.id,
      });
      return const Ok(null);
    } catch (e) {
      return Err(BookFailure('Error tracking view', cause: e));
    }
  }

  @override
  Future<Result<List<BookWithRelations>>> getRecentViews(String userId) async {
    try {
      final ids = await _data.rpc(
        'get_user_recent_views',
        params: {'uid': userId, 'max_results': 6},
      );
      if (ids.isEmpty) return const Ok([]);
      final bookIdList = ids.map<int>((e) => e['book_id'] as int).toList();
      final rows = await _data.booksWithRelationsByIds(bookIdList);
      final books = rows.map((json) => BookModel.fromJson(json)).toList();
      return Ok(books);
    } catch (e) {
      return Err(BookFailure('Error al obtener vistas recientes', cause: e));
    }
  }

  @override
  Future<Result<List<BookWithRelations>>> getMostViewedBooks() async {
    try {
      // Public RPC for readers (visible books only). The admin-only
      // get_most_viewed_books RPC is used by the analytics dashboard.
      final ids = await _data.rpc(
        'get_most_viewed_books_public',
        params: {'max_results': 6},
      );
      if (ids.isEmpty) return const Ok([]);
      final bookIdList = ids.map<int>((e) => e['book_id'] as int).toList();
      final rows = await _data.booksWithRelationsByIds(bookIdList);
      final books = rows.map((json) => BookModel.fromJson(json)).toList();
      return Ok(books);
    } catch (e) {
      return Err(BookFailure('Error al obtener libros más vistos', cause: e));
    }
  }
}
