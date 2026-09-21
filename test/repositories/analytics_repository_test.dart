import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/data/analytics_repository_impl.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late AnalyticsRepositoryImpl repository;

  setUp(() {
    backend = FakeBackend();
    repository = AnalyticsRepositoryImpl(backend.data);
  });

  group('AnalyticsRepositoryImpl', () {
    group('getViewsTrend', () {
      test('returns trend data on success', () async {
        when(() => backend.data.rpc('get_views_trend',
            params: any(named: 'params'))).thenAnswer((_) async => [
              {'view_date': '2026-07-01', 'view_count': 5},
            ]);

        final result = await repository.getViewsTrend();

        expect(result, isA<Ok<List<AnalyticsTrendEntry>>>());
        final value = (result as Ok<List<AnalyticsTrendEntry>>).value;
        expect(value.length, 1);
        expect(value.first.viewCount, 5);
        verify(() => backend.data.rpc('get_views_trend', params: {'days_back': 30}))
            .called(1);
      });

      test('forwards the requested window', () async {
        when(() => backend.data.rpc('get_views_trend',
            params: any(named: 'params'))).thenAnswer((_) async => []);

        await repository.getViewsTrend(daysBack: 7);

        verify(() => backend.data.rpc('get_views_trend', params: {'days_back': 7}))
            .called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc('get_views_trend',
            params: any(named: 'params'))).thenThrow(Exception('RPC error'));

        final result = await repository.getViewsTrend();

        expect(result, isA<Err<List<AnalyticsTrendEntry>>>());
      });
    });

    group('getTopBooks', () {
      test('returns top books data on success', () async {
        when(() => backend.data.rpc('get_top_books',
            params: any(named: 'params'))).thenAnswer((_) async => [
              {'book_id': 1, 'book_name': 'Book', 'view_count': 10},
            ]);

        final result = await repository.getTopBooks();

        expect(result, isA<Ok<List<AnalyticsTopBook>>>());
        final value = (result as Ok<List<AnalyticsTopBook>>).value;
        expect(value.first.bookName, 'Book');
        verify(() => backend.data.rpc('get_top_books', params: {'limit_count': 10}))
            .called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc('get_top_books',
            params: any(named: 'params'))).thenThrow(Exception('RPC error'));

        final result = await repository.getTopBooks();

        expect(result, isA<Err<List<AnalyticsTopBook>>>());
      });
    });

    group('getOverview', () {
      test('returns overview data on success', () async {
        when(() => backend.data.rpc('get_analytics_overview'))
            .thenAnswer((_) async => [
                  {
                    'total_views': 100,
                    'views_today': 5,
                    'total_books': 10,
                    'visible_books': 8,
                  },
                ]);

        final result = await repository.getOverview();

        expect(result, isA<Ok<AnalyticsOverview>>());
        final value = (result as Ok<AnalyticsOverview>).value;
        expect(value.totalViews, 100);
        expect(value.viewsToday, 5);
        verify(() => backend.data.rpc('get_analytics_overview')).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.data.rpc('get_analytics_overview'))
            .thenThrow(Exception('RPC error'));

        final result = await repository.getOverview();

        expect(result, isA<Err<AnalyticsOverview>>());
      });
    });
  });
}
