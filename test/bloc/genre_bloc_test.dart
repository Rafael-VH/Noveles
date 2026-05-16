import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/genre_bloc.dart';
import 'package:noveles/features/presentation/bloc/genre_event.dart';
import 'package:noveles/features/presentation/bloc/genre_state.dart';

class MockGetGenre extends Mock implements GetGenre {}

void main() {
  late MockGetGenre mockGetGenre;
  late GenreBloc genreBloc;

  setUp(() {
    mockGetGenre = MockGetGenre();
    genreBloc = GenreBloc(mockGetGenre);
  });

  tearDown(() {
    genreBloc.close();
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

    test('initial state is GenreInitial', () {
      expect(genreBloc.state, equals(GenreInitial()));
    });

    blocTest<GenreBloc, GenreState>(
      'emits [GenreLoading, GenreLoaded] when LoadGenres succeeds',
      build: () {
        when(() => mockGetGenre()).thenAnswer((_) async => testGenres);
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
        when(() => mockGetGenre()).thenThrow(Exception('API error'));
        return genreBloc;
      },
      act: (bloc) => bloc.add(LoadGenres()),
      expect: () => [
        isA<GenreLoading>(),
        isA<GenreError>().having((s) => s.message, 'message', contains('API error')),
      ],
    );
  });
}
