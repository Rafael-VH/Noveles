import 'package:get_it/get_it.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/profiles/di/injection_profiles.dart';
import 'package:noveles/features/auth/di/injection_auth.dart';
import 'package:noveles/features/books/di/injection_books.dart';
import 'package:noveles/features/chapters/di/injection_chapters.dart';
import 'package:noveles/features/genres/di/injection_genres.dart';
import 'package:noveles/features/labels/di/injection_labels.dart';
import 'package:noveles/features/tooks/di/injection_tooks.dart';
import 'package:noveles/features/scan/di/injection_scan.dart';
import 'package:noveles/features/admin/di/injection_admin.dart';
import 'package:noveles/features/app/di/injection_app.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _registerCore();
  initProfilesDependencies();
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
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
