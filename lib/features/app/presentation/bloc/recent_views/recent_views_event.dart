import 'package:equatable/equatable.dart';

abstract class RecentViewsEvent extends Equatable {
  const RecentViewsEvent();

  @override
  List<Object> get props => [];
}

class LoadRecentViews extends RecentViewsEvent {
  final String userId;
  const LoadRecentViews(this.userId);

  @override
  List<Object> get props => [userId];
}
