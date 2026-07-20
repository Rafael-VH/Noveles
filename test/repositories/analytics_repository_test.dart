import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/admin/data/analytics_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock
    implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock for the RPC call which returns PostgrestFilterBuilder
// ignore: must_be_immutable
class MockRpcFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {
  dynamic _data;

  void thenReturns(dynamic data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(dynamic value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data);
    if (result is Future<U>) return result;
    return result;
  }
}

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late AnalyticsRepositoryImpl repository;

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    when(() => mockProvider.client).thenReturn(mockClient);
    repository = AnalyticsRepositoryImpl(mockProvider);
  });

  group('AnalyticsRepositoryImpl', () {
    group('getViewsTrend', () {
      test('returns trend data on success', () async {
        final mockBuilder = MockRpcFilterBuilder();
        when(() => mockClient.rpc('get_views_trend',
                params: any(named: 'params')))
            .thenAnswer((_) => mockBuilder);
        mockBuilder.thenReturns([
          {'view_date': '2026-07-01', 'view_count': 5},
        ]);

        final result = await repository.getViewsTrend();

        expect(result, isA<Ok<List<Map<String, dynamic>>>>());
        final value = (result as Ok<List<Map<String, dynamic>>>).value;
        expect(value.length, 1);
        expect(value.first['view_count'], 5);
      });

      test('returns Err on error', () async {
        when(() => mockClient.rpc('get_views_trend',
                params: any(named: 'params')))
            .thenThrow(Exception('RPC error'));

        final result = await repository.getViewsTrend();
        expect(result, isA<Err<List<Map<String, dynamic>>>>());
      });
    });

    group('getTopBooks', () {
      test('returns top books data on success', () async {
        final mockBuilder = MockRpcFilterBuilder();
        when(() => mockClient.rpc('get_top_books',
                params: any(named: 'params')))
            .thenAnswer((_) => mockBuilder);
        mockBuilder.thenReturns([
          {'book_id': 1, 'book_name': 'Book', 'view_count': 10},
        ]);

        final result = await repository.getTopBooks();

        expect(result, isA<Ok<List<Map<String, dynamic>>>>());
        final value = (result as Ok<List<Map<String, dynamic>>>).value;
        expect(value.first['book_name'], 'Book');
      });

      test('returns Err on error', () async {
        when(() => mockClient.rpc('get_top_books',
                params: any(named: 'params')))
            .thenThrow(Exception('RPC error'));

        final result = await repository.getTopBooks();
        expect(result, isA<Err<List<Map<String, dynamic>>>>());
      });
    });

    group('getOverview', () {
      test('returns overview data on success', () async {
        final mockBuilder = MockRpcFilterBuilder();
        when(() => mockClient.rpc('get_analytics_overview'))
            .thenAnswer((_) => mockBuilder);
        mockBuilder.thenReturns([
          {
            'total_views': 100,
            'views_today': 5,
            'total_books': 10,
            'visible_books': 8,
          },
        ]);

        final result = await repository.getOverview();

        expect(result, isA<Ok<Map<String, dynamic>>>());
        final value = (result as Ok<Map<String, dynamic>>).value;
        expect(value['total_views'], 100);
        expect(value['views_today'], 5);
      });

      test('returns Err on error', () async {
        when(() => mockClient.rpc('get_analytics_overview'))
            .thenThrow(Exception('RPC error'));

        final result = await repository.getOverview();
        expect(result, isA<Err<Map<String, dynamic>>>());
      });
    });
  });
}
