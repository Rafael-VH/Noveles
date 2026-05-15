import 'package:get_it/get_it.dart';
//
import 'package:noveles/features/data/repositories/book_repository_impl.dart';
import 'package:noveles/features/data/repositories/chapter_repository_impl.dart';
import 'package:noveles/features/data/repositories/genre_repository_impl.dart';
import 'package:noveles/features/data/repositories/took_repository_impl.dart';
//
import 'package:noveles/features/domain/repositories/book_repository.dart';
import 'package:noveles/features/domain/repositories/chapter_repository.dart';
import 'package:noveles/features/domain/repositories/genre_repository.dart';
import 'package:noveles/features/domain/repositories/took_repository.dart';
//
import 'package:noveles/features/domain/use_cases/get_book.dart';
import 'package:noveles/features/domain/use_cases/get_book_by_id.dart';
import 'package:noveles/features/domain/use_cases/get_genre.dart';
import 'package:noveles/features/domain/use_cases/get_took.dart';
import 'package:noveles/features/domain/use_cases/get_chapter.dart';
//
import 'package:noveles/features/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/presentation/bloc/genre_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<BookRepository>(() => BookRepositoryImpl());
  getIt.registerLazySingleton<GenreRepository>(() => GenreRepositoryImpl());
  getIt.registerLazySingleton<TookRepository>(() => TookRepositoryImpl());
  getIt.registerLazySingleton<ChapterRepository>(() => ChapterRepositoryImpl());

  // Use Cases
  getIt.registerLazySingleton(() => GetBooks(getIt()));
  getIt.registerLazySingleton(() => GetBookById(getIt()));
  getIt.registerLazySingleton(() => GetGenre(getIt()));
  getIt.registerLazySingleton(() => GetTook(getIt()));
  getIt.registerLazySingleton(() => GetChapter(getIt()));

  // Blocs
  getIt.registerFactory(() => BookBloc(getIt(), getIt()));
  getIt.registerFactory(() => GenreBloc(getIt()));
}
