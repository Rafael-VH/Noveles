import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/data/repositories/took_repository_impl.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

void main() {
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late TookRepositoryImpl repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();

    supabase = mockClient;

    repository = TookRepositoryImpl();

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
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('TookRepositoryImpl', () {
    group('getTooks', () {
      test('returns list of TookEntity on success', () async {
        mockFilter.thenReturns([{
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'cover': '',
          'number': '1',
          'title': 'Tomo 1',
          'chapter_count': '12',
          'book_id': 1,
          'chapters': <Map<String, dynamic>>[],
        }]);

        final tooks = await repository.getTooks();

        expect(tooks, isA<List<TookEntity>>());
        expect(tooks.length, 1);
        expect(tooks.first.title, 'Tomo 1');
        verify(() => mockClient.from('tooks')).called(1);
      });

      test('throws RepositoryException on error', () async {
        when(() => mockFilter.order(
          any(),
          ascending: any(named: 'ascending'),
          nullsFirst: any(named: 'nullsFirst'),
          referencedTable: any(named: 'referencedTable'),
        )).thenThrow(Exception('DB error'));

        try {
          await repository.getTooks();
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al obtener tomos'));
        }
      });
    });

    group('createTook', () {
      test('throws RepositoryException on error', () async {
        when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenThrow(Exception('Insert failed'));

        try {
          await repository.createTook(
            TookEntity(
              id: 0, createdAt: DateTime(2024),
              cover: '', number: '1', title: '',
              chapterCount: '', bookId: 1, listChapter: const [],
              createdBy: null,
            ),
          );
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al crear tomo'));
        }
      });
    });

    group('updateTook', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any())).thenThrow(Exception('Update failed'));

        try {
          await repository.updateTook(
            TookEntity(
              id: 1, createdAt: DateTime(2024),
              cover: '', number: '1', title: '',
              chapterCount: '', bookId: 1, listChapter: const [],
              createdBy: null,
            ),
          );
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al actualizar tomo'));
        }
      });
    });

    group('deleteTook', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any())).thenThrow(Exception('Delete failed'));

        try {
          await repository.deleteTook(1);
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al eliminar tomo'));
        }
      });
    });
  });
}
