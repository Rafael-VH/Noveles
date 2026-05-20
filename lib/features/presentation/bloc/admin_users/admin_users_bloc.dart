import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/get_all_profiles.dart';
import 'package:noveles/features/presentation/bloc/admin_users/admin_users_event.dart';
import 'package:noveles/features/presentation/bloc/admin_users/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAllProfiles getAllProfiles;

  AdminUsersBloc({
    required this.getAllProfiles,
  }) : super(const AdminUsersInitial()) {
    on<LoadAdminUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadAdminUsers event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(const AdminUsersLoading());
    try {
      final users = await getAllProfiles();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminUsersError(e.toString()));
    }
  }
}
