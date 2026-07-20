import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final SupabaseClientProvider _supabase;

  AnalyticsRepositoryImpl(this._supabase);

  @override
  Future<Result<List<Map<String, dynamic>>>> getViewsTrend({
    int daysBack = 30,
  }) async {
    try {
      final response = await _supabase.client
          .rpc('get_views_trend', params: {'days_back': daysBack});
      final data = (response as List).cast<Map<String, dynamic>>();
      return Ok(data);
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching views trend', cause: e));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getTopBooks({
    int limitCount = 10,
  }) async {
    try {
      final response = await _supabase.client
          .rpc('get_top_books', params: {'limit_count': limitCount});
      final data = (response as List).cast<Map<String, dynamic>>();
      return Ok(data);
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching top books', cause: e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getOverview() async {
    try {
      final response =
          await _supabase.client.rpc('get_analytics_overview');
      final data = (response as List).first as Map<String, dynamic>;
      return Ok(data);
    } catch (e) {
      return Err(AnalyticsFailure('Error fetching analytics overview', cause: e));
    }
  }
}
