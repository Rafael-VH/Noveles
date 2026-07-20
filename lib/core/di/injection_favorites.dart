import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/favorites/data/favorite_repository_impl.dart';
import 'package:noveles/features/favorites/domain/favorite_repository.dart';
import 'package:noveles/features/favorites/presentation/bloc/favorite_bloc.dart';

final getIt = GetIt.instance;

void initFavoritesDependencies() {
  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerFactory(
    () => FavoriteBloc(
      favoriteRepository: getIt(),
    ),
  );
}
