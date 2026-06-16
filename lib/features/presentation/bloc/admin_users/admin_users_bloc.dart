import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
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
    final result = await getAllProfiles();
    switch (result) {
      case Ok(:final value):
        emit(AdminUsersLoaded(value));
      case Err(:final error):
        emit(AdminUsersError(error.message));
        NotificationService.error('Error al cargar usuarios: ${error.message}');
    }
  }
}
