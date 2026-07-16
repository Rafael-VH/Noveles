import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/profiles/presentation/bloc/profile_bloc.dart';
import 'package:noveles/features/profiles/presentation/screens/widgets/avatar_section.dart';
import 'package:noveles/features/profiles/presentation/screens/widgets/profile_edit_form.dart';
import 'package:noveles/features/profiles/presentation/screens/widgets/password_change_form.dart';
import 'package:noveles/features/profiles/presentation/screens/widgets/logout_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      context.read<ProfileBloc>().add(PickAvatar(File(xFile.path)));
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            UpdateProfile(
              displayName: _displayNameController.text.trim(),
              bio: _bioController.text.trim(),
            ),
          );
    }
  }

  void _onChangePassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            ChangePassword(_newPasswordController.text),
          );
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  void _onLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              if (!_initialized) {
                _displayNameController.text = state.user.displayName ?? '';
                _bioController.text = state.user.bio ?? '';
                _initialized = true;
              }
              if (state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                );
              }
            }
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            UserEntity user;
            bool isSaving;
            File? pendingAvatar;

            if (state is ProfileLoaded) {
              user = state.user;
              isSaving = false;
              pendingAvatar = state.pendingAvatar;
            } else if (state is ProfileSaving) {
              user = state.user;
              isSaving = true;
              pendingAvatar = null;
            } else if (state is ProfileError && state.user != null) {
              user = state.user!;
              isSaving = false;
              pendingAvatar = null;
            } else {
              return const Center(child: Text('Error al cargar perfil'));
            }

            return _buildForm(context, user, isSaving, pendingAvatar);
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    UserEntity user,
    bool isSaving,
    File? pendingAvatar,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          AvatarSection(
            pendingAvatar: pendingAvatar,
            avatarUrl: user.avatarUrl,
            isSaving: isSaving,
            onPickImage: _pickImage,
          ),
          const SizedBox(height: 24),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ProfileEditForm(
            formKey: _formKey,
            displayNameController: _displayNameController,
            bioController: _bioController,
            isSaving: isSaving,
            onSave: _onSave,
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Cambiar Contraseña',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          PasswordChangeForm(
            formKey: _passwordFormKey,
            newPasswordController: _newPasswordController,
            confirmPasswordController: _confirmPasswordController,
            isSaving: isSaving,
            onChangePassword: _onChangePassword,
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          LogoutSection(onConfirmLogout: _onLogout),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
