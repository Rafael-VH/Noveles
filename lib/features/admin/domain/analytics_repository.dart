import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';

abstract class AnalyticsRepository {
  Future<Result<AnalyticsOverview>> getOverview();
  Future<Result<List<AnalyticsTrendEntry>>> getViewsTrend({int daysBack = 30});
  Future<Result<List<AnalyticsTopBook>>> getTopBooks({int limitCount = 10});
}
