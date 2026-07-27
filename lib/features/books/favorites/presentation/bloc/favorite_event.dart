import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String userId;
  final int bookId;

  const ToggleFavoriteEvent({required this.userId, required this.bookId});

  @override
  List<Object> get props => [userId, bookId];
}

class LoadFavorites extends FavoriteEvent {
  final String userId;

  const LoadFavorites({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String userId;
  final int bookId;

  const CheckFavoriteStatus({required this.userId, required this.bookId});

  @override
  List<Object> get props => [userId, bookId];
}
