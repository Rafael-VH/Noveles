import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/data/genre_repository_impl.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late GenreRepositoryImpl repository;

  GenreEntity genre({
    int id = 0,
    String name = 'Fantasy',
    String description = 'Fantasy genre',
  }) =>
      GenreEntity(
        id: id,
        createdAt: DateTime(2024),
        name: name,
        description: description,
      );

  setUp(() {
    backend = FakeBackend();
    repository = GenreRepositoryImpl(backend.data);
  });

  group('GenreRepositoryImpl', () {
    group('getGenres', () {
      test('returns list of GenreEntity on success', () async {
        backend.rows('genres', [
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
        verify(() => backend.data.from('genres')).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('genres').rows())
            .thenThrow(Exception('DB error'));

        final result = await repository.getGenres();

        expect(result, isA<Err<List<GenreEntity>>>());
        final error = (result as Err<List<GenreEntity>>).error;
        expect(error.message, contains('Error al obtener géneros'));
      });
    });

    group('getGenreById', () {
      test('returns GenreEntity when found', () async {
        backend.maybeRow('genres', {
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
        backend.maybeRow('genres', null);

        final result = await repository.getGenreById(999);

        expect(result, isA<Ok<GenreEntity?>>());
        final value = (result as Ok<GenreEntity?>).value;
        expect(value, isNull);
      });

      test('returns Err on error', () async {
        when(() => backend.query('genres').eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getGenreById(1);

        expect(result, isA<Err<GenreEntity?>>());
        final error = (result as Err<GenreEntity?>).error;
        expect(error.message, contains('Error al obtener género'));
      });
    });

    group('createGenre', () {
      test('returns Ok and persists the genre', () async {
        backend.insertOk('genres');

        final result = await repository.createGenre(genre(name: 'New Genre'));

        expect(result, isA<Ok<void>>());
        final values = backend.capturedInsert('genres');
        expect(values['name'], 'New Genre');
        expect(values['created_at'], DateTime(2024).toIso8601String());
      });

      test('returns Err on error', () async {
        when(() => backend.data.insert(
              any(),
              any(),
              returning: any(named: 'returning'),
            )).thenThrow(Exception('Insert failed'));

        final result = await repository.createGenre(genre());

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al crear género'));
      });
    });

    group('updateGenre', () {
      test('returns Ok and targets the genre id', () async {
        backend.updateOk('genres');

        final result = await repository.updateGenre(
          genre(id: 1, name: 'Updated', description: 'Updated desc'),
        );

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('genres').eq('id', 1)).called(1);
        expect(backend.capturedUpdate('genres')['name'], 'Updated');
      });

      test('returns Err on error', () async {
        when(() => backend.query('genres').eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateGenre(genre(id: 1));

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al actualizar género'));
      });
    });

    group('deleteGenre', () {
      test('returns Ok and targets the genre id', () async {
        backend.deleteOk('genres');

        final result = await repository.deleteGenre(1);

        expect(result, isA<Ok<void>>());
        verify(() => backend.query('genres').eq('id', 1)).called(1);
        verify(() => backend.query('genres').delete()).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.query('genres').eq(any(), any()))
            .thenThrow(Exception('Delete failed'));

        final result = await repository.deleteGenre(1);

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al eliminar género'));
      });
    });
  });
}
