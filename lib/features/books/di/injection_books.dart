import 'package:get_it/get_it.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/features/books/data/book_repository_impl.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/get_book_by_id.dart';
import 'package:noveles/features/books/domain/get_books_by_genre.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/books/domain/upload_image.dart';
import 'package:noveles/features/books/domain/get_book_labels.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';
import 'package:noveles/features/books/domain/get_recent_views.dart';
import 'package:noveles/features/books/domain/get_most_viewed_books.dart';
import 'package:noveles/features/books/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/books/favorites/data/favorite_repository_impl.dart';
import 'package:noveles/features/books/favorites/domain/favorite_repository.dart';
import 'package:noveles/features/books/favorites/domain/use_cases/get_favorites_use_case.dart';
import 'package:noveles/features/books/favorites/domain/use_cases/is_favorite_use_case.dart';
import 'package:noveles/features/books/favorites/domain/use_cases/toggle_favorite_use_case.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';

void initBooksDependencies(GetIt getIt) {
  getIt.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      getIt<DataGateway>(),
      getIt<StorageGateway>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetBooks(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetBookById(getIt()),
  );
  getIt.registerLazySingleton(
    () => CreateBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => DeleteBook(getIt()),
  );
  getIt.registerLazySingleton(
    () => UploadImage(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetBooksByGenre(),
  );
  getIt.registerLazySingleton(
    () => ToggleBookVisibility(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetBookLabels(getIt()),
  );
  getIt.registerLazySingleton(
    () => TrackBookView(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetRecentViews(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetMostViewedBooks(getIt()),
  );

  getIt.registerFactory(
    () => BookBloc(
      getBooks: getIt(),
      getBookById: getIt(),
    ),
  );

  // Favorites
  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      getIt<DataGateway>(),
    ),
  );

  getIt.registerLazySingleton(
    () => ToggleFavorite(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetFavorites(getIt()),
  );
  getIt.registerLazySingleton(
    () => IsFavorite(getIt()),
  );

  getIt.registerFactory(
    () => FavoriteBloc(
      toggleFavorite: getIt(),
      getFavorites: getIt(),
      isFavorite: getIt(),
    ),
  );
}
