import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final DataGateway _data;

  AnalyticsRepositoryImpl(this._data);

  @override
  Future<Result<AnalyticsOverview>> getOverview() async {
    try {
      final response = await _data.rpc('get_analytics_overview');
      final data = (response as List).first as Map<String, dynamic>;
      return Ok(AnalyticsOverview.fromJson(data));
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching analytics overview', cause: e));
    }
  }

  @override
  Future<Result<List<AnalyticsTrendEntry>>> getViewsTrend({
    int daysBack = 30,
  }) async {
    try {
      final response = await _data.rpc('get_views_trend', params: {'days_back': daysBack});
      final data = (response as List)
          .map((e) => AnalyticsTrendEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Ok(data);
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching views trend', cause: e));
    }
  }

  @override
  Future<Result<List<AnalyticsTopBook>>> getTopBooks({
    int limitCount = 10,
  }) async {
    try {
      final response = await _data.rpc('get_top_books', params: {'limit_count': limitCount});
      final data = (response as List)
          .map((e) => AnalyticsTopBook.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Ok(data);
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching top books', cause: e));
    }
  }
}
