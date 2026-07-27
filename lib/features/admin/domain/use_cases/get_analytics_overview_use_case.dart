import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';

class GetAnalyticsOverview {
  final AnalyticsRepository repository;

  GetAnalyticsOverview(this.repository);

  Future<Result<AnalyticsOverview>> call() async {
    return await repository.getOverview();
  }
}
