import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:noveles/features/profiles/presentation/bloc/profile_event.dart';
export 'package:noveles/features/profiles/presentation/bloc/profile_state.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/domain/get_profile.dart';
import 'package:noveles/features/profiles/domain/update_profile.dart';
import 'package:noveles/features/profiles/domain/upload_avatar.dart';
import 'package:noveles/features/profiles/domain/change_password.dart';
import 'package:noveles/features/profiles/presentation/bloc/profile_event.dart'
    as events;
import 'package:noveles/features/profiles/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<events.ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadAvatar uploadAvatar;
  final ChangePassword changePassword;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadAvatar,
    required this.changePassword,
  }) : super(ProfileInitial()) {
    on<events.LoadProfile>(_onLoadProfile);
    on<events.UpdateProfile>(_onUpdateProfile);
    on<events.PickAvatar>(_onPickAvatar);
    on<events.ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    events.LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfile();
    switch (result) {
      case Ok(:final value):
        emit(ProfileLoaded(value));
      case Err(:final error):
        emit(ProfileError(error.message));
    }
  }

  Future<void> _onUpdateProfile(
    events.UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    switch (state) {
      case ProfileLoaded(:final user, :final pendingAvatarPath):
        emit(ProfileSaving(user));
        String? avatarUrl = user.avatarUrl;
        if (pendingAvatarPath != null) {
          final avatarResult = await uploadAvatar(pendingAvatarPath);
          switch (avatarResult) {
            case Ok(:final value):
              avatarUrl = value;
            case Err(:final error):
              emit(ProfileError(error.message, user: user));
              return;
          }
        }
        final updateResult = await updateProfile(
          displayName: event.displayName,
          bio: event.bio,
          avatarUrl: avatarUrl,
        );
        switch (updateResult) {
          case Ok(:final value):
            emit(
                ProfileLoaded(value, message: 'Perfil actualizado exitosamente'));
          case Err(:final error):
            emit(ProfileError(error.message, user: user));
        }
      case _:
        emit(ProfileError('No se puede actualizar: perfil no cargado'));
    }
  }

  Future<void> _onPickAvatar(
    events.PickAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    switch (state) {
      case ProfileLoaded(:final user):
        emit(ProfileLoaded(user, pendingAvatarPath: event.filePath));
      case _:
        return;
    }
  }

  Future<void> _onChangePassword(
    events.ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    switch (state) {
      case ProfileLoaded(:final user):
        emit(ProfileSaving(user));
        final result = await changePassword(event.newPassword);
        switch (result) {
          case Ok():
            emit(ProfileLoaded(user,
                message: 'Contraseña actualizada exitosamente'));
          case Err(:final error):
            emit(ProfileError(error.message, user: user));
        }
      case _:
        emit(
            ProfileError('No se puede cambiar la contraseña: perfil no cargado'));
    }
  }
}
