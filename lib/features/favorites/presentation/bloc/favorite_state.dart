import 'package:equatable/equatable.dart';
import 'package:noveles/features/favorites/domain/favorite_entity.dart';

abstract class FavoriteState extends Equatable {
  @override
  List<Object> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<FavoriteEntity> favorites;

  FavoriteLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoriteStatusChecked extends FavoriteState {
  final bool isFavorite;

  FavoriteStatusChecked(this.isFavorite);

  @override
  List<Object> get props => [isFavorite];
}

class FavoriteToggled extends FavoriteState {
  final bool isFavorite;

  FavoriteToggled(this.isFavorite);

  @override
  List<Object> get props => [isFavorite];
}

class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError(this.message);

  @override
  List<Object> get props => [message];
}
