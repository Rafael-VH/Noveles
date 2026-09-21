import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/auth_identity.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/data/auth_repository_impl.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late AuthRepositoryImpl repository;

  const identity = AuthIdentity(id: 'user-1', email: 'test@example.com');
  const profileRow = {'id': 'user-1', 'role': 'user'};

  setUp(() {
    backend = FakeBackend();
    repository = AuthRepositoryImpl(backend.auth, backend.data);
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test('returns UserEntity on success', () async {
        when(() => backend.auth.signIn('test@example.com', 'password'))
            .thenAnswer((_) async => identity);
        backend.maybeRow('profiles', {
          'id': 'user-1',
          'email': 'test@example.com',
          'role': 'user',
        });

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.email, 'test@example.com');
        expect(value.role, UserRole.user);
      });

      test('returns Err when the backend reports no user', () async {
        when(() => backend.auth.signIn(any(), any()))
            .thenAnswer((_) async => null);

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al iniciar sesión'));
      });

      test('creates the profile on first login when it is missing', () async {
        when(() => backend.auth.signIn('test@example.com', 'password'))
            .thenAnswer((_) async => identity);
        // Read 1: no profile yet. Read 2: the verification after the insert.
        final reads = <Map<String, dynamic>?>[null, profileRow];
        var read = 0;
        when(() => backend.query('profiles').maybeRow())
            .thenAnswer((_) async => reads[read++]);
        backend.insertOk('profiles');

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.role, UserRole.user);
        final created = backend.capturedInsert('profiles');
        expect(created['id'], 'user-1');
        expect(created['role'], UserRole.user.name);
      });

      test('returns Err on auth failure', () async {
        when(() => backend.auth.signIn(any(), any()))
            .thenThrow(Exception('Auth error'));

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al iniciar sesión'));
      });
    });

    group('register', () {
      test('returns UserEntity on success', () async {
        when(() => backend.auth.signUp('test@example.com', 'password'))
            .thenAnswer((_) async => identity);
        backend.maybeRow('profiles', {
          'id': 'user-1',
          'email': 'test@example.com',
          'role': 'user',
        });

        final result = await repository.register('test@example.com', 'password');

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.email, 'test@example.com');
      });

      test('returns Err when the backend reports no user', () async {
        when(() => backend.auth.signUp(any(), any()))
            .thenAnswer((_) async => null);

        final result = await repository.register('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al registrarse'));
      });

      test('returns Err on auth failure', () async {
        when(() => backend.auth.signUp(any(), any()))
            .thenThrow(Exception('Auth error'));

        final result = await repository.register('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al registrarse'));
      });
    });

    group('logout', () {
      test('returns Ok on success', () async {
        when(() => backend.auth.signOut()).thenAnswer((_) async {});

        final result = await repository.logout();

        expect(result, isA<Ok<void>>());
        verify(() => backend.auth.signOut()).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.auth.signOut())
            .thenThrow(Exception('Logout error'));

        final result = await repository.logout();

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cerrar sesión'));
      });
    });

    group('getCurrentUser', () {
      test('returns UserEntity when there is a session', () async {
        backend.signedInAs('user-1', email: 'test@example.com');
        backend.maybeRow('profiles', {
          'id': 'user-1',
          'email': 'test@example.com',
          'role': 'user',
        });

        final result = await repository.getCurrentUser();

        expect(result, isA<Ok<UserEntity?>>());
        final value = (result as Ok<UserEntity?>).value;
        expect(value, isNotNull);
        expect(value!.id, 'user-1');
      });

      test('returns null when there is no session', () async {
        final result = await repository.getCurrentUser();

        expect(result, isA<Ok<UserEntity?>>());
        expect((result as Ok<UserEntity?>).value, isNull);
      });

      test('returns Err on profile error', () async {
        backend.signedInAs('user-1', email: 'test@example.com');
        when(() => backend.query('profiles').eq(any(), any()))
            .thenThrow(Exception('Profile error'));

        final result = await repository.getCurrentUser();

        expect(result, isA<Err<UserEntity?>>());
        final error = (result as Err<UserEntity?>).error;
        expect(error.message, contains('Error al obtener perfil'));
      });
    });

    group('onAuthStateChange', () {
      late StreamController<AuthIdentityEvent> controller;

      setUp(() {
        controller = StreamController<AuthIdentityEvent>();
        when(() => backend.auth.stateChanges())
            .thenAnswer((_) => controller.stream);
      });

      tearDown(() => controller.close());

      test('maps signedIn event', () async {
        final events = repository.onAuthStateChange().take(1).toList();

        controller.add(AuthIdentityEvent.signedIn);

        expect((await events).first, AuthEvent.signedIn);
      });

      test('maps signedOut event', () async {
        final events = repository.onAuthStateChange().take(1).toList();

        controller.add(AuthIdentityEvent.signedOut);

        expect((await events).first, AuthEvent.signedOut);
      });

      test('maps tokenRefreshed event', () async {
        final events = repository.onAuthStateChange().take(1).toList();

        controller.add(AuthIdentityEvent.tokenRefreshed);

        expect((await events).first, AuthEvent.tokenRefreshed);
      });

      test('maps unknown events to userChanged', () async {
        final events = repository.onAuthStateChange().take(1).toList();

        controller.add(AuthIdentityEvent.unknown);

        expect((await events).first, AuthEvent.userChanged);
      });

      test('handles stream errors by emitting authError', () async {
        final events = repository.onAuthStateChange().take(1).toList();

        controller.addError(Exception('Stream error'));

        expect((await events).first, AuthEvent.authError);
      });
    });
  });
}
