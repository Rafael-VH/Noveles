import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/get_profile.dart';
import 'package:noveles/features/domain/use_cases/update_profile.dart' as usecases;
import 'package:noveles/features/domain/use_cases/upload_avatar.dart' as usecases2;
import 'package:noveles/features/domain/use_cases/change_password.dart' as usecases3;
import 'package:noveles/features/presentation/bloc/profile/profile_bloc.dart';
import 'package:noveles/features/presentation/bloc/profile/profile_event.dart';
import 'package:noveles/features/presentation/bloc/profile/profile_state.dart';

class MockGetProfile extends Mock implements GetProfile {}
class MockUpdateProfile extends Mock implements usecases.UpdateProfile {}
class MockUploadAvatar extends Mock implements usecases2.UploadAvatar {}
class MockChangePassword extends Mock implements usecases3.ChangePassword {}

void main() {
  late MockGetProfile mockGetProfile;
  late MockUpdateProfile mockUpdateProfile;
  late MockUploadAvatar mockUploadAvatar;
  late MockChangePassword mockChangePassword;

  final testUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    role: 'user',
    displayName: 'Test User',
    bio: 'Bio text',
    avatarUrl: null,
  );

  final updatedUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    role: 'user',
    displayName: 'Updated Name',
    bio: 'Updated bio',
    avatarUrl: null,
  );

  setUp(() {
    mockGetProfile = MockGetProfile();
    mockUpdateProfile = MockUpdateProfile();
    mockUploadAvatar = MockUploadAvatar();
    mockChangePassword = MockChangePassword();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileInitial', () {
      final bloc = ProfileBloc(
        getProfile: mockGetProfile,
        updateProfile: mockUpdateProfile,
        uploadAvatar: mockUploadAvatar,
        changePassword: mockChangePassword,
      );
      expect(bloc.state, equals(ProfileInitial()));
      bloc.close();
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when LoadProfile succeeds',
      build: () {
        when(() => mockGetProfile()).thenAnswer((_) async => testUser);
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
        act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having(
          (s) => s.user.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when LoadProfile fails',
      build: () {
        when(() => mockGetProfile()).thenThrow(Exception('Error al cargar'));
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
        act: (bloc) => bloc.add(LoadProfile()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('Error al cargar'),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileLoaded] when UpdateProfile succeeds',
      setUp: () {
        when(() => mockGetProfile()).thenAnswer((_) async => testUser);
      },
      build: () {
        when(() => mockUpdateProfile(
          displayName: any(named: 'displayName'),
          bio: any(named: 'bio'),
          avatarUrl: any(named: 'avatarUrl'),
        )).thenAnswer((_) async => updatedUser);
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      seed: () => ProfileLoaded(testUser),
      act: (bloc) => bloc.add(UpdateProfile(
        displayName: 'Updated Name',
        bio: 'Updated bio',
      )),
      expect: () => [
        isA<ProfileSaving>().having(
          (s) => s.user.displayName,
          'user displayName',
          'Test User',
        ),
        isA<ProfileLoaded>().having(
          (s) => s.user.displayName,
          'updated displayName',
          'Updated Name',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileError] when UpdateProfile fails',
      setUp: () {
        when(() => mockGetProfile()).thenAnswer((_) async => testUser);
      },
      build: () {
        when(() => mockUpdateProfile(
          displayName: any(named: 'displayName'),
          bio: any(named: 'bio'),
          avatarUrl: any(named: 'avatarUrl'),
        )).thenThrow(Exception('Error al actualizar'));
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      seed: () => ProfileLoaded(testUser),
      act: (bloc) => bloc.add(UpdateProfile(
        displayName: 'Updated Name',
        bio: 'Updated bio',
      )),
      expect: () => [
        isA<ProfileSaving>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('Error al actualizar'),
        ).having(
          (s) => s.user?.displayName,
          'user preserved',
          'Test User',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileLoaded] when ChangePassword succeeds',
      setUp: () {
        when(() => mockGetProfile()).thenAnswer((_) async => testUser);
      },
      build: () {
        when(() => mockChangePassword(any())).thenAnswer((_) async {});
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      seed: () => ProfileLoaded(testUser),
      act: (bloc) => bloc.add(ChangePassword('newPass123')),
      expect: () => [
        isA<ProfileSaving>(),
        isA<ProfileLoaded>().having(
          (s) => s.message,
          'message',
          'Contraseña actualizada exitosamente',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileSaving, ProfileError] when ChangePassword fails',
      setUp: () {
        when(() => mockGetProfile()).thenAnswer((_) async => testUser);
      },
      build: () {
        when(() => mockChangePassword(any()))
            .thenThrow(Exception('Error al cambiar'));
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      seed: () => ProfileLoaded(testUser),
      act: (bloc) => bloc.add(ChangePassword('newPass123')),
      expect: () => [
        isA<ProfileSaving>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('Error al cambiar'),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileError when UpdateProfile is called on ProfileInitial',
      build: () {
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      act: (bloc) => bloc.add(UpdateProfile(displayName: 'New')),
      expect: () => [
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('No se puede actualizar'),
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileError when ChangePassword is called on ProfileInitial',
      build: () {
        return ProfileBloc(
          getProfile: mockGetProfile,
          updateProfile: mockUpdateProfile,
          uploadAvatar: mockUploadAvatar,
          changePassword: mockChangePassword,
        );
      },
      act: (bloc) => bloc.add(ChangePassword('newPass')),
      expect: () => [
        isA<ProfileError>().having(
          (s) => s.message,
          'message',
          contains('No se puede cambiar la contraseña'),
        ),
      ],
    );
  });
}
