import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_state.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;

  final overviewData = const AnalyticsOverview(
    totalViews: 150,
    viewsToday: 12,
    totalBooks: 25,
    visibleBooks: 20,
  );

  final trendData = const [
    AnalyticsTrendEntry(viewDate: '2026-07-01', viewCount: 5),
    AnalyticsTrendEntry(viewDate: '2026-07-02', viewCount: 8),
  ];

  final topBooksData = const [
    AnalyticsTopBook(bookName: 'Top Book', viewCount: 42),
  ];

  setUp(() {
    mockRepository = MockAnalyticsRepository();
  });

  group('AdminAnalyticsBloc', () {
    test('initial state is AnalyticsInitial', () {
      final bloc = AdminAnalyticsBloc(analyticsRepository: mockRepository);
      expect(bloc.state, const AnalyticsInitial());
      bloc.close();
    });

    blocTest<AdminAnalyticsBloc, AdminAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsLoaded] when LoadAnalytics succeeds',
      build: () {
        when(() => mockRepository.getOverview())
            .thenAnswer((_) async => Ok(overviewData));
        when(() => mockRepository.getViewsTrend())
            .thenAnswer((_) async => Ok(trendData));
        when(() => mockRepository.getTopBooks())
            .thenAnswer((_) async => Ok(topBooksData));
        return AdminAnalyticsBloc(analyticsRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadAnalytics()),
      expect: () => [
        const AnalyticsLoading(),
        isA<AnalyticsLoaded>()
            .having((s) => s.overview.totalViews, 'total_views', 150)
            .having((s) => s.trend.length, 'trend count', 2)
            .having((s) => s.topBooks.length, 'top books count', 1),
      ],
    );

    blocTest<AdminAnalyticsBloc, AdminAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsError] when LoadAnalytics overview fails',
      build: () {
        when(() => mockRepository.getOverview())
            .thenAnswer((_) async => Err(AnalyticsFailure('Overview error')));
        when(() => mockRepository.getViewsTrend())
            .thenAnswer((_) async => Ok(trendData));
        when(() => mockRepository.getTopBooks())
            .thenAnswer((_) async => Ok(topBooksData));
        return AdminAnalyticsBloc(analyticsRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadAnalytics()),
      expect: () => [
        const AnalyticsLoading(),
        isA<AnalyticsError>()
            .having((s) => s.message, 'message', contains('Overview error')),
      ],
    );

    blocTest<AdminAnalyticsBloc, AdminAnalyticsState>(
      'emits [AnalyticsLoading, AnalyticsError] when LoadAnalytics trend fails',
      build: () {
        when(() => mockRepository.getOverview())
            .thenAnswer((_) async => Ok(overviewData));
        when(() => mockRepository.getViewsTrend())
            .thenAnswer((_) async => Err(AnalyticsFailure('Trend error')));
        when(() => mockRepository.getTopBooks())
            .thenAnswer((_) async => Ok(topBooksData));
        return AdminAnalyticsBloc(analyticsRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadAnalytics()),
      expect: () => [
        const AnalyticsLoading(),
        isA<AnalyticsError>()
            .having((s) => s.message, 'message', contains('Trend error')),
      ],
    );
  });
}
