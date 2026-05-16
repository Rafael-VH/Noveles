import 'package:get_it/get_it.dart';
//
import 'package:noveles/features/data/repositories/auth_repository_impl.dart';
import 'package:noveles/features/data/repositories/book_repository_impl.dart';
import 'package:noveles/features/data/repositories/chapter_repository_impl.dart';
import 'package:noveles/features/data/repositories/genre_repository_impl.dart';
import 'package:noveles/features/data/repositories/profiles_repository_impl.dart';
import 'package:noveles/features/data/repositories/took_repository_impl.dart';
//
import 'package:noveles/features/domain/repositories/auth_repository.dart';
import 'package:noveles/features/domain/repositories/book_repository.dart';
import 'package:noveles/features/domain/repositories/chapter_repository.dart';
import 'package:noveles/features/domain/repositories/genre_repository.dart';
import 'package:noveles/features/domain/repositories/profiles_repository.dart';
import 'package:noveles/features/domain/repositories/took_repository.dart';
//
import 'package:noveles/features/domain/use_cases/change_password.dart';
import 'package:noveles/features/domain/use_cases/create_book.dart';
import 'package:noveles/features/domain/use_cases/create_chapter.dart';
import 'package:noveles/features/domain/use_cases/create_genre.dart';
import 'package:noveles/features/domain/use_cases/create_took.dart';
import 'package:noveles/features/domain/use_cases/delete_book.dart';
import 'package:noveles/features/domain/use_cases/delete_chapter.dart';
import 'package:noveles/features/domain/use_cases/delete_genre.dart';
import 'package:noveles/features/domain/use_cases/delete_took.dart';
import 'package:noveles/features/domain/use_cases/get_book.dart';
import 'package:noveles/features/domain/use_cases/get_book_by_id.dart';
import 'package:noveles/features/domain/use_cases/get_chapter.dart';
import 'package:noveles/features/domain/use_cases/get_chapter_by_id.dart';
import 'package:noveles/features/domain/use_cases/get_current_user.dart';
import 'package:noveles/features/domain/use_cases/get_genre.dart';
import 'package:noveles/features/domain/use_cases/get_genre_by_id.dart';
import 'package:noveles/features/domain/use_cases/get_profile.dart';
import 'package:noveles/features/domain/use_cases/get_took.dart';
import 'package:noveles/features/domain/use_cases/get_took_by_id.dart';
import 'package:noveles/features/domain/use_cases/login.dart';
import 'package:noveles/features/domain/use_cases/logout.dart';
import 'package:noveles/features/domain/use_cases/register.dart';
import 'package:noveles/features/domain/use_cases/update_book.dart';
import 'package:noveles/features/domain/use_cases/update_chapter.dart';
import 'package:noveles/features/domain/use_cases/update_genre.dart';
import 'package:noveles/features/domain/use_cases/update_profile.dart';
import 'package:noveles/features/domain/use_cases/update_took.dart';
import 'package:noveles/features/domain/use_cases/upload_avatar.dart';
//
import 'package:noveles/features/presentation/bloc/admin_bloc.dart';
import 'package:noveles/features/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/presentation/bloc/genre_bloc.dart';
import 'package:noveles/features/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<BookRepository>(() => BookRepositoryImpl());
  getIt.registerLazySingleton<GenreRepository>(() => GenreRepositoryImpl());
  getIt.registerLazySingleton<TookRepository>(() => TookRepositoryImpl());
  getIt.registerLazySingleton<ChapterRepository>(() => ChapterRepositoryImpl());
  getIt.registerLazySingleton<ProfilesRepository>(() => ProfilesRepositoryImpl());

  // Use Cases
  getIt.registerLazySingleton(() => Login(getIt()));
  getIt.registerLazySingleton(() => Register(getIt()));
  getIt.registerLazySingleton(() => Logout(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));
  getIt.registerLazySingleton(() => GetBooks(getIt()));
  getIt.registerLazySingleton(() => GetBookById(getIt()));
  getIt.registerLazySingleton(() => CreateBook(getIt()));
  getIt.registerLazySingleton(() => UpdateBook(getIt()));
  getIt.registerLazySingleton(() => DeleteBook(getIt()));
  getIt.registerLazySingleton(() => GetGenre(getIt()));
  getIt.registerLazySingleton(() => GetGenreById(getIt()));
  getIt.registerLazySingleton(() => CreateGenre(getIt()));
  getIt.registerLazySingleton(() => UpdateGenre(getIt()));
  getIt.registerLazySingleton(() => DeleteGenre(getIt()));
  getIt.registerLazySingleton(() => GetTook(getIt()));
  getIt.registerLazySingleton(() => GetTookById(getIt()));
  getIt.registerLazySingleton(() => CreateTook(getIt()));
  getIt.registerLazySingleton(() => UpdateTook(getIt()));
  getIt.registerLazySingleton(() => DeleteTook(getIt()));
  getIt.registerLazySingleton(() => GetChapter(getIt()));
  getIt.registerLazySingleton(() => GetChapterById(getIt()));
  getIt.registerLazySingleton(() => CreateChapter(getIt()));
  getIt.registerLazySingleton(() => UpdateChapter(getIt()));
  getIt.registerLazySingleton(() => DeleteChapter(getIt()));
  getIt.registerLazySingleton(() => GetProfile(getIt()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt()));
  getIt.registerLazySingleton(() => UploadAvatar(getIt()));
  getIt.registerLazySingleton(() => ChangePassword(getIt()));

  // Blocs
  getIt.registerFactory(
    () => AuthBloc(
      login: getIt(),
      register: getIt(),
      logout: getIt(),
      getCurrentUser: getIt(),
    ),
  );
  getIt.registerFactory(
    () => BookBloc(
      getBooks: getIt(),
      getBookById: getIt(),
    ),
  );
  getIt.registerFactory(() => GenreBloc(getIt()));
  getIt.registerFactory(
    () => ProfileBloc(
      getProfile: getIt(),
      updateProfile: getIt(),
      uploadAvatar: getIt(),
      changePassword: getIt(),
    ),
  );

  getIt.registerFactory(
    () => AdminBloc(
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
    ),
  );
}
