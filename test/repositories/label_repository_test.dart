import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/data/label_repository_impl.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late LabelRepositoryImpl repository;

  LabelEntity label({int id = 0, String name = 'Label 1', String color = '#FF0000'}) =>
      LabelEntity(
        id: id,
        createdAt: DateTime(2024),
        name: name,
        color: color,
      );

  setUp(() {
    backend = FakeBackend();
    repository = LabelRepositoryImpl(backend.data);
  });

  group('LabelRepositoryImpl', () {
    group('getLabels', () {
      test('returns list of LabelEntity on success', () async {
        backend.rows('labels', [
          {
            'id': 1,
            'created_at': '2024-01-01T00:00:00.000',
            'name': 'Label 1',
            'color': '#FF0000',
          },
          {
            'id': 2,
            'created_at': '2024-01-02T00:00:00.000',
            'name': 'Label 2',
            'color': '#00FF00',
          },
        ]);

        final result = await repository.getLabels();

        expect(result, isA<Ok<List<LabelEntity>>>());
        final value = (result as Ok<List<LabelEntity>>).value;
        expect(value.length, 2);
        expect(value.first.name, 'Label 1');
        expect(value.first.color, '#FF0000');
        verify(() => backend.data.from('labels')).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('labels').rows())
            .thenThrow(Exception('DB error'));

        final result = await repository.getLabels();

        expect(result, isA<Err<List<LabelEntity>>>());
        final error = (result as Err<List<LabelEntity>>).error;
        expect(error.message, contains('Error al obtener etiquetas'));
      });
    });

    group('createLabel', () {
      test('returns Ok and persists name and color', () async {
        backend.insertOk('labels');

        final result = await repository.createLabel(label(name: 'New Label'));

        expect(result, isA<Ok<void>>());
        final values = backend.capturedInsert('labels');
        expect(values['name'], 'New Label');
        expect(values['color'], '#FF0000');
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createLabel(label());

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear etiqueta'));
      });
    });

    group('updateLabel', () {
      test('returns Ok and targets the label id', () async {
        backend.updateOk('labels');

        final result = await repository.updateLabel(1, 'Updated', '#0000FF');

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('labels').eq('id', 1)).called(1);
        final values = backend.capturedUpdate('labels');
        expect(values['name'], 'Updated');
        expect(values['color'], '#0000FF');
      });

      test('returns Err on error', () async {
        when(() => backend.query('labels').eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateLabel(1, 'Updated', '#0000FF');

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar etiqueta'));
      });
    });

    group('deleteLabel', () {
      test('returns Ok on success', () async {
        backend.deleteOk('labels');

        final result = await repository.deleteLabel(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('labels').eq('id', 1)).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('labels').eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteLabel(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar etiqueta'));
      });
    });

    group('assignLabel', () {
      test('returns Ok and writes to the join table', () async {
        backend.insertOk('books_labels');

        final result = await repository.assignLabel(1, 2);

        expect(result, isA<Ok<void>>());
        final values = backend.capturedInsert('books_labels');
        expect(values, {'book_id': 1, 'label_id': 2});
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Assign failed'));

        final result = await repository.assignLabel(1, 2);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al asignar etiqueta'));
      });
    });

    group('removeLabel', () {
      test('returns Ok and filters by book and label', () async {
        backend.deleteOk('books_labels');

        final result = await repository.removeLabel(1, 2);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('books_labels').eq('book_id', 1)).called(1);
        verify(() => backend.query('books_labels').eq('label_id', 2)).called(1);
        verify(() => backend.query('books_labels').delete()).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('books_labels').eq(any(), any()))
            .thenThrow(Exception('Remove failed'));

        final result = await repository.removeLabel(1, 2);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al quitar etiqueta'));
      });
    });

    group('getBookLabels', () {
      test('returns a map of label ids per book', () async {
        backend.rows('books_labels', [
          {'book_id': 1, 'label_id': 2},
          {'book_id': 1, 'label_id': 3},
          {'book_id': 2, 'label_id': 3},
        ]);

        final result = await repository.getBookLabels([1, 2]);

        expect(result, isA<Ok<Map<int, Set<int>>>>());
        final value = (result as Ok<Map<int, Set<int>>>).value;
        expect(value, {
          1: {2, 3},
          2: {3},
        });
        verify(() => backend.query('books_labels').inList('book_id', [1, 2]))
            .called(1);
      });

      test('skips the query entirely for an empty id list', () async {
        final result = await repository.getBookLabels([]);

        expect(result, isA<Ok<Map<int, Set<int>>>>());
        expect((result as Ok<Map<int, Set<int>>>).value, isEmpty);
        verifyNever(() => backend.data.from(any()));
      });

      test('returns Err on error', () async {
        when(() => backend.query('books_labels').inList(any(), any()))
            .thenThrow(Exception('Label query failed'));

        final result = await repository.getBookLabels([1]);

        expect(result, isA<Err<Map<int, Set<int>>>>());
        final error = (result as Err<Map<int, Set<int>>>).error;
        expect(error.message, contains('Error al obtener etiquetas de libros'));
      });
    });
  });
}
