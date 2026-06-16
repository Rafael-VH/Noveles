import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/genres/data/genre_repository_impl.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

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

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockTransformBuilder mockTransform;
  late GenreRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(GenreEntity(
      id: 0,
      createdAt: DateTime(2024),
      name: '',
      description: '',
    ));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();

    when(() => mockProvider.client).thenReturn(mockClient);

    repository = GenreRepositoryImpl(mockProvider);

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
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('GenreRepositoryImpl', () {
    group('getGenres', () {
      test('returns list of GenreEntity on success', () async {
        mockFilter.thenReturns([
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'name': 'Fantasy',
            'description': 'Fantasy genre',
          },
          {
            'id': 2,
            'created_at': '2024-01-02T00:00:00.000',
            'name': 'Sci-Fi',
            'description': 'Science fiction',
          },
        ]);

        final result = await repository.getGenres();

        expect(result, isA<Ok<List<GenreEntity>>>());
        final value = (result as Ok<List<GenreEntity>>).value;
        expect(value.length, 2);
        expect(value.first.name, 'Fantasy');
        verify(() => mockClient.from('genres')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getGenres();
        expect(result, isA<Err<List<GenreEntity>>>());
        final error = (result as Err<List<GenreEntity>>).error;
        expect(error.message, contains('Error al obtener géneros'));
      });
    });

    group('getGenreById', () {
      test('returns GenreEntity when found', () async {
        mockTransform.thenReturns({
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'name': 'Fantasy',
          'description': 'Fantasy genre',
        });

        final result = await repository.getGenreById(1);

        expect(result, isA<Ok<GenreEntity?>>());
        final value = (result as Ok<GenreEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
        expect(value.name, 'Fantasy');
      });

      test('returns null when not found', () async {
        mockTransform.thenReturns(null);

        final result = await repository.getGenreById(999);

        expect(result, isA<Ok<GenreEntity?>>());
        final value = (result as Ok<GenreEntity?>).value;
        expect(value, isNull);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getGenreById(1);
        expect(result, isA<Err<GenreEntity?>>());
        final error = (result as Err<GenreEntity?>).error;
        expect(error.message, contains('Error al obtener género'));
      });
    });

    group('createGenre', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.createGenre(GenreEntity(
          id: 0,
          createdAt: DateTime(2024),
          name: 'New Genre',
          description: 'Description',
        ));

        expect(result, isA<Ok<void>>());
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

        final result = await repository.createGenre(GenreEntity(
          id: 0,
          createdAt: DateTime(2024),
          name: 'New Genre',
          description: 'Description',
        ));
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear género'));
      });
    });

    group('updateGenre', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.updateGenre(GenreEntity(
          id: 1,
          createdAt: DateTime(2024),
          name: 'Updated',
          description: 'Updated desc',
        ));

        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.update(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateGenre(GenreEntity(
          id: 1,
          createdAt: DateTime(2024),
          name: 'Updated',
          description: 'Updated desc',
        ));
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar género'));
      });
    });

    group('deleteGenre', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.deleteGenre(1);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteGenre(1);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar género'));
      });
    });
  });
}
