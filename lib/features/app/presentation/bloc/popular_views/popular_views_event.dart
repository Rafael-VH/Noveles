import 'package:equatable/equatable.dart';

abstract class PopularViewsEvent extends Equatable {
  const PopularViewsEvent();

  @override
  List<Object> get props => [];
}

class LoadPopularViews extends PopularViewsEvent {
  const LoadPopularViews();
}
