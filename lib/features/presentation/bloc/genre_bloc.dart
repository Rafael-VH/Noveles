import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/genre_event.dart';
import 'package:noveles/features/presentation/bloc/genre_state.dart';

class GenreBloc extends Bloc<GenreEvent, GenreState> {
  final GetGenre getGenre;

  GenreBloc(this.getGenre) : super(GenreInitial()) {
    on<LoadGenres>(_onLoadGenres);
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
}
