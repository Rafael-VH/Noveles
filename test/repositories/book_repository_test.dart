import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/data/book_repository_impl.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late BookRepositoryImpl repository;

  /// A row as the adapter returns it: the book plus its resolved relations.
  Map<String, dynamic> bookJson({int id = 1, String name = 'Test Book'}) => {
        'id': id,
        'created_at': '2024-01-01T00:00:00.000',
        'cover': 'cover.jpg',
        'name': name,
        'short': '',
        'alternative': '',
        'description': '',
        'author_id': 1,
        'author': 'Author',
        'country': 'JP',
        'state': 'ongoing',
        'type': 'novel',
        'release': '2024',
        'took_count': 5,
        'chapter_count': 10,
        'source': '',
        'link': '',
        'is_favorite': false,
        'is_visible': true,
        'authors': {'id': 1, 'name': 'Author', 'created_at': '2024-01-01'},
        'books_genres': <Map<String, dynamic>>[],
        'books_labels': <Map<String, dynamic>>[],
        'tooks': <Map<String, dynamic>>[],
      };

  BookEntity book({
    int id = 0,
    String name = 'Test Book',
    String cover = '',
    bool isVisible = true,
  }) =>
      BookEntity(
        id: id,
        createdAt: DateTime(2024),
        cover: cover,
        name: name,
        short: '',
        alternative: '',
        description: '',
        authorId: 1,
        author: 'Author',
        country: '',
        state: '',
        type: '',
        release: '',
        tookCount: 0,
        chapterCount: 0,
        source: '',
        link: '',
        isFavorite: false,
        isVisible: isVisible,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: const [],
        createdBy: null,
      );

  /// Stubs the aggregate read used by `getBooks`.
  void stubBooksWithRelations(List<Map<String, dynamic>> rows) =>
      when(() => backend.data.booksWithRelations(
            onlyVisible: any(named: 'onlyVisible'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => rows);

  setUp(() {
    backend = FakeBackend();
    repository = BookRepositoryImpl(backend.data, backend.storage);
  });

  group('BookRepositoryImpl', () {
    group('getBooks', () {
      test('returns list of BookWithRelations via the aggregate read', () async {
        stubBooksWithRelations([bookJson()]);

        final result = await repository.getBooks();

        expect(result, isA<Ok<List<BookWithRelations>>>());
        final value = (result as Ok<List<BookWithRelations>>).value;
        expect(value.length, 1);
        expect(value.first.name, 'Test Book');
      });

      test('forwards visibility and pagination to the backend', () async {
        stubBooksWithRelations([]);

        await repository.getBooks(onlyVisible: true, page: 3, pageSize: 10);

        verify(() => backend.data.booksWithRelations(
              onlyVisible: true,
              limit: 10,
              offset: 20,
            )).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.booksWithRelations(
              onlyVisible: any(named: 'onlyVisible'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getBooks();

        expect(result, isA<Err<List<BookWithRelations>>>());
        final error = (result as Err<List<BookWithRelations>>).error;
        expect(error.message, contains('Error al obtener libros'));
      });
    });

    group('getBookById', () {
      test('returns BookWithRelations when found', () async {
        when(() => backend.data.bookWithRelationsById(1))
            .thenAnswer((_) async => bookJson());

        final result = await repository.getBookById(1);

        expect(result, isA<Ok<BookWithRelations?>>());
        final value = (result as Ok<BookWithRelations?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
        expect(value.name, 'Test Book');
      });

      test('returns null when not found', () async {
        when(() => backend.data.bookWithRelationsById(999))
            .thenAnswer((_) async => null);

        final result = await repository.getBookById(999);

        expect(result, isA<Ok<BookWithRelations?>>());
        expect((result as Ok<BookWithRelations?>).value, isNull);
      });

      test('returns Err on error', () async {
        when(() => backend.data.bookWithRelationsById(any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getBookById(1);

        expect(result, isA<Err<BookWithRelations?>>());
        final error = (result as Err<BookWithRelations?>).error;
        expect(error.message, contains('Error al obtener libro'));
      });
    });

    group('createBook', () {
      test('routes creation through the relations function', () async {
        when(() => backend.data.rpc('create_book_with_relations',
                params: any(named: 'params')))
            .thenAnswer((_) async => 1);

        final result = await repository.createBook(book(name: 'New Book'));

        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).value, 1);
        final params = backend.capturedRpcParams('create_book_with_relations');
        expect((params['p_book'] as Map)['name'], 'New Book');
        expect(params['p_genre_ids'], isEmpty);
        expect(params['p_label_ids'], isEmpty);
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc('create_book_with_relations',
                params: any(named: 'params')))
            .thenThrow(Exception('RPC error'));

        final result = await repository.createBook(book());

        expect(result, isA<Err<int>>());
        final error = (result as Err<int>).error;
        expect(error.message, contains('Error al crear libro'));
      });
    });

    group('updateBook', () {
      test('routes the update through the relations function', () async {
        when(() => backend.data.rpc('update_book_with_relations',
                params: any(named: 'params')))
            .thenAnswer((_) async => '');

        final result = await repository.updateBook(book(id: 1, name: 'Updated'));

        expect(result, isA<Ok<void>>());
        final params = backend.capturedRpcParams('update_book_with_relations');
        expect((params['p_book'] as Map)['id'], 1);
        expect((params['p_book'] as Map)['name'], 'Updated');
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc('update_book_with_relations',
                params: any(named: 'params')))
            .thenThrow(Exception('RPC error'));

        final result = await repository.updateBook(book(id: 1));

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar libro'));
      });
    });

    group('deleteBook', () {
      test('cleans covers and storage-backed chapter content, then deletes',
          () async {
        when(() => backend.data.bookContentTree(1)).thenAnswer((_) async => {
              'cover': 'covers/test.jpg',
              'tooks': [
                {
                  'cover': 'covers/took.jpg',
                  'chapters': [
                    {
                      'content':
                          'https://cdn.example.com/chapters/content/1/ch1.pdf',
                    },
                  ],
                },
              ],
            });
        when(() => backend.storage.pathFromUrl('chapters', any()))
            .thenReturn('content/1/ch1.pdf');
        backend.removeOk();
        backend.deleteOk('books');

        final result = await repository.deleteBook(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.storage.remove('covers', ['covers/test.jpg']))
            .called(1);
        verify(() => backend.storage.remove('covers', ['covers/took.jpg']))
            .called(1);
        verify(() => backend.storage.remove('chapters', ['content/1/ch1.pdf']))
            .called(1);
        verify(() => backend.query('books').eq('id', 1)).called(1);
      });

      test('leaves inline chapter content alone', () async {
        when(() => backend.data.bookContentTree(1)).thenAnswer((_) async => {
              'cover': '',
              'tooks': [
                {
                  'cover': '',
                  'chapters': [
                    {'content': 'texto inline, no es un archivo'},
                  ],
                },
              ],
            });
        backend.removeOk();
        backend.deleteOk('books');

        final result = await repository.deleteBook(1);

        expect(result, isA<Ok<void>>());
        verifyNever(() => backend.storage.remove(any(), any()));
      });

      test('returns Ok when the book has no cover or tooks', () async {
        when(() => backend.data.bookContentTree(1)).thenAnswer((_) async => {
              'cover': '',
              'tooks': <Map<String, dynamic>>[],
            });
        backend.deleteOk('books');

        final result = await repository.deleteBook(1);

        expect(result, isA<Ok<void>>());
        verifyNever(() => backend.storage.remove(any(), any()));
      });

      test('returns Ok even when the book data is missing', () async {
        when(() => backend.data.bookContentTree(1))
            .thenAnswer((_) async => null);
        backend.deleteOk('books');

        final result = await repository.deleteBook(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('books').delete()).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.bookContentTree(any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteBook(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar libro'));
      });
    });

    group('toggleBookVisibility', () {
      test('returns Ok and writes the new flag', () async {
        backend.updateOk('books');

        final result = await repository.toggleBookVisibility(1, true);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('books').eq('id', 1)).called(1);
        expect(backend.capturedUpdate('books'), {'is_visible': true});
      });

      test('returns Err on error', () async {
        when(() => backend.query('books').eq(any(), any()))
            .thenThrow(Exception('Toggle failed'));

        final result = await repository.toggleBookVisibility(1, true);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cambiar visibilidad'));
      });
    });

    group('uploadImage', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('cover_test_');
      });

      tearDown(() => tempDir.deleteSync(recursive: true));

      File writeCover(String extension) {
        final file = File('${tempDir.path}/cover.$extension');
        file.writeAsBytesSync(List.filled(100, 0));
        return file;
      }

      test('returns the stored path on success', () async {
        backend.signedInAs('user-1');
        backend.uploadOk();

        final result = await repository.uploadImage(writeCover('jpg').path);

        expect(result, isA<Ok<String>>());
        final value = (result as Ok<String>).value;
        expect(value, startsWith('user-1/'));
        expect(value, endsWith('.jpg'));
        verify(() => backend.storage.upload('covers', value, any())).called(1);
      });

      test('returns Err for a rejected extension', () async {
        backend.signedInAs('user-1');

        final result = await repository.uploadImage(writeCover('gif').path);

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Formato no permitido'));
      });

      test('returns Err on storage error', () async {
        backend.signedInAs('user-1');
        when(() => backend.storage.upload(any(), any(), any()))
            .thenThrow(Exception('Upload failed'));

        final result = await repository.uploadImage(writeCover('jpg').path);

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al subir cover'));
      });
    });

    group('getBookLabels', () {
      test('returns a map of label ids per book', () async {
        backend.rows('books_labels', [
          {'book_id': 1, 'label_id': 2},
        ]);

        final result = await repository.getBookLabels([book(id: 1)]);

        expect(result, isA<Ok<Map<int, Set<int>>>>());
        expect((result as Ok<Map<int, Set<int>>>).value, {
          1: {2},
        });
        verify(() => backend.query('books_labels').inList('book_id', [1]))
            .called(1);
      });

      test('skips the query for an empty book list', () async {
        final result = await repository.getBookLabels([]);

        expect(result, isA<Ok<Map<int, Set<int>>>>());
        expect((result as Ok<Map<int, Set<int>>>).value, isEmpty);
        verifyNever(() => backend.data.from(any()));
      });

      test('returns Err on error', () async {
        when(() => backend.query('books_labels').inList(any(), any()))
            .thenThrow(Exception('Label query failed'));

        final result = await repository.getBookLabels([book(id: 1)]);

        expect(result, isA<Err<Map<int, Set<int>>>>());
        final error = (result as Err<Map<int, Set<int>>>).error;
        expect(error.message, contains('Error al obtener etiquetas de libros'));
      });
    });

    group('trackBookView', () {
      test('returns Ok and records the view', () async {
        backend.insertOk('book_views');

        final result = await repository.trackBookView(42);

        expect(result, isA<Ok<void>>());
        final values = backend.capturedInsert('book_views');
        expect(values['book_id'], 42);
        expect(values['user_id'], isNull);
      });

      test('attributes the view to the reader when signed in', () async {
        backend.signedInAs('user-7');
        backend.insertOk('book_views');

        await repository.trackBookView(42);

        expect(backend.capturedInsert('book_views')['user_id'], 'user-7');
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.trackBookView(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error tracking view'));
      });
    });

    group('getRecentViews', () {
      test('resolves the returned ids through the aggregate read', () async {
        when(() => backend.data.rpc('get_user_recent_views',
            params: any(named: 'params'))).thenAnswer((_) async => [
              {'book_id': 1},
              {'book_id': 2},
            ]);
        when(() => backend.data.booksWithRelationsByIds([1, 2]))
            .thenAnswer((_) async => [bookJson(name: 'Recent Book 1')]);

        final result = await repository.getRecentViews('user1');

        expect(result, isA<Ok<List<BookWithRelations>>>());
        final value = (result as Ok<List<BookWithRelations>>).value;
        expect(value.length, 1);
        expect(value.first.name, 'Recent Book 1');
        verify(() => backend.data.rpc('get_user_recent_views',
            params: {'uid': 'user1', 'max_results': 6})).called(1);
      });

      test('returns an empty list when the function returns no ids', () async {
        when(() => backend.data.rpc('get_user_recent_views',
            params: any(named: 'params'))).thenAnswer((_) async => []);

        final result = await repository.getRecentViews('user1');

        expect(result, isA<Ok<List<BookWithRelations>>>());
        expect((result as Ok<List<BookWithRelations>>).value, isEmpty);
        verifyNever(() => backend.data.booksWithRelationsByIds(any()));
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc(any(), params: any(named: 'params')))
            .thenThrow(Exception('RPC failed'));

        final result = await repository.getRecentViews('user1');

        expect(result, isA<Err<List<BookWithRelations>>>());
        final error = (result as Err<List<BookWithRelations>>).error;
        expect(error.message, contains('Error al obtener vistas recientes'));
      });
    });

    group('getMostViewedBooks', () {
      test('uses the reader-facing function', () async {
        when(() => backend.data.rpc('get_most_viewed_books_public',
            params: any(named: 'params'))).thenAnswer((_) async => [
              {'book_id': 3},
            ]);
        when(() => backend.data.booksWithRelationsByIds([3]))
            .thenAnswer((_) async => [bookJson(id: 3, name: 'Popular Book')]);

        final result = await repository.getMostViewedBooks();

        expect(result, isA<Ok<List<BookWithRelations>>>());
        final value = (result as Ok<List<BookWithRelations>>).value;
        expect(value.length, 1);
        expect(value.first.name, 'Popular Book');
        verify(() => backend.data.rpc('get_most_viewed_books_public',
            params: {'max_results': 6})).called(1);
      });

      test('returns an empty list when the function returns no ids', () async {
        when(() => backend.data.rpc('get_most_viewed_books_public',
            params: any(named: 'params'))).thenAnswer((_) async => []);

        final result = await repository.getMostViewedBooks();

        expect(result, isA<Ok<List<BookWithRelations>>>());
        expect((result as Ok<List<BookWithRelations>>).value, isEmpty);
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc(any(), params: any(named: 'params')))
            .thenThrow(Exception('RPC failed'));

        final result = await repository.getMostViewedBooks();

        expect(result, isA<Err<List<BookWithRelations>>>());
        final error = (result as Err<List<BookWithRelations>>).error;
        expect(error.message, contains('Error al obtener libros más vistos'));
      });
    });
  });
}
