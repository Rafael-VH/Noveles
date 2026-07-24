import 'package:get_it/get_it.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_bloc.dart';
import 'package:noveles/features/genres/presentation/genre_cubit.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_bloc.dart';

final getIt = GetIt.instance;

void initScanDependencies() {
  // ScanBookBloc — book CRUD + visibility operations
  getIt.registerFactory(
    () => ScanBookBloc(
      getBooks: getIt(),
      createBook: getIt(),
      updateBook: getIt(),
      deleteBook: getIt(),
      toggleBookVisibility: getIt(),
    ),
  );

  // ScanCoverBloc — cover upload only
  getIt.registerFactory(
    () => ScanCoverBloc(
      uploadImage: getIt(),
    ),
  );

  // GenreCubit — shared genre loading
  getIt.registerFactory(
    () => GenreCubit(
      getGenres: getIt(),
    ),
  );

  // ScanTookBloc — took operations
  getIt.registerFactory(
    () => ScanTookBloc(
      createTook: getIt(),
      updateTook: getIt(),
      deleteTook: getIt(),
      uploadImage: getIt(),
    ),
  );

  // ScanChapterBloc — chapter operations
  getIt.registerFactory(
    () => ScanChapterBloc(
      createChapter: getIt(),
      updateChapter: getIt(),
      deleteChapter: getIt(),
      uploadContent: getIt(),
    ),
  );
}
