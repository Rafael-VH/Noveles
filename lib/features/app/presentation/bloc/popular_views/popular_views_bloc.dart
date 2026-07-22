import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_event.dart';
export 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/get_most_viewed_books.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_event.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_state.dart';

class PopularViewsBloc extends Bloc<PopularViewsEvent, PopularViewsState> {
  final GetMostViewedBooks getMostViewedBooks;

  PopularViewsBloc({required this.getMostViewedBooks})
      : super(PopularViewsInitial()) {
    on<LoadPopularViews>(_onLoadPopularViews);
  }

  Future<void> _onLoadPopularViews(
    LoadPopularViews event,
    Emitter<PopularViewsState> emit,
  ) async {
    emit(PopularViewsLoading());
    final result = await getMostViewedBooks();
    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          emit(PopularViewsEmpty());
        } else {
          emit(PopularViewsLoaded(value));
        }
      case Err(:final error):
        emit(PopularViewsError(error.message));
    }
  }
}
