import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_bloc.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_event.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

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
  late StreamController<AuthChangeEvent> authStateController;

  final testUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    role: 'user',
    displayName: 'Test User',
    bio: 'Bio',
    avatarUrl: null,
  );

  setUp(() {
    mockLogin = MockLogin();
    mockRegister = MockRegister();
    mockLogout = MockLogout();
    mockGetCurrentUser = MockGetCurrentUser();
    mockListenAuthState = MockListenAuthState();
    authStateController = StreamController<AuthChangeEvent>();
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
            .thenAnswer((_) async => testUser);
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
            .thenThrow(Exception('Invalid credentials'));
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
            .thenAnswer((_) async => testUser);
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
            .thenThrow(Exception('Email taken'));
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
        when(() => mockLogout()).thenAnswer((_) async {});
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
        when(() => mockLogout()).thenThrow(Exception('Error'));
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
        when(() => mockGetCurrentUser())
            .thenAnswer((_) async => testUser);
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
        when(() => mockGetCurrentUser())
            .thenAnswer((_) async => null);
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
      'emits [AuthLoading, AuthUnauthenticated] when CheckAuthSession throws',
      build: () {
        when(() => mockGetCurrentUser())
            .thenThrow(Exception('Error'));
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
  });
}
