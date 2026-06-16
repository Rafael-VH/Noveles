import 'package:get_it/get_it.dart';
import 'package:noveles/features/auth/data/auth_repository_impl.dart';
import 'package:noveles/features/auth/domain/auth_repository.dart';
import 'package:noveles/features/auth/domain/login.dart';
import 'package:noveles/features/auth/domain/logout.dart';
import 'package:noveles/features/auth/domain/register.dart';
import 'package:noveles/features/auth/domain/get_current_user.dart';
import 'package:noveles/features/auth/domain/listen_auth_state.dart';
import 'package:noveles/features/auth/domain/change_password.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_bloc.dart';

final getIt = GetIt.instance;

void initAuthDependencies() {
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  getIt.registerLazySingleton(() => Login(getIt()));
  getIt.registerLazySingleton(() => Register(getIt()));
  getIt.registerLazySingleton(() => Logout(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt()));
  getIt.registerLazySingleton(() => ListenAuthState(getIt()));
  getIt.registerLazySingleton(() => ChangePassword(getIt()));

  getIt.registerFactory(
    () => AuthBloc(
      login: getIt(),
      register: getIt(),
      logout: getIt(),
      getCurrentUser: getIt(),
      listenAuthState: getIt(),
    ),
  );
}
