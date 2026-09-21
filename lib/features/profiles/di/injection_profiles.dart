import 'package:get_it/get_it.dart';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/features/profiles/data/profiles_repository_impl.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';
import 'package:noveles/features/profiles/domain/get_profile.dart';
import 'package:noveles/features/profiles/domain/update_profile.dart';
import 'package:noveles/features/profiles/domain/upload_avatar.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
import 'package:noveles/features/profiles/domain/change_password.dart';
import 'package:noveles/features/profiles/domain/update_user_role.dart';
import 'package:noveles/features/profiles/presentation/bloc/profile_bloc.dart'
    hide UpdateProfile, ChangePassword;

final getIt = GetIt.instance;

void initProfilesDependencies() {
  getIt.registerLazySingleton<ProfilesRepository>(
    () => ProfilesRepositoryImpl(
      getIt<DataGateway>(),
      getIt<StorageGateway>(),
      getIt<AuthGateway>(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetProfile(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateProfile(getIt()),
  );
  getIt.registerLazySingleton(
    () => UploadAvatar(getIt()),
  );
  getIt.registerLazySingleton(
    () => GetAllProfiles(getIt()),
  );
  getIt.registerLazySingleton(
    () => UpdateUserRole(getIt()),
  );
  getIt.registerLazySingleton(
    () => ChangePassword(getIt()),
  );

  getIt.registerFactory(
    () => ProfileBloc(
      getProfile: getIt(),
      updateProfile: getIt(),
      uploadAvatar: getIt(),
      changePassword: getIt(),
    ),
  );
}
