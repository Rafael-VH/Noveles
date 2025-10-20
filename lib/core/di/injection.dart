import 'package:get_it/get_it.dart';
//
import 'package:noveles/features/data/local/data_sources/book_local_data_source.dart';
import 'package:noveles/features/data/repositories/book_repository_impl.dart';
//
import 'package:noveles/features/domain/repositories/book_repository.dart';
import 'package:noveles/features/domain/use_cases/get_book.dart';
import 'package:noveles/features/domain/use_cases/get_book_by_id.dart';
//
import 'package:noveles/features/presentation/bloc/book_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Data Sources
  getIt.registerLazySingleton<BookLocalDataSource>(() => BookLocalDataSource());

  // Repositories
  getIt
      .registerLazySingleton<BookRepository>(() => BookRepositoryImpl(getIt()));

  // Use Cases
  getIt.registerLazySingleton(() => GetBooks(getIt()));
  getIt.registerLazySingleton(() => GetBookById(getIt()));

  // Blocs
  getIt.registerFactory(() => BookBloc(getIt(), getIt()));
}
