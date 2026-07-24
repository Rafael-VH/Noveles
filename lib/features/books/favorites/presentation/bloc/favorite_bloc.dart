import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/books/favorites/presentation/bloc/favorite_event.dart';
export 'package:noveles/features/books/favorites/presentation/bloc/favorite_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_event.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository favoriteRepository;

  FavoriteBloc({required this.favoriteRepository}) : super(FavoriteInitial()) {
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    final result = await favoriteRepository.toggleFavorite(
      event.userId,
      event.bookId,
    );
    switch (result) {
      case Ok(:final value):
        emit(FavoriteToggled(value));
      case Err(:final error):
        emit(FavoriteError(error.message));
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    final result = await favoriteRepository.getFavorites(event.userId);
    switch (result) {
      case Ok(:final value):
        emit(FavoriteLoaded(value));
      case Err(:final error):
        emit(FavoriteError(error.message));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoriteState> emit,
  ) async {
    final result = await favoriteRepository.isFavorite(
      event.userId,
      event.bookId,
    );
    switch (result) {
      case Ok(:final value):
        emit(FavoriteStatusChecked(value));
      case Err(:final error):
        emit(FavoriteError(error.message));
    }
  }
}
