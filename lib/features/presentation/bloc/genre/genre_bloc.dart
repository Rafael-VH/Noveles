import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/domain/create_genre.dart';
import 'package:noveles/features/genres/domain/update_genre.dart';
import 'package:noveles/features/genres/domain/delete_genre.dart';
import 'package:noveles/features/presentation/bloc/genre/genre_event.dart';
import 'package:noveles/features/presentation/bloc/genre/genre_state.dart';

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
        NotificationService.error('Error al cargar géneros: ${error.message}');
    }
  }

  Future<void> _onCreateGenre(
    CreateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final createResult = await createGenre(event.genre);
    switch (createResult) {
      case Ok():
        final genresResult = await getGenre();
        switch (genresResult) {
          case Ok(:final value):
            emit(GenreLoaded(value, message: 'Género creado'));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar la lista: ${error.message}');
        }
      case Err(:final error):
        emit(GenreError(error.message));
        NotificationService.error('Error al crear el género: ${error.message}');
    }
  }

  Future<void> _onUpdateGenre(
    UpdateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final updateResult = await updateGenre(event.genre);
    switch (updateResult) {
      case Ok():
        final genresResult = await getGenre();
        switch (genresResult) {
          case Ok(:final value):
            emit(GenreLoaded(value, message: 'Género actualizado'));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar la lista: ${error.message}');
        }
      case Err(:final error):
        emit(GenreError(error.message));
        NotificationService.error(
            'Error al actualizar el género: ${error.message}');
    }
  }

  Future<void> _onDeleteGenre(
    DeleteGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    final deleteResult = await deleteGenre(event.id);
    switch (deleteResult) {
      case Ok():
        final genresResult = await getGenre();
        switch (genresResult) {
          case Ok(:final value):
            emit(GenreLoaded(value, message: 'Género eliminado'));
          case Err(:final error):
            NotificationService.error(
                'Error al actualizar la lista: ${error.message}');
        }
      case Err(:final error):
        emit(GenreError(error.message));
        NotificationService.error(
            'Error al eliminar el género: ${error.message}');
    }
  }
}
