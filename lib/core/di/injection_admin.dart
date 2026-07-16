import 'package:get_it/get_it.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';

final getIt = GetIt.instance;

void initAdminDependencies() {
  getIt.registerFactory(
    () => AdminBloc(
      getBooks: getIt(),
      toggleBookVisibility: getIt(),
      deleteBook: getIt(),
    ),
  );
  getIt.registerFactory(
    () => AdminUsersBloc(getAllProfiles: getIt()),
  );
}
