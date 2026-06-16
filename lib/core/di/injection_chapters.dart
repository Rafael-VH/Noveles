import 'package:get_it/get_it.dart';
import 'package:noveles/features/chapters/data/chapter_repository_impl.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/get_chapter.dart';
import 'package:noveles/features/chapters/domain/get_chapter_by_id.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_bloc.dart';

final getIt = GetIt.instance;

void initChaptersDependencies() {
  getIt.registerLazySingleton<ChapterRepository>(() => ChapterRepositoryImpl());

  getIt.registerLazySingleton(() => GetChapter(getIt()));
  getIt.registerLazySingleton(() => GetChapterById(getIt()));
  getIt.registerLazySingleton(() => CreateChapter(getIt()));
  getIt.registerLazySingleton(() => UpdateChapter(getIt()));
  getIt.registerLazySingleton(() => DeleteChapter(getIt()));
  getIt.registerLazySingleton(() => GetChapterContent(getIt()));

  getIt.registerFactory(
    () => ChapterBloc(getChapterContent: getIt()),
  );
}
