import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminUsers extends AdminUsersEvent {
  const LoadAdminUsers();
}

class ChangeUserRole extends AdminUsersEvent {
  final String targetUserId;
  final String newRole;

  const ChangeUserRole({
    required this.targetUserId,
    required this.newRole,
  });

  @override
  List<Object> get props => [targetUserId, newRole];
}

class SuspendUser extends AdminUsersEvent {
  final String targetUserId;

  const SuspendUser({required this.targetUserId});

  @override
  List<Object> get props => [targetUserId];
}
