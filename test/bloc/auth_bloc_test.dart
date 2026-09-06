import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart' as domain;
import 'package:noveles/features/auth/domain/use_cases/login.dart';
import 'package:noveles/features/auth/domain/use_cases/register.dart';
import 'package:noveles/features/auth/domain/use_cases/logout.dart';
import 'package:noveles/features/auth/domain/use_cases/get_current_user.dart';
import 'package:noveles/features/auth/domain/use_cases/listen_auth_state.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';

class MockLogin extends Mock implements Login {}

class MockRegister extends Mock implements Register {}

class MockLogout extends Mock implements Logout {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockListenAuthState extends Mock implements ListenAuthState {}

void main() {
  late MockLogin mockLogin;
  late MockRegister mockRegister;
  late MockLogout mockLogout;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockListenAuthState mockListenAuthState;
  late StreamController<domain.AuthEvent> authStateController;

  const testUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    role: UserRole.user,
    displayName: 'Test User',
    bio: 'Bio',
    avatarUrl: null,
  );

  const suspendedUser = UserEntity(
    id: '2',
    email: 'suspended@example.com',
    role: UserRole.suspended,
  );

  const unknownRoleUser = UserEntity(
    id: '3',
    email: 'weird@example.com',
    role: UserRole.unknown,
  );

  setUp(() {
    mockLogin = MockLogin();
    mockRegister = MockRegister();
    mockLogout = MockLogout();
    mockGetCurrentUser = MockGetCurrentUser();
    mockListenAuthState = MockListenAuthState();
    authStateController = StreamController<domain.AuthEvent>();
    when(() => mockListenAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      final bloc = AuthBloc(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        getCurrentUser: mockGetCurrentUser,
        listenAuthState: mockListenAuthState,
      );
      expect(bloc.state, equals(AuthInitial()));
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when LoginRequested succeeds',
      build: () {
        when(() => mockLogin('a@b.com', 'pass'))
            .thenAnswer((_) async => const Ok(testUser));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(LoginRequested('a@b.com', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested fails',
      build: () {
        when(() => mockLogin('a@b.com', 'wrong'))
            .thenAnswer((_) async => const Err<UserEntity>(AuthFailure('Invalid credentials')));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(LoginRequested('a@b.com', 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          contains('Invalid credentials'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when RegisterRequested succeeds',
      build: () {
        when(() => mockRegister('a@b.com', 'pass'))
            .thenAnswer((_) async => const Ok(testUser));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(RegisterRequested('a@b.com', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when RegisterRequested fails',
      build: () {
        when(() => mockRegister('a@b.com', 'pass'))
            .thenAnswer((_) async => const Err<UserEntity>(AuthFailure('Email taken')));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(RegisterRequested('a@b.com', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          contains('Email taken'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when LogoutRequested succeeds',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Ok(null));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LogoutRequested fails',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Err<void>(AuthFailure('Error')));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          contains('Error'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when CheckAuthSession has user',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer((_) async => const Ok(testUser));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(CheckAuthSession()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.email,
          'email',
          'test@example.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when CheckAuthSession has no user',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer((_) async => const Ok(null));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(CheckAuthSession()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when CheckAuthSession fails',
      build: () {
        when(() => mockGetCurrentUser()).thenAnswer((_) async => const Err<UserEntity?>(AuthFailure('Error')));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(CheckAuthSession()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
          (s) => s.message,
          'message',
          contains('Error'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuspended] and signs out when login returns a suspended user',
      build: () {
        when(() => mockLogin('s@x.com', 'pass'))
            .thenAnswer((_) async => const Ok(suspendedUser));
        when(() => mockLogout()).thenAnswer((_) async => const Ok(null));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(LoginRequested('s@x.com', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuspended>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (bloc) {
        // A suspended user must be signed out so the stale session cannot be used.
        verify(() => mockLogout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuspended] and signs out when the profile role is unknown',
      build: () {
        when(() => mockGetCurrentUser())
            .thenAnswer((_) async => const Ok(unknownRoleUser));
        when(() => mockLogout()).thenAnswer((_) async => const Ok(null));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) => bloc.add(CheckAuthSession()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuspended>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    // --- P0: C2 race condition guard ---

    test('second LogoutRequested during active logout is a no-op', () async {
      final completer = Completer<void>();
      when(() => mockLogout()).thenAnswer((_) async {
        await completer.future;
        return const Ok(null);
      });

      final bloc = AuthBloc(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        getCurrentUser: mockGetCurrentUser,
        listenAuthState: mockListenAuthState,
      );

      // Start manual logout — sets _manualLogoutInProgress = true
      bloc.add(const LogoutRequested());
      await Future<void>.delayed(Duration.zero);

      // Stream fires signedOut while logout is in progress
      authStateController.add(domain.AuthEvent.signedOut);
      await Future<void>.delayed(Duration.zero);

      // Complete the slow logout
      completer.complete();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Only one logout call — the stream event was guarded
      expect(bloc.state, isA<AuthUnauthenticated>());
      verify(() => mockLogout()).called(1);

      await bloc.close();
    });

    // --- P1: stream auto-logout ---

    blocTest<AuthBloc, AuthState>(
      'Stream signedOut event triggers automatic LogoutRequested',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Ok(null));
        return AuthBloc(
          login: mockLogin,
          register: mockRegister,
          logout: mockLogout,
          getCurrentUser: mockGetCurrentUser,
          listenAuthState: mockListenAuthState,
        );
      },
      act: (bloc) async {
        // Let the subscription activate
        await Future<void>.delayed(Duration.zero);
        // Fire signedOut from the stream
        authStateController.add(domain.AuthEvent.signedOut);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (bloc) {
        verify(() => mockLogout()).called(1);
      },
    );

    test('Stream userChanged event re-fetches the profile without logging out',
        () async {
      when(() => mockGetCurrentUser())
          .thenAnswer((_) async => const Ok(testUser));

      final bloc = AuthBloc(
        login: mockLogin,
        register: mockRegister,
        logout: mockLogout,
        getCurrentUser: mockGetCurrentUser,
        listenAuthState: mockListenAuthState,
      );

      // Establish an authenticated session first.
      bloc.add(CheckAuthSession());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<AuthAuthenticated>());

      // Fire userChanged (e.g. profile update): must NOT sign out, but refetch.
      authStateController.add(domain.AuthEvent.userChanged);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state, isA<AuthAuthenticated>());
      verify(() => mockGetCurrentUser()).called(2);
      verifyNever(() => mockLogout());

      await bloc.close();
    });
  });
}
