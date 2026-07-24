import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/tooks/data/took_repository_impl.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';
import 'package:noveles/features/tooks/domain/create_took.dart';
import 'package:noveles/features/tooks/domain/get_took.dart';
import 'package:noveles/features/tooks/domain/get_took_by_id.dart';
import 'package:noveles/features/tooks/domain/get_tooks_by_book.dart';
import 'package:noveles/features/tooks/domain/update_took.dart';
import 'package:noveles/features/tooks/domain/delete_took.dart';

final getIt = GetIt.instance;

void initTooksDependencies() {
  getIt.registerLazySingleton<TookRepository>(
    () => TookRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetTook(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetTookById(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetTooksByBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateTook(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateTook(getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteTook(getIt()),
  );
}
