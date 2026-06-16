import 'package:flutter_bloc/flutter_bloc.dart';
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
    try {
      final genres = await getGenre();
      emit(GenreLoaded(genres));
    } catch (e) {
      emit(GenreError(e.toString()));
    }
  }

  Future<void> _onCreateGenre(
    CreateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    try {
      await createGenre(event.genre);
      final genres = await getGenre();
      emit(GenreLoaded(genres, message: 'Género creado'));
    } catch (e) {
      emit(GenreError(e.toString()));
    }
  }

  Future<void> _onUpdateGenre(
    UpdateGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    try {
      await updateGenre(event.genre);
      final genres = await getGenre();
      emit(GenreLoaded(genres, message: 'Género actualizado'));
    } catch (e) {
      emit(GenreError(e.toString()));
    }
  }

  Future<void> _onDeleteGenre(
    DeleteGenreEvent event,
    Emitter<GenreState> emit,
  ) async {
    try {
      await deleteGenre(event.id);
      final genres = await getGenre();
      emit(GenreLoaded(genres, message: 'Género eliminado'));
    } catch (e) {
      emit(GenreError(e.toString()));
    }
  }
}
