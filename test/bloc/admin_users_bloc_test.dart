import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
import 'package:noveles/features/profiles/domain/update_user_role.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';

class MockGetAllProfiles extends Mock implements GetAllProfiles {}

class MockUpdateUserRole extends Mock implements UpdateUserRole {}

void main() {
  late MockGetAllProfiles mockGetAllProfiles;
  late MockUpdateUserRole mockUpdateUserRole;

  final testUsers = [
    const UserEntity(
      id: '1',
      email: 'admin@test.com',
      role: UserRole.admin,
      displayName: 'Admin',
    ),
    const UserEntity(
      id: '2',
      email: 'scan@test.com',
      role: UserRole.scan,
      displayName: 'Scanner',
    ),
    const UserEntity(
      id: '3',
      email: 'user@test.com',
      role: UserRole.user,
      displayName: 'User',
    ),
  ];

  final updatedUser = const UserEntity(
    id: '2',
    email: 'scan@test.com',
    role: UserRole.admin,
    displayName: 'Scanner',
  );

  setUp(() {
    mockGetAllProfiles = MockGetAllProfiles();
    mockUpdateUserRole = MockUpdateUserRole();
  });

  group('AdminUsersBloc', () {
    test('initial state is AdminUsersInitial', () {
      final bloc = AdminUsersBloc(
        getAllProfiles: mockGetAllProfiles,
        updateUserRole: mockUpdateUserRole,
        currentUserId: '1',
      );
      expect(bloc.state, const AdminUsersInitial());
      bloc.close();
    });

    blocTest<AdminUsersBloc, AdminUsersState>(
      'emits [AdminUsersLoading, AdminUsersLoaded] when LoadAdminUsers succeeds',
      build: () {
        when(() => mockGetAllProfiles())
            .thenAnswer((_) async => Ok(testUsers));
        return AdminUsersBloc(
          getAllProfiles: mockGetAllProfiles,
          updateUserRole: mockUpdateUserRole,
          currentUserId: '1',
        );
      },
      act: (bloc) => bloc.add(const LoadAdminUsers()),
      expect: () => [
        const AdminUsersLoading(),
        isA<AdminUsersLoaded>().having(
          (s) => s.users.length,
          'user count',
          3,
        ),
      ],
    );

    blocTest<AdminUsersBloc, AdminUsersState>(
      'emits [AdminUsersLoading, AdminUsersError] when LoadAdminUsers fails',
      build: () {
        when(() => mockGetAllProfiles())
            .thenAnswer((_) async => Err(ProfileFailure('Error de red')));
        return AdminUsersBloc(
          getAllProfiles: mockGetAllProfiles,
          updateUserRole: mockUpdateUserRole,
          currentUserId: '1',
        );
      },
      act: (bloc) => bloc.add(const LoadAdminUsers()),
      expect: () => [
        const AdminUsersLoading(),
        isA<AdminUsersError>().having(
          (s) => s.message,
          'message',
          contains('Error de red'),
        ),
      ],
    );

    // --- ChangeUserRole tests ---

    group('ChangeUserRole', () {
      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersError when trying to change own role',
        build: () => AdminUsersBloc(
          getAllProfiles: mockGetAllProfiles,
          updateUserRole: mockUpdateUserRole,
          currentUserId: '1',
        ),
        act: (bloc) => bloc.add(const ChangeUserRole(
          targetUserId: '1',
          newRole: 'user',
        )),
        expect: () => [
          const AdminUsersError('No puedes cambiar tu propio rol'),
        ],
      );

      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits [AdminUsersLoaded] with success message on role change',
        build: () {
          when(() => mockUpdateUserRole('2', 'admin'))
              .thenAnswer((_) async => Ok(updatedUser));
          when(() => mockGetAllProfiles())
              .thenAnswer((_) async => Ok(testUsers));
          return AdminUsersBloc(
            getAllProfiles: mockGetAllProfiles,
            updateUserRole: mockUpdateUserRole,
            currentUserId: '1',
          );
        },
        act: (bloc) => bloc.add(const ChangeUserRole(
          targetUserId: '2',
          newRole: 'admin',
        )),
        expect: () => [
          isA<AdminUsersLoaded>().having(
            (s) => s.message,
            'message',
            'Rol cambiado a admin',
          ),
        ],
      );

      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersError when role change fails',
        build: () {
          when(() => mockUpdateUserRole('2', 'admin'))
              .thenAnswer((_) async => Err(ProfileFailure('Permiso denegado')));
          return AdminUsersBloc(
            getAllProfiles: mockGetAllProfiles,
            updateUserRole: mockUpdateUserRole,
            currentUserId: '1',
          );
        },
        act: (bloc) => bloc.add(const ChangeUserRole(
          targetUserId: '2',
          newRole: 'admin',
        )),
        expect: () => [
          isA<AdminUsersError>().having(
            (s) => s.message,
            'message',
            contains('Permiso denegado'),
          ),
        ],
      );
    });

    // --- SuspendUser tests ---

    group('SuspendUser', () {
      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersError when trying to suspend self',
        build: () => AdminUsersBloc(
          getAllProfiles: mockGetAllProfiles,
          updateUserRole: mockUpdateUserRole,
          currentUserId: '1',
        ),
        act: (bloc) => bloc.add(const SuspendUser(targetUserId: '1')),
        expect: () => [
          const AdminUsersError('No puedes suspenderte a ti mismo'),
        ],
      );

      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersLoaded with suspend message when suspending a user',
        build: () {
          when(() => mockUpdateUserRole('3', 'suspended'))
              .thenAnswer((_) async => Ok(testUsers[2].copyWith(role: UserRole.suspended)));
          when(() => mockGetAllProfiles())
              .thenAnswer((_) async => Ok(testUsers));
          return AdminUsersBloc(
            getAllProfiles: mockGetAllProfiles,
            updateUserRole: mockUpdateUserRole,
            currentUserId: '1',
          );
        },
        seed: () => AdminUsersLoaded(testUsers),
        act: (bloc) => bloc.add(const SuspendUser(targetUserId: '3')),
        expect: () => [
          isA<AdminUsersLoaded>().having(
            (s) => s.message,
            'message',
            'Usuario suspendido',
          ),
        ],
      );

      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersLoaded with reactivated message when unsuspending',
        build: () {
          when(() => mockUpdateUserRole('3', 'user'))
              .thenAnswer((_) async => Ok(testUsers[2]));
          when(() => mockGetAllProfiles())
              .thenAnswer((_) async => Ok(testUsers));
          return AdminUsersBloc(
            getAllProfiles: mockGetAllProfiles,
            updateUserRole: mockUpdateUserRole,
            currentUserId: '1',
          );
        },
        seed: () => AdminUsersLoaded([
          testUsers[0],
          testUsers[1],
          testUsers[2].copyWith(role: UserRole.suspended),
        ]),
        act: (bloc) => bloc.add(const SuspendUser(targetUserId: '3')),
        expect: () => [
          isA<AdminUsersLoaded>().having(
            (s) => s.message,
            'message',
            'Usuario reactivado',
          ),
        ],
      );

      blocTest<AdminUsersBloc, AdminUsersState>(
        'emits AdminUsersError when suspend API fails',
        build: () {
          when(() => mockUpdateUserRole('3', 'suspended'))
              .thenAnswer((_) async => Err(ProfileFailure('Error de red')));
          return AdminUsersBloc(
            getAllProfiles: mockGetAllProfiles,
            updateUserRole: mockUpdateUserRole,
            currentUserId: '1',
          );
        },
        seed: () => AdminUsersLoaded(testUsers),
        act: (bloc) => bloc.add(const SuspendUser(targetUserId: '3')),
        expect: () => [
          isA<AdminUsersError>().having(
            (s) => s.message,
            'message',
            contains('Error de red'),
          ),
        ],
      );
    });
  });
}
