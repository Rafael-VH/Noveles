import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_state.dart';

class AdminAnalyticsBloc
    extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AdminAnalyticsBloc({required this.analyticsRepository})
      : super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    final overviewResult = await analyticsRepository.getOverview();
    switch (overviewResult) {
      case Ok(:final value):
        final overview = value;

        final trendResult = await analyticsRepository.getViewsTrend();
        switch (trendResult) {
          case Ok(:final value):
            final trend = value;

            final topBooksResult = await analyticsRepository.getTopBooks();
            switch (topBooksResult) {
              case Ok(:final value):
                emit(AnalyticsLoaded(
                  overview: overview,
                  trend: trend,
                  topBooks: value,
                ));
              case Err(:final error):
                emit(AnalyticsError(error.message));
            }
          case Err(:final error):
            emit(AnalyticsError(error.message));
        }
      case Err(:final error):
        emit(AnalyticsError(error.message));
    }
  }
}
