import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? bio;

  UpdateProfile({this.displayName, this.bio});

  @override
  List<Object> get props => [displayName ?? '', bio ?? ''];
}

class PickAvatar extends ProfileEvent {
  final File file;

  PickAvatar(this.file);

  @override
  List<Object> get props => [file];
}

class ChangePassword extends ProfileEvent {
  final String newPassword;

  ChangePassword(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}
