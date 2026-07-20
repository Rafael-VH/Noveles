import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/tooks/data/took_repository_impl.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

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

/// Mock for PostgrestTransformBuilder<Map<String, dynamic>> — returned by
/// .select('id').single() chain in createTook.
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

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockTransformBuilder mockTransform;
  late MockSelectBuilder mockSelectBuilder;
  late MockMapResultBuilder mockMapResult;
  late TookRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(TookEntity(
      id: 0,
      createdAt: DateTime(2024),
      cover: '',
      number: '',
      title: '',
      chapterCount: 0,
      bookId: 0,
      listChapterIds: const [],
    ));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();
    mockSelectBuilder = MockSelectBuilder();
    mockMapResult = MockMapResultBuilder();

    when(() => mockProvider.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);

    repository = TookRepositoryImpl(mockProvider);

    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockFilter);
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
    when(() => mockFilter.maybeSingle()).thenAnswer((_) => mockTransform);
    // Mock the .select('id').single() chain for createTook
    when(() => mockFilter.select(any())).thenAnswer((_) => mockSelectBuilder);
    when(() => mockSelectBuilder.single()).thenAnswer((_) => mockMapResult);
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('TookRepositoryImpl', () {
    group('getTooks', () {
      test('returns list of TookEntity on success', () async {
        mockFilter.thenReturns([
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'cover': '',
            'number': '1',
            'title': 'Tomo 1',
            'chapter_count': 12,
            'book_id': 1,
            'chapters': <Map<String, dynamic>>[],
          }
        ]);

        final result = await repository.getTooks();

        expect(result, isA<Ok<List<TookEntity>>>());
        final value = (result as Ok<List<TookEntity>>).value;
        expect(value.length, 1);
        expect(value.first.title, 'Tomo 1');
        verify(() => mockClient.from('tooks')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getTooks();
        expect(result, isA<Err<List<TookEntity>>>());
        final error = (result as Err<List<TookEntity>>).error;
        expect(error.message, contains('Error al obtener tomos'));
      });
    });

    group('getTookById', () {
      test('returns TookEntity when found', () async {
        mockTransform.thenReturns({
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'cover': '',
          'number': '1',
          'title': 'Tomo 1',
          'chapter_count': 12,
          'book_id': 1,
          'chapters': <Map<String, dynamic>>[],
        });

        final result = await repository.getTookById(1);

        expect(result, isA<Ok<TookEntity?>>());
        final value = (result as Ok<TookEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
        expect(value.title, 'Tomo 1');
      });

      test('returns null when not found', () async {
        mockTransform.thenReturns(null);

        final result = await repository.getTookById(999);

        expect(result, isA<Ok<TookEntity?>>());
        final value = (result as Ok<TookEntity?>).value;
        expect(value, isNull);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getTookById(1);
        expect(result, isA<Err<TookEntity?>>());
        final error = (result as Err<TookEntity?>).error;
        expect(error.message, contains('Error al obtener tomo'));
      });
    });

    group('createTook', () {
      test('returns Ok with new ID on success', () async {
        // Mock the .select('id').single() chain
        mockMapResult.thenReturns({'id': 99});

        final result = await repository.createTook(
          TookEntity(
            id: 0,
            createdAt: DateTime(2024),
            cover: '',
            number: '1',
            title: 'New Took',
            chapterCount: 0,
            bookId: 1,
            listChapterIds: const [],
            createdBy: null,
          ),
        );

        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).value, 99);
        verify(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createTook(
          TookEntity(
            id: 0,
            createdAt: DateTime(2024),
            cover: '',
            number: '1',
            title: '',
            chapterCount: 0,
            bookId: 1,
            listChapterIds: const [],
            createdBy: null,
          ),
        );
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear tomo'));
      });
    });

    group('updateTook', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.updateTook(
          TookEntity(
            id: 1,
            createdAt: DateTime(2024),
            cover: '',
            number: '1',
            title: 'Updated',
            chapterCount: 0,
            bookId: 1,
            listChapterIds: const [],
            createdBy: null,
          ),
        );

        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.update(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateTook(
          TookEntity(
            id: 1,
            createdAt: DateTime(2024),
            cover: '',
            number: '1',
            title: '',
            chapterCount: 0,
            bookId: 1,
            listChapterIds: const [],
            createdBy: null,
          ),
        );
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar tomo'));
      });
    });

    group('deleteTook', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.deleteTook(1);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteTook(1);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar tomo'));
      });
    });
  });
}
