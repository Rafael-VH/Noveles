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
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      emit(ProfileError('No se puede actualizar: perfil no cargado'));
      return;
    }
    emit(ProfileSaving(currentState.user));
    String? avatarUrl = currentState.user.avatarUrl;
    if (currentState.pendingAvatar != null) {
      final avatarResult =
          await uploadAvatar(currentState.pendingAvatar!.path);
      switch (avatarResult) {
        case Ok(:final value):
          avatarUrl = value;
        case Err(:final error):
          emit(ProfileError(error.message, user: currentState.user));
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
        emit(ProfileLoaded(value, message: 'Perfil actualizado exitosamente'));
      case Err(:final error):
        emit(ProfileError(error.message, user: currentState.user));
    }
  }

  Future<void> _onPickAvatar(
    events.PickAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    emit(ProfileLoaded(currentState.user, pendingAvatar: event.file));
  }

  Future<void> _onChangePassword(
    events.ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      emit(ProfileError('No se puede cambiar la contraseña: perfil no cargado'));
      return;
    }
    emit(ProfileSaving(currentState.user));
    final result = await changePassword(event.newPassword);
    switch (result) {
      case Ok():
        emit(ProfileLoaded(currentState.user,
            message: 'Contraseña actualizada exitosamente'));
      case Err(:final error):
        emit(ProfileError(error.message, user: currentState.user));
    }
  }
}
