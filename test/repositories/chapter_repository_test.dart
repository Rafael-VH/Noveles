import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/repository_exception.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/data/repositories/chapter_repository_impl.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock for PostgrestFilterBuilder<PostgrestList>.
/// Overrides then() directly to avoid Mocktail's difficulty with Future methods.
/// Error tests use Mocktail's thenThrow on chain methods instead of going
/// through the await mechanism (which triggers zone error reporting).
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

/// Mock for PostgrestTransformBuilder<Map<String, dynamic>?> (returned by
/// maybeSingle()). Also overrides then() for await support.
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
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockTransformBuilder mockTransform;
  late ChapterRepositoryImpl repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();

    supabase = mockClient;

    repository = ChapterRepositoryImpl();

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

  group('ChapterRepositoryImpl', () {
    group('getChapters', () {
      test('returns list of ChapterEntity on success', () async {
        mockFilter.thenReturns([{
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'number': '1',
          'title': 'Chapter 1',
          'content': 'ch1.txt',
          'took_id': 1,
        }]);

        final chapters = await repository.getChapters();

        expect(chapters, isA<List<ChapterEntity>>());
        expect(chapters.length, 1);
        expect(chapters.first.title, 'Chapter 1');
        verify(() => mockClient.from('chapters')).called(1);
      });

      test('throws RepositoryException on error', () async {
        when(() => mockFilter.order(
          any(),
          ascending: any(named: 'ascending'),
          nullsFirst: any(named: 'nullsFirst'),
          referencedTable: any(named: 'referencedTable'),
        )).thenThrow(Exception('DB error'));

        try {
          await repository.getChapters();
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al obtener capítulos'));
        }
      });
    });

    group('getChapterById', () {
      test('returns ChapterEntity when found', () async {
        mockTransform.thenReturns({
          'id': 1,
          'created_at': '2024-01-01T00:00:00.000',
          'number': '1',
          'title': 'Chapter 1',
          'content': 'ch1.txt',
          'took_id': 1,
        });

        final chapter = await repository.getChapterById(1);

        expect(chapter, isNotNull);
        expect(chapter!.id, 1);
      });

      test('returns null when not found', () async {
        mockTransform.thenReturns(null);

        final chapter = await repository.getChapterById(999);

        expect(chapter, isNull);
      });

      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any())).thenThrow(Exception('DB error'));

        try {
          await repository.getChapterById(1);
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al obtener capítulo'));
        }
      });
    });

    group('createChapter', () {
      test('throws RepositoryException on error', () async {
        when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenThrow(Exception('Insert failed'));

        try {
          await repository.createChapter(
            ChapterEntity(
              id: 0, createdAt: DateTime(2024),
              number: '1', title: '', content: '', tookId: 1,
            ),
          );
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al crear capítulo'));
        }
      });
    });

    group('updateChapter', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any())).thenThrow(Exception('Update failed'));

        try {
          await repository.updateChapter(
            ChapterEntity(
              id: 1, createdAt: DateTime(2024),
              number: '1', title: '', content: '', tookId: 1,
            ),
          );
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al actualizar capítulo'));
        }
      });
    });

    group('deleteChapter', () {
      test('throws RepositoryException on error', () async {
        when(() => mockFilter.eq(any(), any())).thenThrow(Exception('Delete failed'));

        try {
          await repository.deleteChapter(1);
          fail('Expected RepositoryException');
        } on RepositoryException catch (e) {
          expect(e.message, contains('Error al eliminar capítulo'));
        }
      });
    });
  });
}
