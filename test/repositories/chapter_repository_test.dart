import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/data/chapter_repository_impl.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late ChapterRepositoryImpl repository;

  Map<String, dynamic> chapterJson({int id = 1, String title = 'Chapter 1'}) => {
        'id': id,
        'created_at': '2024-01-01T00:00:00.000',
        'number': '1',
        'title': title,
        'content': 'ch1.txt',
        'took_id': 1,
      };

  ChapterEntity chapter({
    int id = 0,
    String title = 'Chapter 1',
    String content = '',
    ChapterContentType contentType = ChapterContentType.storagePath,
  }) =>
      ChapterEntity(
        id: id,
        createdAt: DateTime(2024),
        number: '1',
        title: title,
        content: content,
        tookId: 1,
        createdBy: null,
        contentType: contentType,
      );

  setUp(() {
    backend = FakeBackend();
    repository = ChapterRepositoryImpl(backend.data, backend.storage);
  });

  group('ChapterRepositoryImpl', () {
    group('getChapters', () {
      test('returns list of ChapterEntity on success', () async {
        backend.rows('chapters', [chapterJson()]);

        final result = await repository.getChapters();

        expect(result, isA<Ok<List<ChapterEntity>>>());
        final value = (result as Ok<List<ChapterEntity>>).value;
        expect(value.length, 1);
        expect(value.first.title, 'Chapter 1');
        verify(() => backend.data.from('chapters')).called(1);
      });

      test('pages with an explicit range', () async {
        backend.rows('chapters', []);

        await repository.getChapters(page: 3, pageSize: 10);

        verify(() => backend.query('chapters').range(20, 29)).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('chapters').rows())
            .thenThrow(Exception('DB error'));

        final result = await repository.getChapters();

        expect(result, isA<Err<List<ChapterEntity>>>());
        final error = (result as Err<List<ChapterEntity>>).error;
        expect(error.message, contains('Error al obtener capítulos'));
      });
    });

    group('getChapterById', () {
      test('returns ChapterEntity when found', () async {
        backend.maybeRow('chapters', chapterJson());

        final result = await repository.getChapterById(1);

        expect(result, isA<Ok<ChapterEntity?>>());
        final value = (result as Ok<ChapterEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 1);
      });

      test('returns null when not found', () async {
        backend.maybeRow('chapters', null);

        final result = await repository.getChapterById(999);

        expect(result, isA<Ok<ChapterEntity?>>());
        expect((result as Ok<ChapterEntity?>).value, isNull);
      });

      test('returns Err on error', () async {
        when(() => backend.query('chapters').eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getChapterById(1);

        expect(result, isA<Err<ChapterEntity?>>());
        final error = (result as Err<ChapterEntity?>).error;
        expect(error.message, contains('Error al obtener capítulo'));
      });
    });

    group('createChapter', () {
      test('returns the new id and asks for it back', () async {
        backend.insertReturnsId('chapters', 42);

        final result = await repository.createChapter(
          chapter(title: 'New Chapter'),
        );

        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).value, 42);
        verify(() => backend.data.insert('chapters', any(), returning: 'id'))
            .called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createChapter(chapter());

        expect(result, isA<Err<int>>());
        final error = (result as Err<int>).error;
        expect(error.message, contains('Error al crear capítulo'));
      });

      test('persists content_type inline', () async {
        backend.insertReturnsId('chapters', 7);

        await repository.createChapter(chapter(
          title: 'Capítulo inline',
          content: 'texto directo',
          contentType: ChapterContentType.inline,
        ));

        final values = backend.capturedInsertReturning('chapters');
        expect(values['content_type'], 'inline');
        expect(values['content'], 'texto directo');
      });

      test('defaults content_type to storagePath', () async {
        backend.insertReturnsId('chapters', 8);

        await repository.createChapter(chapter(content: 'userId/123.txt'));

        final values = backend.capturedInsertReturning('chapters');
        expect(values['content_type'], 'storagePath');
      });

      test('stamps ownership from the acting identity', () async {
        backend.signedInAs('user-3');
        backend.insertReturnsId('chapters', 9);

        await repository.createChapter(chapter());

        expect(backend.capturedInsertReturning('chapters')['created_by'],
            'user-3');
      });
    });

    group('updateChapter', () {
      test('returns Ok and targets the chapter id', () async {
        backend.updateOk('chapters');

        final result = await repository.updateChapter(
          chapter(id: 1, title: 'Updated'),
        );

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('chapters').eq('id', 1)).called(1);
        expect(backend.capturedUpdate('chapters')['title'], 'Updated');
      });

      test('persists content_type', () async {
        backend.updateOk('chapters');

        final result = await repository.updateChapter(chapter(
          id: 1,
          title: 'Capítulo inline',
          content: 'texto directo',
          contentType: ChapterContentType.inline,
        ));

        expect(result, isA<Ok<void>>());
        expect(backend.capturedUpdate('chapters')['content_type'], 'inline');
      });

      test('returns Err on error', () async {
        when(() => backend.query('chapters').eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateChapter(chapter(id: 1));

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar capítulo'));
      });
    });

    group('deleteChapter', () {
      test('returns Ok on success', () async {
        backend.deleteOk('chapters');

        final result = await repository.deleteChapter(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('chapters').eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('chapters').eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteChapter(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar capítulo'));
      });
    });

    group('downloadContent', () {
      test('returns inline content verbatim without touching storage',
          () async {
        final result = await repository.downloadContent(
          'Hello world',
          contentType: ChapterContentType.inline,
        );

        expect(result, isA<Ok<String>>());
        expect((result as Ok<String>).value, 'Hello world');
        verifyNever(() => backend.storage.download(any(), any()));
      });

      test('reads storage for a storagePath chapter', () async {
        when(() => backend.storage.download('chapters', any()))
            .thenAnswer((_) async => [72, 105]);

        final result = await repository.downloadContent(
          'ch1.txt',
          contentType: ChapterContentType.storagePath,
        );

        expect(result, isA<Ok<String>>());
        expect((result as Ok<String>).value, 'Hi');
      });

      test('defaults to the storagePath branch', () async {
        when(() => backend.storage.download('chapters', any()))
            .thenAnswer((_) async => [72]);

        final result = await repository.downloadContent('ch1.txt');

        expect(result, isA<Ok<String>>());
        verify(() => backend.storage.download('chapters', 'ch1.txt')).called(1);
      });

      test('returns Err on storage download error', () async {
        when(() => backend.storage.download(any(), any()))
            .thenThrow(Exception('Download failed'));

        final result = await repository.downloadContent(
          'ch1.txt',
          contentType: ChapterContentType.storagePath,
        );

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al descargar contenido'));
      });
    });

    group('markChapterAsRead', () {
      test('returns Ok and records the reader', () async {
        backend.insertOk('chapter_reads');

        final result = await repository.markChapterAsRead(1, 'user1');

        expect(result, isA<Ok<void>>());
        final values = backend.capturedInsert('chapter_reads');
        expect(values['chapter_id'], 1);
        expect(values['user_id'], 'user1');
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.markChapterAsRead(1, 'user1');

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al marcar capítulo como leído'));
      });
    });

    group('getReadChapterIds', () {
      test('scopes the read chapters of a took to the current user', () async {
        backend.rows('chapters', [
          {'id': 10},
          {'id': 11},
        ]);
        backend.rows('chapter_reads', [
          {'chapter_id': 10},
        ]);

        final result = await repository.getReadChapterIds(5, 'user1');

        expect(result, isA<Ok<Set<int>>>());
        expect((result as Ok<Set<int>>).value, {10});
        verify(() => backend.query('chapters').eq('took_id', 5)).called(1);
        verify(() => backend.query('chapter_reads').inList('chapter_id', [10, 11]))
            .called(1);
      });

      test('skips the second read when the took has no chapters', () async {
        backend.rows('chapters', []);

        final result = await repository.getReadChapterIds(999, 'user1');

        expect(result, isA<Ok<Set<int>>>());
        expect((result as Ok<Set<int>>).value, isEmpty);
        verifyNever(() => backend.data.from('chapter_reads'));
      });

      test('returns Err on error', () async {
        when(() => backend.query('chapters').eq(any(), any()))
            .thenThrow(Exception('Query failed'));

        final result = await repository.getReadChapterIds(1, 'user1');

        expect(result, isA<Err<Set<int>>>());
        final error = (result as Err<Set<int>>).error;
        expect(error.message, contains('Error al obtener capítulos leídos'));
      });
    });
  });
}
