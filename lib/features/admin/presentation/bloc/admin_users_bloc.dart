import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
export 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAllProfiles getAllProfiles;
  final String currentUserId;

  AdminUsersBloc({
    required this.getAllProfiles,
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
    // TODO: Implement role change via repository (Fase 5)
    emit(AdminUsersError('Cambio de rol no implementado aún'));
  }

  Future<void> _onSuspendUser(
    SuspendUser event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (event.targetUserId == currentUserId) {
      emit(AdminUsersError('No puedes suspenderte a ti mismo'));
      return;
    }
    // TODO: Implement suspension via repository (Fase 5)
    emit(AdminUsersError('Suspensión no implementada aún'));
  }
}
