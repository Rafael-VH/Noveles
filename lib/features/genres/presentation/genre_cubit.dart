import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/presentation/genre_state.dart';

class GenreCubit extends Cubit<GenreState> {
  final GetGenre getGenres;

  GenreCubit({
    required this.getGenres,
  }) : super(GenreInitial());

  Future<void> loadGenres() async {
    emit(GenreLoading());
    final result = await getGenres();
    switch (result) {
      case Ok(:final value):
        emit(GenreLoaded(value));
      case Err(:final error):
        emit(GenreError(error.message));
    }
  }
}
