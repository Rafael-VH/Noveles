import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_state.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository mockRepository;

  final overviewData = {
    'total_views': 150,
    'views_today': 12,
    'total_books': 25,
    'visible_books': 20,
  };

  final trendData = [
    {'view_date': '2026-07-01', 'view_count': 5},
    {'view_date': '2026-07-02', 'view_count': 8},
  ];

  final topBooksData = [
    {'book_id': 1, 'book_name': 'Top Book', 'view_count': 42},
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
            .having((s) => s.overview['total_views'], 'total_views', 150)
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
