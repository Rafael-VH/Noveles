import 'package:equatable/equatable.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final String? pendingAvatarPath;
  final String? message;

  ProfileLoaded(this.user, {this.pendingAvatarPath, this.message});

  @override
  List<Object> get props => [user, pendingAvatarPath ?? '', message ?? ''];
}

class ProfileSaving extends ProfileState {
  final UserEntity user;

  ProfileSaving(this.user);

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  final UserEntity? user;

  ProfileError(this.message, {this.user});

  @override
  List<Object> get props => [message, user ?? ''];
}
