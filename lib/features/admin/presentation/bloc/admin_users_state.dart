import 'package:equatable/equatable.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object> get props => [];
}

class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserEntity> users;
  final String? message;

  const AdminUsersLoaded(this.users, {this.message});

  @override
  List<Object> get props => [users, message ?? ''];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object> get props => [message];
}
