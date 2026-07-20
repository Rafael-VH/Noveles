import 'package:noveles/core/errors/result.dart';

abstract class AnalyticsRepository {
  Future<Result<List<Map<String, dynamic>>>> getViewsTrend({int daysBack = 30});
  Future<Result<List<Map<String, dynamic>>>> getTopBooks({int limitCount = 10});
  Future<Result<Map<String, dynamic>>> getOverview();
}
