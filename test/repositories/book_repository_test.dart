import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_repository_impl.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock for PostgrestFilterBuilder<PostgrestList> (the type returned by
/// select(), insert(), update(), delete(), and used for eq/order/limit chains).
/// Overrides then() directly instead of stubbing it because Mocktail has
/// difficulty with methods from Future for await-able types.
// ignore: must_be_immutable
class MockFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  PostgrestList? _data;

  void thenReturns(PostgrestList data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

// ignore: must_be_immutable
class MockTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  Map<String, dynamic>? _data;

  void thenReturns(Map<String, dynamic>? data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>? value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data);
    if (result is Future<U>) return result;
    return result;
  }
}

/// Mock for PostgrestTransformBuilder<Map<String, dynamic>> — used by the
/// ".select('id').single()" chain in createBook.
// ignore: must_be_immutable
class MockMapResultBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  Map<String, dynamic>? _data;

  void thenReturns(Map<String, dynamic> data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

/// Mock for PostgrestTransformBuilder<List<Map<String, dynamic>>> — returned
/// by filterBuilder.select() before .single() is called.
// ignore: must_be_immutable
class MockSelectBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>>? _data;

  void thenReturns(List<Map<String, dynamic>> data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockGoTrueClient mockAuth;
  late MockSupabaseStorageClient mockStorage;
  late MockStorageFileApi mockStorageFileApi;
  late BookRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(BookEntity(
      id: 0,
      createdAt: DateTime(2024),
      cover: '',
      name: '',
      short: '',
      alternative: '',
      description: '',
      authorId: 0,
      author: '',
      country: '',
      state: '',
      type: '',
      release: '',
      tookCount: 0,
      chapterCount: 0,
      source: '',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenreIds: const [],
      listTookIds: const [],
      listLabelIds: const [],
      createdBy: null,
    ));
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockAuth = MockGoTrueClient();
    mockStorage = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();

    when(() => mockProvider.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockClient.storage).thenReturn(mockStorage);
    when(() => mockStorage.from(any())).thenReturn(mockStorageFileApi);

    repository = BookRepositoryImpl(mockProvider);

    // Default chain: from() → queryBuilder
    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockFilter);

    // Default chain: filter methods return filter
    when(() => mockFilter.eq(any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.filter(any(), any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.order(
          any(),
          ascending: any(named: 'ascending'),
          nullsFirst: any(named: 'nullsFirst'),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.limit(
          any(),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.range(
          any(),
          any(),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  // Uses mockFilter.thenReturns() and mockFilter.thenThrows() instead of
  // stubbing then() on the mock — Mocktail has difficulty with Future methods.

  group('BookRepositoryImpl', () {
    group('getBooks', () {
      test('returns list of BookEntity on success', () async {
        mockFilter.thenReturns([
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'cover': 'cover.jpg',
            'name': 'Test Book',
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
          }
        ]);

        final result = await repository.getBooks();

        expect(result, isA<Ok<List<BookWithRelations>>>());
        final value = (result as Ok<List<BookWithRelations>>).value;
        expect(value.length, 1);
        expect(value.first.name, 'Test Book');
        verify(() => mockClient.from('books')).called(1);
      });

      test('filters visible books when onlyVisible is true', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        await repository.getBooks(onlyVisible: true);

        verify(() => mockFilter.eq('is_visible', true)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getBooks();
        expect(result, isA<Err<List<BookWithRelations>>>());
        final error = (result as Err<List<BookWithRelations>>).error;
        expect(error.message, contains('Error al obtener libros'));
      });
    });

    group('getBookById', () {
      test('returns BookEntity when found', () async {
        // We need a MockTransformBuilder for maybeSingle
        // Override the default eq chain to support maybeSingle
        final mockTransformGetBook = MockTransformBuilder();
        when(() => mockFilter.maybeSingle()).thenAnswer((_) => mockTransformGetBook);

        mockTransformGetBook.thenReturns({
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'cover': 'cover.jpg',
          'name': 'Test Book',
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
        });

        final result = await repository.getBookById(1);

        expect(result, isA<Ok<BookWithRelations?>>());
        final value = (result as Ok<BookWithRelations?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
        expect(value.name, 'Test Book');
      });

      test('returns null when not found', () async {
        final mockTransformGetBook = MockTransformBuilder();
        when(() => mockFilter.maybeSingle()).thenAnswer((_) => mockTransformGetBook);
        mockTransformGetBook.thenReturns(null);

        final result = await repository.getBookById(999);

        expect(result, isA<Ok<BookWithRelations?>>());
        final value = (result as Ok<BookWithRelations?>).value;
        expect(value, isNull);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getBookById(1);
        expect(result, isA<Err<BookWithRelations?>>());
        final error = (result as Err<BookWithRelations?>).error;
        expect(error.message, contains('Error al obtener libro'));
      });
    });

    group('createBook', () {
      test('returns Ok on success', () async {
        // CreateBook flow with authorId=1 (existing author)
        // Stub the .select('id').single() chain
        final mockSelectBuilder = MockSelectBuilder();
        final mockSingleResult = MockMapResultBuilder();
        when(() => mockFilter.select(any())).thenAnswer((_) => mockSelectBuilder);
        when(() => mockSelectBuilder.single()).thenAnswer((_) => mockSingleResult);
        mockSingleResult.thenReturns({'id': 1});

        final result = await repository.createBook(BookEntity(
          id: 0,
          createdAt: DateTime(2024),
          cover: '',
          name: 'New Book',
          short: '',
          alternative: '',
          description: '',
          authorId: 1,
          author: 'Existing Author',
          country: '',
          state: '',
          type: '',
          release: '',
          tookCount: 0,
          chapterCount: 0,
          source: '',
          link: '',
          isFavorite: false,
          isVisible: true,
          listGenreIds: const [],
          listTookIds: const [],
          listLabelIds: const [],
          createdBy: null,
        ));

        expect(result, isA<Ok<void>>());
        verify(() => mockClient.from('books')).called(1);
      });

      test('returns Err on error', () async {
        // The createBook flow with authorId=0 enters the author lookup branch
        // and calls maybeSingle(). Stub it to throw to test the error path.
        when(() => mockFilter.maybeSingle())
            .thenThrow(Exception('Insert failed'));

        final result = await repository.createBook(BookEntity(
          id: 0,
          createdAt: DateTime(2024),
          cover: '',
          name: 'New',
          short: '',
          alternative: '',
          description: '',
          authorId: 0,
          author: 'Test Author',
          country: '',
          state: '',
          type: '',
          release: '',
          tookCount: 0,
          chapterCount: 0,
          source: '',
          link: '',
          isFavorite: false,
          isVisible: true,
          listGenreIds: const [],
          listTookIds: const [],
          listLabelIds: const [],
          createdBy: null,
        ));
        expect(result, isA<Err<void>>());
      });
    });

    group('updateBook', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);
        final result = await repository.updateBook(
          BookEntity(
            id: 1,
            createdAt: DateTime(2024),
            cover: '',
            name: 'Updated',
            short: '',
            alternative: '',
            description: '',
            authorId: 1,
            author: '',
            country: '',
            state: '',
            type: '',
            release: '',
            tookCount: 0,
            chapterCount: 0,
            source: '',
            link: '',
            isFavorite: false,
            isVisible: true,
            listGenreIds: const [],
            listTookIds: const [],
            listLabelIds: const [],
            createdBy: null,
          ),
        );
        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.update(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateBook(
          BookEntity(
            id: 1,
            createdAt: DateTime(2024),
            cover: '',
            name: 'Updated',
            short: '',
            alternative: '',
            description: '',
            authorId: 1,
            author: '',
            country: '',
            state: '',
            type: '',
            release: '',
            tookCount: 0,
            chapterCount: 0,
            source: '',
            link: '',
            isFavorite: false,
            isVisible: true,
            listGenreIds: const [],
            listTookIds: const [],
            listLabelIds: const [],
            createdBy: null,
          ),
        );
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar libro'));
      });
    });

    group('deleteBook', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);
        final result = await repository.deleteBook(1);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteBook(1);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar libro'));
      });
    });

    group('toggleBookVisibility', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);
        final result = await repository.toggleBookVisibility(1, true);

        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.update(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Toggle failed'));

        final result = await repository.toggleBookVisibility(1, true);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cambiar visibilidad'));
      });
    });

    group('uploadCover', () {
      late File tempFile;

      setUp(() async {
        tempFile = File('${Directory.systemTemp.path}/test_cover.jpg');
        await tempFile.writeAsBytes(List.filled(100, 0)); // 100 bytes dummy file
      });

      tearDown(() async {
        if (await tempFile.exists()) await tempFile.delete();
      });

      test('returns URL on success', () async {
        when(() => mockStorageFileApi.upload(
              any(),
              any(),
            )).thenAnswer((_) async => 'covers/test.jpg');
        when(() => mockStorageFileApi.getPublicUrl(any()))
            .thenReturn('https://example.com/covers/test.jpg');

        final result = await repository.uploadCover(tempFile.path);

        expect(result, isA<Ok<String>>());
        final value = (result as Ok<String>).value;
        expect(value, endsWith('.jpg'));
      });

      test('returns Err on error', () async {
        when(() => mockStorageFileApi.upload(
              any(),
              any(),
            )).thenThrow(Exception('Upload failed'));

        final result = await repository.uploadCover(tempFile.path);
        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al subir cover'));
      });
    });

    group('getBookLabels', () {
      final testBooksForLabels = [
        BookEntity(
          id: 1,
          createdAt: DateTime(2024),
          cover: '',
          name: 'Book 1',
          short: '',
          alternative: '',
          description: '',
          authorId: 1,
          author: '',
          country: '',
          state: '',
          type: '',
          release: '',
          tookCount: 0,
          chapterCount: 0,
          source: '',
          link: '',
          isFavorite: false,
          isVisible: true,
          listGenreIds: const [],
          listTookIds: const [],
          listLabelIds: const [],
          createdBy: null,
        ),
      ];

      test('returns map of book labels on success', () async {
        mockFilter.thenReturns([
          {'book_id': 1, 'label_id': 2},
        ] as PostgrestList);

        final result = await repository.getBookLabels(testBooksForLabels);
        expect(result, isA<Ok<Map<int, Set<int>>>>());
        final value = (result as Ok<Map<int, Set<int>>>).value;
        expect(value, {1: {2}});
      });

      test('returns Err on error', () async {
        when(() => mockFilter.filter(any(), any(), any()))
            .thenThrow(Exception('Label query failed'));

        final result = await repository.getBookLabels(testBooksForLabels);
        expect(result, isA<Err<Map<int, Set<int>>>>());
        final error = (result as Err<Map<int, Set<int>>>).error;
        expect(error.message, contains('Error al obtener etiquetas de libros'));
      });
    });
  });
}
