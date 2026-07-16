import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_state.dart';

class MockGetAllProfiles extends Mock implements GetAllProfiles {}

void main() {
  late MockGetAllProfiles mockGetAllProfiles;

  final testUsers = [
    const UserEntity(
      id: '1',
      email: 'admin@test.com',
      role: 'admin',
      displayName: 'Admin',
    ),
    const UserEntity(
      id: '2',
      email: 'scan@test.com',
      role: 'scan',
      displayName: 'Scanner',
    ),
  ];

  setUp(() {
    mockGetAllProfiles = MockGetAllProfiles();
  });

  group('AdminUsersBloc', () {
    test('initial state is AdminUsersInitial', () {
      final bloc = AdminUsersBloc(getAllProfiles: mockGetAllProfiles);
      expect(bloc.state, const AdminUsersInitial());
      bloc.close();
    });

    blocTest<AdminUsersBloc, AdminUsersState>(
      'emits [AdminUsersLoading, AdminUsersLoaded] when LoadAdminUsers succeeds',
      build: () {
        when(() => mockGetAllProfiles()).thenAnswer((_) async => Ok(testUsers));
        return AdminUsersBloc(getAllProfiles: mockGetAllProfiles);
      },
      act: (bloc) => bloc.add(const LoadAdminUsers()),
      expect: () => [
        const AdminUsersLoading(),
        isA<AdminUsersLoaded>().having(
          (s) => s.users.length,
          'user count',
          2,
        ),
      ],
    );

    blocTest<AdminUsersBloc, AdminUsersState>(
      'emits [AdminUsersLoading, AdminUsersError] when LoadAdminUsers fails',
      build: () {
        when(() => mockGetAllProfiles())
            .thenAnswer((_) async => Err(ProfileFailure('Error de red')));
        return AdminUsersBloc(getAllProfiles: mockGetAllProfiles);
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
  });
}
