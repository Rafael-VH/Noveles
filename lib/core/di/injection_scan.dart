import 'package:get_it/get_it.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_bloc.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_took_bloc.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_chapter_bloc.dart';

final getIt = GetIt.instance;

void initScanDependencies() {
  // ScanBookBloc — book operations
  getIt.registerFactory(
    () => ScanBloc(
      getBooks: getIt(),
      createBook: getIt(),
      updateBook: getIt(),
      deleteBook: getIt(),
      getGenres: getIt(),
      uploadCover: getIt(),
      toggleBookVisibility: getIt(),
    ),
  );

  // ScanTookBloc — took operations
  getIt.registerFactory(
    () => ScanTookBloc(
      createTook: getIt(),
      updateTook: getIt(),
      deleteTook: getIt(),
    ),
  );

  // ScanChapterBloc — chapter operations
  getIt.registerFactory(
    () => ScanChapterBloc(
      createChapter: getIt(),
      updateChapter: getIt(),
      deleteChapter: getIt(),
    ),
  );
}
