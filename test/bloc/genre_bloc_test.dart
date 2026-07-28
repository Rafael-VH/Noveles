import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/domain/create_genre.dart';
import 'package:noveles/features/genres/domain/update_genre.dart';
import 'package:noveles/features/genres/domain/delete_genre.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_bloc.dart';

class MockGetGenre extends Mock implements GetGenre {}

class MockCreateGenre extends Mock implements CreateGenre {}

class MockUpdateGenre extends Mock implements UpdateGenre {}

class MockDeleteGenre extends Mock implements DeleteGenre {}

void main() {
  setUpAll(() {
    registerFallbackValue(GenreEntity(
      id: 0,
      createdAt: DateTime(2024),
      name: '',
      description: '',
    ));
  });

  late MockGetGenre mockGetGenre;
  late MockCreateGenre mockCreateGenre;
  late MockUpdateGenre mockUpdateGenre;
  late MockDeleteGenre mockDeleteGenre;
  late GenreBloc genreBloc;

  setUp(() {
    mockGetGenre = MockGetGenre();
    mockCreateGenre = MockCreateGenre();
    mockUpdateGenre = MockUpdateGenre();
    mockDeleteGenre = MockDeleteGenre();
    genreBloc = GenreBloc(
      getGenre: mockGetGenre,
      createGenre: mockCreateGenre,
      updateGenre: mockUpdateGenre,
      deleteGenre: mockDeleteGenre,
    );
  });

  group('GenreBloc', () {
    final testGenres = [
      GenreEntity(
        id: 1,
        createdAt: DateTime(2024),
        name: 'Fantasy',
        description: 'Fantasy genre',
      ),
    ];

    final testGenre = GenreEntity(
      id: 2,
      createdAt: DateTime(2024),
      name: 'Sci-Fi',
      description: 'Sci-Fi genre',
    );

    test('initial state is GenreInitial', () {
      expect(genreBloc.state, equals(GenreInitial()));
      genreBloc.close();
    });

    blocTest<GenreBloc, GenreState>(
      'emits [GenreLoading, GenreLoaded] when LoadGenres succeeds',
      build: () {
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(testGenres));
        return genreBloc;
      },
      act: (bloc) => bloc.add(LoadGenres()),
      expect: () => [
        isA<GenreLoading>(),
        isA<GenreLoaded>().having((s) => s.genres, 'genres', testGenres),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits [GenreLoading, GenreError] when GetGenres fails',
      build: () {
        when(() => mockGetGenre())
            .thenAnswer((_) async => Err(GenreFailure('API error')));
        return genreBloc;
      },
      act: (bloc) => bloc.add(LoadGenres()),
      expect: () => [
        isA<GenreLoading>(),
        isA<GenreError>()
            .having((s) => s.message, 'message', contains('API error')),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreLoaded with message when CreateGenre succeeds',
      build: () {
        when(() => mockCreateGenre(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(testGenres));
        return genreBloc;
      },
      act: (bloc) => bloc.add(CreateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreLoaded>().having(
          (s) => s.message,
          'message',
          'Género creado',
        ),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreError when CreateGenre fails',
      build: () {
        when(() => mockCreateGenre(any()))
            .thenAnswer((_) async => Err(GenreFailure('Create error')));
        return genreBloc;
      },
      act: (bloc) => bloc.add(CreateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreError>().having(
          (s) => s.message,
          'message',
          contains('Create error'),
        ),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreLoaded with message when UpdateGenre succeeds',
      build: () {
        when(() => mockUpdateGenre(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(testGenres));
        return genreBloc;
      },
      act: (bloc) => bloc.add(UpdateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreLoaded>().having(
          (s) => s.message,
          'message',
          'Género actualizado',
        ),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreError when UpdateGenre fails',
      build: () {
        when(() => mockUpdateGenre(any()))
            .thenAnswer((_) async => Err(GenreFailure('Update error')));
        return genreBloc;
      },
      act: (bloc) => bloc.add(UpdateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreError>().having(
          (s) => s.message,
          'message',
          contains('Update error'),
        ),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreLoaded with message when DeleteGenre succeeds',
      build: () {
        when(() => mockDeleteGenre(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(testGenres));
        return genreBloc;
      },
      act: (bloc) => bloc.add(DeleteGenreEvent(1)),
      expect: () => [
        isA<GenreLoaded>().having(
          (s) => s.message,
          'message',
          'Género eliminado',
        ),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'emits GenreError when DeleteGenre fails',
      build: () {
        when(() => mockDeleteGenre(any()))
            .thenAnswer((_) async => Err(GenreFailure('Delete error')));
        return genreBloc;
      },
      act: (bloc) => bloc.add(DeleteGenreEvent(1)),
      expect: () => [
        isA<GenreError>().having(
          (s) => s.message,
          'message',
          contains('Delete error'),
        ),
      ],
    );

    // --- P0: mutation from GenreLoaded ---

    blocTest<GenreBloc, GenreState>(
      'CreateGenre success from GenreLoaded appends to existing genres',
      seed: () => GenreLoaded(testGenres),
      build: () {
        when(() => mockCreateGenre(any()))
            .thenAnswer((_) async => const Ok(null));
        return genreBloc;
      },
      act: (bloc) => bloc.add(CreateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreLoaded>()
            .having((s) => s.genres.length, 'genre count', 2)
            .having((s) => s.genres.first.id, 'first genre id', 1)
            .having((s) => s.genres.last.id, 'new genre id', 2)
            .having((s) => s.message, 'message', 'Género creado'),
      ],
    );

    blocTest<GenreBloc, GenreState>(
      'CreateGenre error from GenreLoaded preserves genres with error',
      seed: () => GenreLoaded(testGenres),
      build: () {
        when(() => mockCreateGenre(any()))
            .thenAnswer((_) async => Err(GenreFailure('Create error')));
        return genreBloc;
      },
      act: (bloc) => bloc.add(CreateGenreEvent(testGenre)),
      expect: () => [
        isA<GenreLoaded>()
            .having((s) => s.genres, 'genres preserved', testGenres)
            .having((s) => s.message, 'message', contains('Create error')),
      ],
    );
  });
}
