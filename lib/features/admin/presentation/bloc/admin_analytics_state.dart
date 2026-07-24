import 'package:equatable/equatable.dart';
import 'package:noveles/features/admin/domain/analytics_entities.dart';

abstract class AdminAnalyticsState extends Equatable {
  const AdminAnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AdminAnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AdminAnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AdminAnalyticsState {
  final AnalyticsOverview overview;
  final List<AnalyticsTrendEntry> trend;
  final List<AnalyticsTopBook> topBooks;

  const AnalyticsLoaded({
    required this.overview,
    required this.trend,
    required this.topBooks,
  });

  @override
  List<Object> get props => [overview, trend, topBooks];
}

class AnalyticsError extends AdminAnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
