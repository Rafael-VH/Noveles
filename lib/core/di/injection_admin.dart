import 'package:get_it/get_it.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_bloc.dart';

final getIt = GetIt.instance;

void initAdminDependencies() {
  getIt.registerFactory(
    () => AdminBloc(
      getBooks: getIt(),
      toggleBookVisibility: getIt(),
      deleteBook: getIt(),
    ),
  );
  // AdminUsersBloc is now created directly in AdminDashScreen
  // with currentUserId from auth state for self-demotion protection
}
