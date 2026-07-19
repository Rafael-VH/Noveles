import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? bio;

  const UpdateProfile({this.displayName, this.bio});

  @override
  List<Object> get props => [displayName ?? '', bio ?? ''];
}

class PickAvatar extends ProfileEvent {
  final String filePath;

  const PickAvatar(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class ChangePassword extends ProfileEvent {
  final String newPassword;

  const ChangePassword(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}
