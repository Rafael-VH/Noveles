import 'package:get_it/get_it.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/auth/data/auth_repository_impl.dart';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';
import 'package:noveles/features/auth/domain/use_cases/login.dart';
import 'package:noveles/features/auth/domain/use_cases/logout.dart';
import 'package:noveles/features/auth/domain/use_cases/register.dart';
import 'package:noveles/features/auth/domain/use_cases/get_current_user.dart';
import 'package:noveles/features/auth/domain/use_cases/listen_auth_state.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void initAuthDependencies() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<SupabaseClientProvider>(),
    ),
  );

  getIt.registerLazySingleton(
    () => Login(getIt()),
  );
  getIt.registerLazySingleton(
    () => Register(getIt()),
  );
  getIt.registerLazySingleton(
    () => Logout(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetCurrentUser(getIt()),
  );
  getIt.registerLazySingleton(
    () => ListenAuthState(getIt()),
  );

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
