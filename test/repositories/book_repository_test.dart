import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_repository_impl.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
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
      tookCount: '',
      chapterCount: '',
      source: '',
      link: '',
      isFavorite: false,
      isVisible: true,
      listGenre: const [],
      listTook: const [],
      listLabel: const [],
      createdBy: null,
    ));
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();

    supabase = mockClient;

    repository = BookRepositoryImpl();

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
            'took_count': '5',
            'chapter_count': '10',
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

        final books = await repository.getBooks();

        expect(books, isA<List<BookEntity>>());
        expect(books.length, 1);
        expect(books.first.name, 'Test Book');
        verify(() => mockClient.from('books')).called(1);
      });

      test('filters visible books when onlyVisible is true', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        await repository.getBooks(onlyVisible: true);

        verify(() => mockFilter.eq('is_visible', true)).called(1);
      });

      test('throws RepositoryException on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        try {
          await repository.getBooks();
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al obtener libros'));
        }
      });
    });

    group('createBook', () {
      test('throws RepositoryException on error', () async {
        // The createBook flow with authorId=0 enters the author lookup branch
        // and calls maybeSingle(). Stub it to throw to test the error path.
        when(() => mockFilter.maybeSingle())
            .thenThrow(Exception('Insert failed'));

        expect(
          repository.createBook(BookEntity(
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
            tookCount: '',
            chapterCount: '',
            source: '',
            link: '',
            isFavorite: false,
            isVisible: true,
            listGenre: const [],
            listTook: const [],
            listLabel: const [],
            createdBy: null,
          )),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('updateBook', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        try {
          await repository.updateBook(
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
              tookCount: '',
              chapterCount: '',
              source: '',
              link: '',
              isFavorite: false,
              isVisible: true,
              listGenre: const [],
              listTook: const [],
              listLabel: const [],
              createdBy: null,
            ),
          );
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al actualizar libro'));
        }
      });
    });

    group('deleteBook', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        try {
          await repository.deleteBook(1);
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al eliminar libro'));
        }
      });
    });

    group('toggleBookVisibility', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Toggle failed'));

        try {
          await repository.toggleBookVisibility(1, true);
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al cambiar visibilidad'));
        }
      });
    });

    group('getBookLabels', () {
      test('returns map of book labels on success', () async {
        mockFilter.thenReturns([
          {'book_id': 1, 'label_id': 2},
        ] as PostgrestList);

        final result = await repository.getBookLabels();

        expect(result, {
          1: {2}
        });
      });

      test('throws RepositoryException on error', () async {
        when(() => mockQueryBuilder.select(any()))
            .thenThrow(Exception('Label query failed'));

        try {
          await repository.getBookLabels();
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al obtener etiquetas de libros'));
        }
      });
    });
  });
}
