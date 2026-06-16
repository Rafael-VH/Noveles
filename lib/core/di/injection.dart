import 'package:get_it/get_it.dart';
import 'injection_profiles.dart';
import 'injection_auth.dart';
import 'injection_books.dart';
import 'injection_chapters.dart';
import 'injection_genres.dart';
import 'injection_labels.dart';
import 'injection_tooks.dart';
import 'injection_scan.dart';
import 'injection_admin.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  initProfilesDependencies();
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
  initGenresDependencies();
  initLabelsDependencies();
  initTooksDependencies();
  initScanDependencies();
  initAdminDependencies();
}
