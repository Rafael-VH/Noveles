import 'package:equatable/equatable.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

abstract class GenreState extends Equatable {
  const GenreState();
  @override
  List<Object> get props => [];
}

class GenreInitial extends GenreState {
  const GenreInitial();
}

class GenreLoading extends GenreState {
  const GenreLoading();
}

class GenreLoaded extends GenreState {
  final List<GenreEntity> genres;
  final String? message;

  const GenreLoaded(this.genres, {this.message});

  @override
  List<Object> get props => [genres, message ?? ''];
}

class GenreError extends GenreState {
  final String message;

  const GenreError(this.message);

  @override
  List<Object> get props => [message];
}
