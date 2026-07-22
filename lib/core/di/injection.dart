import 'package:get_it/get_it.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'injection_profiles.dart';
import 'injection_auth.dart';
import 'injection_books.dart';
import 'injection_chapters.dart';
import 'injection_favorites.dart';
import 'injection_genres.dart';
import 'injection_labels.dart';
import 'injection_tooks.dart';
import 'injection_scan.dart';
import 'injection_admin.dart';
import 'injection_app.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _registerCore();
  initProfilesDependencies();
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
  initFavoritesDependencies();
  initGenresDependencies();
  initLabelsDependencies();
  initTooksDependencies();
  initScanDependencies();
  initAdminDependencies();
  initAppDependencies();
}

void _registerCore() {
  getIt.registerLazySingleton<SupabaseClientProvider>(
    () => SupabaseClientProviderImpl(),
  );
  getIt.registerLazySingleton(
    () => CoverUrlService(getIt<SupabaseClientProvider>().client),
  );
}
