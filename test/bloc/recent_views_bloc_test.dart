import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/domain/get_recent_views.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_bloc.dart';

class MockGetRecentViews extends Mock implements GetRecentViews {}

void main() {
  late MockGetRecentViews mockGetRecentViews;
  late RecentViewsBloc recentViewsBloc;

  setUp(() {
    mockGetRecentViews = MockGetRecentViews();
    recentViewsBloc = RecentViewsBloc(getRecentViews: mockGetRecentViews);
  });

  group('RecentViewsBloc', () {
    const testUserId = 'test-user-id';

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

    test('initial state is RecentViewsInitial', () {
      expect(recentViewsBloc.state, equals(RecentViewsInitial()));
      recentViewsBloc.close();
    });

    blocTest<RecentViewsBloc, RecentViewsState>(
      'emits [RecentViewsLoading, RecentViewsLoaded] when LoadRecentViews succeeds with data',
      build: () {
        when(() => mockGetRecentViews(testUserId))
            .thenAnswer((_) async => Ok(testBooks));
        return recentViewsBloc;
      },
      act: (bloc) => bloc.add(LoadRecentViews(testUserId)),
      expect: () => [
        isA<RecentViewsLoading>(),
        isA<RecentViewsLoaded>().having((s) => s.books, 'books', testBooks),
      ],
    );

    blocTest<RecentViewsBloc, RecentViewsState>(
      'emits [RecentViewsLoading, RecentViewsEmpty] when result is empty',
      build: () {
        when(() => mockGetRecentViews(testUserId))
            .thenAnswer((_) async => Ok(<BookWithRelations>[]));
        return recentViewsBloc;
      },
      act: (bloc) => bloc.add(LoadRecentViews(testUserId)),
      expect: () => [
        isA<RecentViewsLoading>(),
        isA<RecentViewsEmpty>(),
      ],
    );

    blocTest<RecentViewsBloc, RecentViewsState>(
      'emits [RecentViewsLoading, RecentViewsError] when GetRecentViews fails',
      build: () {
        when(() => mockGetRecentViews(testUserId))
            .thenAnswer((_) async => Err(BookFailure('API error')));
        return recentViewsBloc;
      },
      act: (bloc) => bloc.add(LoadRecentViews(testUserId)),
      expect: () => [
        isA<RecentViewsLoading>(),
        isA<RecentViewsError>()
            .having((s) => s.message, 'message', contains('API error')),
      ],
    );
  });
}
