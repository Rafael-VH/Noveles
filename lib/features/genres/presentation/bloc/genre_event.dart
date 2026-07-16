import 'package:equatable/equatable.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

abstract class GenreEvent extends Equatable {
  const GenreEvent();

  @override
  List<Object> get props => [];
}

class LoadGenres extends GenreEvent {
  const LoadGenres();
}

class CreateGenreEvent extends GenreEvent {
  final GenreEntity genre;
  const CreateGenreEvent(this.genre);
  @override
  List<Object> get props => [genre];
}

class UpdateGenreEvent extends GenreEvent {
  final GenreEntity genre;
  const UpdateGenreEvent(this.genre);
  @override
  List<Object> get props => [genre];
}

class DeleteGenreEvent extends GenreEvent {
  final int id;
  const DeleteGenreEvent(this.id);
  @override
  List<Object> get props => [id];
}
