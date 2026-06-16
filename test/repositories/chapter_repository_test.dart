import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/chapters/data/chapter_repository_impl.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

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

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockTransformBuilder mockTransform;
  late MockGoTrueClient mockAuth;
  late MockSupabaseStorageClient mockStorage;
  late MockStorageFileApi mockStorageFileApi;
  late ChapterRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ChapterEntity(
      id: 0,
      createdAt: DateTime(2024),
      number: '',
      title: '',
      content: '',
      tookId: 0,
    ));
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();
    mockAuth = MockGoTrueClient();
    mockStorage = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();

    when(() => mockProvider.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockClient.storage).thenReturn(mockStorage);
    when(() => mockStorage.from(any())).thenReturn(mockStorageFileApi);

    repository = ChapterRepositoryImpl(mockProvider);

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
        mockFilter.thenReturns([
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'number': '1',
            'title': 'Chapter 1',
            'content': 'ch1.txt',
            'took_id': 1,
          }
        ]);

        final result = await repository.getChapters();

        expect(result, isA<Ok<List<ChapterEntity>>>());
        final value = (result as Ok<List<ChapterEntity>>).value;
        expect(value.length, 1);
        expect(value.first.title, 'Chapter 1');
        verify(() => mockClient.from('chapters')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getChapters();
        expect(result, isA<Err<List<ChapterEntity>>>());
        final error = (result as Err<List<ChapterEntity>>).error;
        expect(error.message, contains('Error al obtener capítulos'));
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

        final result = await repository.getChapterById(1);

        expect(result, isA<Ok<ChapterEntity?>>());
        final value = (result as Ok<ChapterEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
      });

      test('returns null when not found', () async {
        mockTransform.thenReturns(null);

        final result = await repository.getChapterById(999);

        expect(result, isA<Ok<ChapterEntity?>>());
        final value = (result as Ok<ChapterEntity?>).value;
        expect(value, isNull);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getChapterById(1);
        expect(result, isA<Err<ChapterEntity?>>());
        final error = (result as Err<ChapterEntity?>).error;
        expect(error.message, contains('Error al obtener capítulo'));
      });
    });

    group('createChapter', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.createChapter(
          ChapterEntity(
            id: 0,
            createdAt: DateTime(2024),
            number: '1',
            title: 'New Chapter',
            content: '',
            tookId: 1,
            createdBy: null,
          ),
        );

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

        final result = await repository.createChapter(
          ChapterEntity(
            id: 0,
            createdAt: DateTime(2024),
            number: '1',
            title: '',
            content: '',
            tookId: 1,
            createdBy: null,
          ),
        );
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear capítulo'));
      });
    });

    group('updateChapter', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.updateChapter(
          ChapterEntity(
            id: 1,
            createdAt: DateTime(2024),
            number: '1',
            title: 'Updated',
            content: '',
            tookId: 1,
            createdBy: null,
          ),
        );

        expect(result, isA<Ok<void>>());
        verify(() => mockQueryBuilder.update(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateChapter(
          ChapterEntity(
            id: 1,
            createdAt: DateTime(2024),
            number: '1',
            title: '',
            content: '',
            tookId: 1,
            createdBy: null,
          ),
        );
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar capítulo'));
      });
    });

    group('deleteChapter', () {
      test('returns Ok on success', () async {
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.deleteChapter(1);

        expect(result, isA<Ok<void>>());
        verify(() => mockFilter.eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteChapter(1);
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar capítulo'));
      });
    });

    group('downloadContent', () {
      test('returns path as-is when not a storage path', () async {
        final result = await repository.downloadContent('inline text');

        expect(result, isA<Ok<String>>());
        final value = (result as Ok<String>).value;
        expect(value, 'inline text');
      });

      test('returns Err on storage download error', () async {
        when(() => mockStorageFileApi.download(
              any(),
              transform: any(named: 'transform'),
              queryParams: any(named: 'queryParams'),
            )).thenThrow(Exception('Download failed'));

        final result = await repository.downloadContent('ch1.txt');

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al descargar contenido'));
      });
    });
  });
}
