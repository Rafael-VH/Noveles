import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/genre/genre_event.dart';
import 'package:noveles/features/presentation/bloc/genre/genre_state.dart';

// GenreBloc es una clase que extiende Bloc y se encarga de manejar los eventos relacionados con los géneros y emitir los estados correspondientes.
class GenreBloc extends Bloc<GenreEvent, GenreState> {
  final GetGenre getGenre;

  GenreBloc(this.getGenre) : super(GenreInitial()) {
    on<LoadGenres>(_onLoadGenres);
  }

  // Método que maneja el evento LoadGenres, que se encarga de cargar la lista de géneros disponibles. Este método emite un estado de carga mientras se realiza la operación, y luego emite un estado de éxito con la lista de géneros cargados o un estado de error si ocurre algún problema durante la carga.
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
}
