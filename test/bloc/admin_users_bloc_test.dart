import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/get_all_profiles.dart';
import 'package:noveles/features/presentation/bloc/admin_users/admin_users_bloc.dart';
import 'package:noveles/features/presentation/bloc/admin_users/admin_users_event.dart';
import 'package:noveles/features/presentation/bloc/admin_users/admin_users_state.dart';

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
        when(() => mockGetAllProfiles()).thenAnswer((_) async => testUsers);
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
        when(() => mockGetAllProfiles()).thenThrow(Exception('Error de red'));
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
