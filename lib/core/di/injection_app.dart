import 'package:get_it/get_it.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_bloc.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_bloc.dart';

final getIt = GetIt.instance;

void initAppDependencies() {
  getIt.registerFactory(
    () => RecentViewsBloc(getRecentViews: getIt()),
  );
  getIt.registerFactory(
    () => PopularViewsBloc(getMostViewedBooks: getIt()),
  );
}
