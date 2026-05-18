import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/profile/profile_event.dart' as events;
import 'package:noveles/features/presentation/bloc/profile/profile_state.dart';

// ProfileBloc es un Bloc que maneja los eventos y estados relacionados con la gestión del perfil del usuario en la aplicación. Este Bloc utiliza casos de uso como GetProfile, UpdateProfile, UploadAvatar y ChangePassword para realizar operaciones relacionadas con el perfil, como cargar la información del perfil, actualizar el nombre de usuario y la biografía, subir un nuevo avatar y cambiar la contraseña. El Bloc reacciona a los eventos emitidos por la interfaz de usuario y emite estados que representan el estado actual del perfil, lo que permite a la interfaz de usuario mostrar información relevante al usuario, como el perfil cargado, mensajes de éxito o error, y estados de carga.
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

  // Este método maneja el evento de carga de perfil. Primero emite un estado de carga mientras se intenta obtener la información del perfil. Si la operación es exitosa, emite un estado de perfil cargado con la información del usuario. Si ocurre un error durante el proceso, emite un estado de error con el mensaje del error.
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

  // Este método maneja el evento de actualización de perfil. Primero verifica si el perfil está cargado, y si no lo está, emite un estado de error. Si el perfil está cargado, emite un estado de guardado mientras intenta actualizar el perfil utilizando el caso de uso UpdateProfile. Si la operación es exitosa, emite un estado de perfil cargado con un mensaje de éxito. Si ocurre un error durante el proceso, emite un estado de error con el mensaje del error y el perfil actual.
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

  // Este método maneja el evento de selección de avatar. Primero verifica si el perfil está cargado, y si no lo está, simplemente retorna sin hacer nada. Si el perfil está cargado, emite un nuevo estado de perfil cargado con el mismo usuario pero con un pendingAvatar que representa la imagen seleccionada por el usuario. La interfaz de usuario puede reaccionar a este estado mostrando una vista previa del nuevo avatar antes de que se guarden los cambios en el perfil.
  Future<void> _onPickAvatar(
    events.PickAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;
    emit(ProfileLoaded(currentState.user, pendingAvatar: event.file));
  }

  // Este método maneja el evento de cambio de contraseña. Primero verifica si el perfil está cargado, y si no lo está, emite un estado de error. Si el perfil está cargado, emite un estado de guardado mientras intenta cambiar la contraseña utilizando el caso de uso ChangePassword. Si la operación es exitosa, emite un estado de perfil cargado con un mensaje de éxito. Si ocurre un error durante el proceso, emite un estado de error con el mensaje del error y el perfil actual.
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
