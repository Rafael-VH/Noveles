import 'package:equatable/equatable.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class RecentViewsState extends Equatable {
  const RecentViewsState();

  @override
  List<Object> get props => [];
}

class RecentViewsInitial extends RecentViewsState {
  const RecentViewsInitial();
}

class RecentViewsLoading extends RecentViewsState {
  const RecentViewsLoading();
}

class RecentViewsLoaded extends RecentViewsState {
  final List<BookWithRelations> books;
  const RecentViewsLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class RecentViewsEmpty extends RecentViewsState {
  const RecentViewsEmpty();
}

class RecentViewsError extends RecentViewsState {
  final String message;
  const RecentViewsError(this.message);

  @override
  List<Object> get props => [message];
}
