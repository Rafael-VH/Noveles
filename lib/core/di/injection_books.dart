import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/books/data/book_repository_impl.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/domain/create_book.dart';
import 'package:noveles/features/books/domain/get_book.dart';
import 'package:noveles/features/books/domain/get_book_by_id.dart';
import 'package:noveles/features/books/domain/get_books_by_genre.dart';
import 'package:noveles/features/books/domain/update_book.dart';
import 'package:noveles/features/books/domain/delete_book.dart';
import 'package:noveles/features/books/domain/toggle_book_visibility.dart';
import 'package:noveles/features/books/domain/upload_cover.dart';
import 'package:noveles/features/books/domain/get_book_labels.dart';
import 'package:noveles/features/books/presentation/bloc/book_bloc.dart';

final getIt = GetIt.instance;

void initBooksDependencies() {
  getIt.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      getIt<SupabaseClientProvider>(),
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
    () => UploadCover(getIt()),
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

  getIt.registerFactory(
    () => BookBloc(
      getBooks: getIt(),
      getBookById: getIt(),
    ),
  );
}
