import 'package:get_it/get_it.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_bloc.dart';

final getIt = GetIt.instance;

void initScanDependencies() {
  getIt.registerFactory(
    () => ScanBloc(
      getBooks: getIt(),
      createBook: getIt(),
      updateBook: getIt(),
      deleteBook: getIt(),
      createTook: getIt(),
      updateTook: getIt(),
      deleteTook: getIt(),
      createChapter: getIt(),
      updateChapter: getIt(),
      deleteChapter: getIt(),
      getGenres: getIt(),
      uploadCover: getIt(),
      toggleBookVisibility: getIt(),
    ),
  );
}
