import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/presentation/genre_cubit.dart';
import 'package:noveles/features/genres/presentation/genre_state.dart';

class MockGetGenre extends Mock implements GetGenre {}

void main() {
  late MockGetGenre mockGetGenre;
  late GenreCubit genreCubit;

  setUp(() {
    mockGetGenre = MockGetGenre();
    genreCubit = GenreCubit(
      getGenres: mockGetGenre,
    );
  });

  tearDown(() {
    genreCubit.close();
  });

  group('GenreCubit', () {
    test('initial state is GenreInitial', () {
      expect(genreCubit.state, equals(GenreInitial()));
    });

    blocTest<GenreCubit, GenreState>(
      'emits [GenreLoading, GenreLoaded] when loadGenres succeeds',
      build: () {
        final genres = [
          GenreEntity(
              id: 1,
              createdAt: DateTime(2024),
              name: 'Acción',
              description: ''),
          GenreEntity(
              id: 2,
              createdAt: DateTime(2024),
              name: 'Romance',
              description: ''),
        ];
        when(() => mockGetGenre()).thenAnswer((_) async => Ok(genres));
        return genreCubit;
      },
      act: (cubit) => cubit.loadGenres(),
      expect: () => [
        isA<GenreLoading>(),
        isA<GenreLoaded>()
            .having((s) => s.genres.length, 'genre count', 2)
            .having((s) => s.genres.first.name, 'first genre name', 'Acción'),
      ],
    );

    blocTest<GenreCubit, GenreState>(
      'emits [GenreLoading, GenreError] when loadGenres fails',
      build: () {
        when(() => mockGetGenre())
            .thenAnswer((_) async => Err(GenreFailure('Error de red')));
        return genreCubit;
      },
      act: (cubit) => cubit.loadGenres(),
      expect: () => [
        isA<GenreLoading>(),
        isA<GenreError>().having(
          (s) => s.message,
          'message',
          contains('Error de red'),
        ),
      ],
    );
  });
}
