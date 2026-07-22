import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_event.dart';
export 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/books/domain/get_recent_views.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_event.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_state.dart';

class RecentViewsBloc extends Bloc<RecentViewsEvent, RecentViewsState> {
  final GetRecentViews getRecentViews;

  RecentViewsBloc({required this.getRecentViews})
      : super(RecentViewsInitial()) {
    on<LoadRecentViews>(_onLoadRecentViews);
  }

  Future<void> _onLoadRecentViews(
    LoadRecentViews event,
    Emitter<RecentViewsState> emit,
  ) async {
    emit(RecentViewsLoading());
    final result = await getRecentViews(event.userId);
    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          emit(RecentViewsEmpty());
        } else {
          emit(RecentViewsLoaded(value));
        }
      case Err(:final error):
        emit(RecentViewsError(error.message));
    }
  }
}
