import 'package:equatable/equatable.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

abstract class PopularViewsState extends Equatable {
  const PopularViewsState();

  @override
  List<Object> get props => [];
}

class PopularViewsInitial extends PopularViewsState {
  const PopularViewsInitial();
}

class PopularViewsLoading extends PopularViewsState {
  const PopularViewsLoading();
}

class PopularViewsLoaded extends PopularViewsState {
  final List<BookWithRelations> books;
  const PopularViewsLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class PopularViewsEmpty extends PopularViewsState {
  const PopularViewsEmpty();
}

class PopularViewsError extends PopularViewsState {
  final String message;
  const PopularViewsError(this.message);

  @override
  List<Object> get props => [message];
}
