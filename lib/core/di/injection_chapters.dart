import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/chapters/data/chapter_repository_impl.dart';
import 'package:noveles/features/chapters/domain/chapter_repository.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/get_chapter.dart';
import 'package:noveles/features/chapters/domain/get_chapter_by_id.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';
import 'package:noveles/features/chapters/domain/upload_chapter_content.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';

final getIt = GetIt.instance;

void initChaptersDependencies() {
  getIt.registerLazySingleton<ChapterRepository>(
    () => ChapterRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetChapter(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetChapterById(getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateChapter(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateChapter(getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteChapter(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetChapterContent(getIt()),
  );
  getIt.registerLazySingleton(
    () => UploadChapterContent(getIt()),
  );
  getIt.registerLazySingleton(
    () => MarkChapterAsRead(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetReadChapterIds(getIt()),
  );

  getIt.registerFactory(
    () => ChapterBloc(getChapterContent: getIt()),
  );
}
