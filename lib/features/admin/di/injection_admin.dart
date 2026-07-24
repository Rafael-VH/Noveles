import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/admin/data/analytics_repository_impl.dart';
import 'package:noveles/features/admin/domain/analytics_repository.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_bloc.dart';

final getIt = GetIt.instance;

void initAdminDependencies() {
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(getIt<SupabaseClientProvider>()),
  );
  getIt.registerFactory(
    () => AdminBloc(
      getBooks: getIt(),
      toggleBookVisibility: getIt(),
      deleteBook: getIt(),
    ),
  );
  getIt.registerFactory(
    () => AdminAnalyticsBloc(analyticsRepository: getIt()),
  );
}
