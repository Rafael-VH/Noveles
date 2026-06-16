import 'package:equatable/equatable.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

abstract class GenreEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadGenres extends GenreEvent {}

class CreateGenreEvent extends GenreEvent {
  final GenreEntity genre;
  CreateGenreEvent(this.genre);
  @override
  List<Object> get props => [genre];
}

class UpdateGenreEvent extends GenreEvent {
  final GenreEntity genre;
  UpdateGenreEvent(this.genre);
  @override
  List<Object> get props => [genre];
}

class DeleteGenreEvent extends GenreEvent {
  final int id;
  DeleteGenreEvent(this.id);
  @override
  List<Object> get props => [id];
}
