import 'package:equatable/equatable.dart';
import 'package:noveles/features/domain/entities/entities.dart';

abstract class GenreState extends Equatable {
  @override
  List<Object> get props => [];
}

class GenreInitial extends GenreState {}

class GenreLoading extends GenreState {}

class GenreLoaded extends GenreState {
  final List<GenreEntity> genres;
  final String? message;

  GenreLoaded(this.genres, {this.message});

  @override
  List<Object> get props => [genres, message ?? ''];
}

class GenreError extends GenreState {
  final String message;

  GenreError(this.message);

  @override
  List<Object> get props => [message];
}
