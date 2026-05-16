import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/profile_event.dart' as events;
import 'package:noveles/features/presentation/bloc/profile_state.dart';

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
    try {
      final user = await getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
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
    try {
      String? avatarUrl = currentState.user.avatarUrl;
      if (currentState.pendingAvatar != null) {
        avatarUrl = await uploadAvatar(currentState.pendingAvatar!.path);
      }
      final user = await updateProfile(
        displayName: event.displayName,
        bio: event.bio,
        avatarUrl: avatarUrl,
      );
      emit(ProfileLoaded(user, message: 'Perfil actualizado exitosamente'));
    } catch (e) {
      emit(ProfileError(e.toString(), user: currentState.user));
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
    try {
      await changePassword(event.newPassword);
      emit(ProfileLoaded(currentState.user, message: 'Contraseña actualizada exitosamente'));
    } catch (e) {
      emit(ProfileError(e.toString(), user: currentState.user));
    }
  }
}
