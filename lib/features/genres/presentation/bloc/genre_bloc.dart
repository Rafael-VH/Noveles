import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/genres/presentation/bloc/genre_event.dart';
export 'package:noveles/features/genres/presentation/bloc/genre_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/domain/create_genre.dart';
import 'package:noveles/features/genres/domain/update_genre.dart';
import 'package:noveles/features/genres/domain/delete_genre.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_event.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_state.dart';

class GenreBloc extends Bloc<GenreEvent, GenreState> {
  final GetGenre getGenre;
  final CreateGenre createGenre;
  final UpdateGenre updateGenre;
  final DeleteGenre deleteGenre;

  GenreBloc({
    required this.getGenre,
    required this.createGenre,
    required this.updateGenre,
    required this.deleteGenre,
  }) : super(GenreInitial()) {
    on<LoadGenres>(_onLoadGenres);
    on<CreateGenreEvent>(_onCreateGenre);
    on<UpdateGenreEvent>(_onUpdateGenre);
    on<DeleteGenreEvent>(_onDeleteGenre);
  }

  Future<void> _onLoadGenres(
    LoadGenres event,
    Emitter<GenreState> emit,
  ) async {
    emit(GenreLoading());
    final result = await getGenre();
    switch (result) {
      case Ok(:final value):
        emit(GenreLoaded(value));
      case Err(:final error):
        emit(GenreError(error.message));
    }
  }

  Future<void> _onCreateGenre(
    CreateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final previousState = state;
    final createResult = await createGenre(event.genre);
    switch (createResult) {
      case Ok():
        final current = previousState is GenreLoaded
            ? previousState.genres
            : <GenreEntity>[];
        emit(GenreLoaded([...current, event.genre], message: 'Género creado'));
      case Err(:final error):
        if (previousState is GenreLoaded) {
          emit(GenreLoaded(previousState.genres, message: error.message));
        } else {
          emit(GenreError(error.message));
        }
    }
  }

  Future<void> _onUpdateGenre(
    UpdateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final previousState = state;
    final updateResult = await updateGenre(event.genre);
    switch (updateResult) {
      case Ok():
        final current = previousState is GenreLoaded
            ? previousState.genres
            : <GenreEntity>[];
        final updated =
            current.map((g) => g.id == event.genre.id ? event.genre : g).toList();
        emit(GenreLoaded(updated, message: 'Género actualizado'));
      case Err(:final error):
        if (previousState is GenreLoaded) {
          emit(GenreLoaded(previousState.genres, message: error.message));
        } else {
          emit(GenreError(error.message));
        }
    }
  }

  Future<void> _onDeleteGenre(
    DeleteGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final previousState = state;
    final deleteResult = await deleteGenre(event.id);
    switch (deleteResult) {
      case Ok():
        final current = previousState is GenreLoaded
            ? previousState.genres
            : <GenreEntity>[];
        final filtered = current.where((g) => g.id != event.id).toList();
        emit(GenreLoaded(filtered, message: 'Género eliminado'));
      case Err(:final error):
        if (previousState is GenreLoaded) {
          emit(GenreLoaded(previousState.genres, message: error.message));
        } else {
          emit(GenreError(error.message));
        }
    }
  }
}
