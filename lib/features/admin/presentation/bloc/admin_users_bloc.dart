import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
export 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
import 'package:noveles/features/profiles/domain/update_user_role.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAllProfiles getAllProfiles;
  final UpdateUserRole updateUserRole;
  final String currentUserId;

  AdminUsersBloc({
    required this.getAllProfiles,
    required this.updateUserRole,
    required this.currentUserId,
  }) : super(const AdminUsersInitial()) {
    on<LoadAdminUsers>(_onLoadUsers);
    on<ChangeUserRole>(_onChangeRole);
    on<SuspendUser>(_onSuspendUser);
  }

  Future<void> _onLoadUsers(
    LoadAdminUsers event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(const AdminUsersLoading());
    final result = await getAllProfiles();
    switch (result) {
      case Ok(:final value):
        emit(AdminUsersLoaded(value));
      case Err(:final error):
        emit(AdminUsersError(error.message));
    }
  }

  Future<void> _onChangeRole(
    ChangeUserRole event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (event.targetUserId == currentUserId) {
      emit(AdminUsersError('No puedes cambiar tu propio rol'));
      return;
    }
    final result = await updateUserRole(event.targetUserId, event.newRole);
    switch (result) {
      case Ok():
        final reloadResult = await getAllProfiles();
        switch (reloadResult) {
          case Ok(:final value):
            emit(AdminUsersLoaded(
              value,
              message: 'Rol cambiado a ${event.newRole}',
            ));
          case Err(:final error):
            emit(AdminUsersError(error.message));
        }
      case Err(:final error):
        emit(AdminUsersError(error.message));
    }
  }

  Future<void> _onSuspendUser(
    SuspendUser event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (event.targetUserId == currentUserId) {
      emit(AdminUsersError('No puedes suspenderte a ti mismo'));
      return;
    }

    // Determine current suspension status from loaded state
    UserRole targetRole = UserRole.user;
    final currentState = state;
    if (currentState is AdminUsersLoaded) {
      final user = currentState.users
          .where((u) => u.id == event.targetUserId)
          .firstOrNull;
      if (user != null) {
        targetRole = user.isSuspended ? UserRole.user : UserRole.suspended;
      }
    }

    final result = await updateUserRole(event.targetUserId, targetRole.name);
    switch (result) {
      case Ok():
        final reloadResult = await getAllProfiles();
        switch (reloadResult) {
          case Ok(:final value):
            final message = targetRole == UserRole.suspended
                ? 'Usuario suspendido'
                : 'Usuario reactivado';
            emit(AdminUsersLoaded(value, message: message));
          case Err(:final error):
            emit(AdminUsersError(error.message));
        }
      case Err(:final error):
        emit(AdminUsersError(error.message));
    }
  }
}
