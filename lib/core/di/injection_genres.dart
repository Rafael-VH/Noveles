import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/genres/data/genre_repository_impl.dart';
import 'package:noveles/features/genres/domain/genre_repository.dart';
import 'package:noveles/features/genres/domain/create_genre.dart';
import 'package:noveles/features/genres/domain/get_genre.dart';
import 'package:noveles/features/genres/domain/get_genre_by_id.dart';
import 'package:noveles/features/genres/domain/update_genre.dart';
import 'package:noveles/features/genres/domain/delete_genre.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_bloc.dart';

final getIt = GetIt.instance;

void initGenresDependencies() {
  getIt.registerLazySingleton<GenreRepository>(
    () => GenreRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetGenre(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetGenreById(getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateGenre(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateGenre(getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteGenre(getIt()),
  );

  getIt.registerFactory(
    () => GenreBloc(
      getGenre: getIt(),
      createGenre: getIt(),
      updateGenre: getIt(),
      deleteGenre: getIt(),
    ),
  );
}
