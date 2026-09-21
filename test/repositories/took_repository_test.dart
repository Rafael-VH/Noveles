import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/data/took_repository_impl.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late TookRepositoryImpl repository;

  Map<String, dynamic> tookJson({int id = 1, String title = 'Tomo 1'}) => {
        'id': id,
        'created_at': '2024-01-01T00:00:00.000',
        'cover': '',
        'number': '1',
        'title': title,
        'chapter_count': 12,
        'book_id': 1,
        'chapters': <Map<String, dynamic>>[],
      };

  TookEntity took({int id = 0, String title = 'Tomo 1', int bookId = 1}) =>
      TookEntity(
        id: id,
        createdAt: DateTime(2024),
        cover: '',
        number: '1',
        title: title,
        chapterCount: 0,
        bookId: bookId,
        listChapterIds: const [],
        createdBy: null,
      );

  setUp(() {
    backend = FakeBackend();
    repository = TookRepositoryImpl(backend.data);
  });

  group('TookRepositoryImpl', () {
    group('getTooks', () {
      test('returns list of TookEntity from the aggregate read', () async {
        when(() => backend.data.tooksWithChapters(
            limit: any(named: 'limit'))).thenAnswer((_) async => [tookJson()]);

        final result = await repository.getTooks();

        expect(result, isA<Ok<List<TookEntity>>>());
        final value = (result as Ok<List<TookEntity>>).value;
        expect(value.length, 1);
        expect(value.first.title, 'Tomo 1');
        verify(() => backend.data.tooksWithChapters(limit: 100)).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.tooksWithChapters(
            limit: any(named: 'limit'))).thenThrow(Exception('DB error'));

        final result = await repository.getTooks();

        expect(result, isA<Err<List<TookEntity>>>());
        final error = (result as Err<List<TookEntity>>).error;
        expect(error.message, contains('Error al obtener tomos'));
      });
    });

    group('getTooksByBook', () {
      test('scopes the aggregate read to the book', () async {
        when(() => backend.data.tooksWithChapters(
              bookId: any(named: 'bookId'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => [tookJson()]);

        final result = await repository.getTooksByBook(7);

        expect(result, isA<Ok<List<TookEntity>>>());
        verify(() => backend.data.tooksWithChapters(bookId: 7, limit: 100))
            .called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.tooksWithChapters(
              bookId: any(named: 'bookId'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getTooksByBook(7);

        expect(result, isA<Err<List<TookEntity>>>());
        final error = (result as Err<List<TookEntity>>).error;
        expect(error.message, contains('Error al obtener tomos del libro'));
      });
    });

    group('getTookById', () {
      test('returns TookEntity when found', () async {
        when(() => backend.data.tookWithChaptersById(1))
            .thenAnswer((_) async => tookJson());

        final result = await repository.getTookById(1);

        expect(result, isA<Ok<TookEntity?>>());
        final value = (result as Ok<TookEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
        expect(value.title, 'Tomo 1');
      });

      test('returns null when not found', () async {
        when(() => backend.data.tookWithChaptersById(999))
            .thenAnswer((_) async => null);

        final result = await repository.getTookById(999);

        expect(result, isA<Ok<TookEntity?>>());
        expect((result as Ok<TookEntity?>).value, isNull);
      });

      test('returns Err on error', () async {
        when(() => backend.data.tookWithChaptersById(any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getTookById(1);

        expect(result, isA<Err<TookEntity?>>());
        final error = (result as Err<TookEntity?>).error;
        expect(error.message, contains('Error al obtener tomo'));
      });
    });

    group('createTook', () {
      test('returns the new id and stamps ownership from the identity',
          () async {
        backend.signedInAs('user-9');
        backend.insertReturnsId('tooks', 99);

        final result = await repository.createTook(took(title: 'New Took'));

        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).value, 99);
        final values = backend.capturedInsertReturning('tooks');
        expect(values['title'], 'New Took');
        expect(values['created_by'], 'user-9');
      });

      test('sends a null owner when there is no identity', () async {
        backend.insertReturnsId('tooks', 99);

        await repository.createTook(took());

        expect(backend.capturedInsertReturning('tooks')['created_by'], isNull);
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createTook(took());

        expect(result, isA<Err<int>>());
        final error = (result as Err<int>).error;
        expect(error.message, contains('Error al crear tomo'));
      });
    });

    group('updateTook', () {
      test('returns Ok and targets the took id', () async {
        backend.updateOk('tooks');

        final result = await repository.updateTook(took(id: 1, title: 'Updated'));

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('tooks').eq('id', 1)).called(1);
        expect(backend.capturedUpdate('tooks')['title'], 'Updated');
      });

      test('returns Err on error', () async {
        when(() => backend.query('tooks').eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateTook(took(id: 1));

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar tomo'));
      });
    });

    group('deleteTook', () {
      test('returns Ok and targets the took id', () async {
        backend.deleteOk('tooks');

        final result = await repository.deleteTook(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('tooks').eq('id', 1)).called(1);
        verify(() => backend.query('tooks').delete()).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('tooks').eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteTook(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar tomo'));
      });
    });
  });
}
