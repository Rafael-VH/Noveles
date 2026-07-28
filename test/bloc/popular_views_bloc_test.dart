import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_most_viewed_books.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_bloc.dart';

class MockGetMostViewedBooks extends Mock implements GetMostViewedBooks {}

void main() {
  late MockGetMostViewedBooks mockGetMostViewedBooks;
  late PopularViewsBloc popularViewsBloc;

  setUp(() {
    mockGetMostViewedBooks = MockGetMostViewedBooks();
    popularViewsBloc = PopularViewsBloc(getMostViewedBooks: mockGetMostViewedBooks);
  });

  group('PopularViewsBloc', () {
    final testBooks = [
      BookWithRelations(
        id: 1,
        createdAt: DateTime(2024),
        cover: 'cover1.jpg',
        name: 'Test Book',
        short: 'Short description',
        alternative: '',
        description: 'Full description',
        authorId: 1,
        author: 'Test Author',
        country: 'JP',
        state: 'ongoing',
        type: 'novel',
        release: '2024',
        tookCount: 5,
        chapterCount: 50,
        source: 'source',
        link: '',
        isFavorite: false,
        isVisible: true,
        listGenreIds: const [],
        listTookIds: const [],
        listLabelIds: const [],
      ),
    ];

    test('initial state is PopularViewsInitial', () {
      expect(popularViewsBloc.state, equals(PopularViewsInitial()));
      popularViewsBloc.close();
    });

    blocTest<PopularViewsBloc, PopularViewsState>(
      'emits [PopularViewsLoading, PopularViewsLoaded] when LoadPopularViews succeeds with data',
      build: () {
        when(() => mockGetMostViewedBooks())
            .thenAnswer((_) async => Ok(testBooks));
        return popularViewsBloc;
      },
      act: (bloc) => bloc.add(LoadPopularViews()),
      expect: () => [
        isA<PopularViewsLoading>(),
        isA<PopularViewsLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<PopularViewsBloc, PopularViewsState>(
      'emits [PopularViewsLoading, PopularViewsEmpty] when result is empty',
      build: () {
        when(() => mockGetMostViewedBooks())
            .thenAnswer((_) async => Ok(<BookWithRelations>[]));
        return popularViewsBloc;
      },
      act: (bloc) => bloc.add(LoadPopularViews()),
      expect: () => [
        isA<PopularViewsLoading>(),
        isA<PopularViewsEmpty>(),
      ],
    );

    blocTest<PopularViewsBloc, PopularViewsState>(
      'emits [PopularViewsLoading, PopularViewsError] when GetMostViewedBooks fails',
      build: () {
        when(() => mockGetMostViewedBooks())
            .thenAnswer((_) async => Err(BookFailure('API error')));
        return popularViewsBloc;
      },
      act: (bloc) => bloc.add(LoadPopularViews()),
      expect: () => [
        isA<PopularViewsLoading>(),
        isA<PopularViewsError>()
            .having((s) => s.message, 'message', contains('API error')),
      ],
    );
  });
}
