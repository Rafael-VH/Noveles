import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/auth/data/auth_repository_impl.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// ignore: must_be_immutable
class MockFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {
  PostgrestList? _data;

  void thenReturns(PostgrestList data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

// ignore: must_be_immutable
class MockTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final _queue = <Map<String, dynamic>?>[];
  int _callIndex = 0;

  void thenReturns(Map<String, dynamic>? data) {
    _queue.add(data);
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>? value) onValue, {
    Function? onError,
  }) async {
    final data =
        _callIndex < _queue.length ? _queue[_callIndex] : _queue.last;
    _callIndex++;
    final result = onValue(data);
    if (result is Future<U>) return result;
    return result;
  }
}

void main() {
  late MockSupabaseClientProvider mockProvider;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockFilterBuilder mockFilter;
  late MockTransformBuilder mockTransform;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();

    when(() => mockProvider.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);

    repository = AuthRepositoryImpl(mockProvider);

    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.eq(any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.maybeSingle()).thenAnswer((_) => mockTransform);
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('AuthRepositoryImpl', () {
    final gotrueUser = User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: null,
      aud: '',
      createdAt: '2024-01-01T00:00:00.000',
      email: 'test@example.com',
      role: '',
      isAnonymous: false,
    );

    final gotrueSession = Session(
      accessToken: 'token',
      tokenType: 'bearer',
      user: User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: null,
        aud: '',
        createdAt: '2024-01-01T00:00:00.000',
        email: 'test@example.com',
        role: '',
        isAnonymous: false,
      ),
    );

    group('login', () {
      test('returns UserEntity on success', () async {
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: gotrueUser));
        mockTransform.thenReturns({
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

      test('returns Err when user is null', () async {
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: null));

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al iniciar sesión'));
      });

      test('creates profile on first login when profile is null', () async {
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: gotrueUser));
        // Call 1 maybeSingle: no profile exists
        mockTransform.thenReturns(null);
        // Call 3 maybeSingle: verification after insert returns new profile
        mockTransform.thenReturns({
          'id': 'user-1',
          'role': 'user',
        });
        // insert() returns mockFilter; resolve the await with empty list
        mockFilter.thenReturns(<Map<String, dynamic>>[]);

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.role, UserRole.user);
        // Profile insert should have been called
        verify(() => mockQueryBuilder.insert(
              any(),
              defaultToNull: any(named: 'defaultToNull'),
            )).called(1);
      });

      test('returns Err on auth failure', () async {
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Auth error'));

        final result = await repository.login('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al iniciar sesión'));
      });
    });

    group('register', () {
      test('returns UserEntity on success', () async {
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: gotrueUser));
        mockTransform.thenReturns({
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

      test('returns Err when user is null', () async {
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => AuthResponse(user: null));

        final result = await repository.register('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al registrarse'));
      });

      test('returns Err on auth failure', () async {
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Auth error'));

        final result = await repository.register('test@example.com', 'password');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al registrarse'));
      });
    });

    group('logout', () {
      test('returns Ok on success', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async => Future.value());

        final result = await repository.logout();

        expect(result, isA<Ok<void>>());
        verify(() => mockAuth.signOut()).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockAuth.signOut()).thenThrow(Exception('Logout error'));

        final result = await repository.logout();

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cerrar sesión'));
      });
    });

    group('getCurrentUser', () {
      test('returns UserEntity when logged in', () async {
        when(() => mockAuth.currentSession).thenReturn(gotrueSession);
        when(() => mockAuth.currentUser).thenReturn(gotrueUser);
        mockTransform.thenReturns({
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

      test('returns null when not logged in', () async {
        when(() => mockAuth.currentSession).thenReturn(null);
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await repository.getCurrentUser();

        expect(result, isA<Ok<UserEntity?>>());
        final value = (result as Ok<UserEntity?>).value;
        expect(value, isNull);
      });

      test('returns Err on profile error', () async {
        when(() => mockAuth.currentSession).thenReturn(gotrueSession);
        when(() => mockAuth.currentUser).thenReturn(gotrueUser);
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Profile error'));

        final result = await repository.getCurrentUser();

        expect(result, isA<Err<UserEntity?>>());
        final error = (result as Err<UserEntity?>).error;
        expect(error.message, contains('Error al obtener perfil'));
      });
    });

    group('onAuthStateChange', () {
      test('maps signedIn event', () async {
        final controller = StreamController<AuthState>();
        when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

        final stream = repository.onAuthStateChange();
        final futures = stream.take(1).toList();

        controller.add(AuthState(AuthChangeEvent.signedIn, null));
        await controller.close();

        final events = await futures;
        expect(events.first, AuthEvent.signedIn);
      });

      test('maps signedOut event', () async {
        final controller = StreamController<AuthState>();
        when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

        final stream = repository.onAuthStateChange();
        final futures = stream.take(1).toList();

        controller.add(AuthState(AuthChangeEvent.signedOut, null));
        await controller.close();

        final events = await futures;
        expect(events.first, AuthEvent.signedOut);
      });

      test('maps tokenRefreshed event', () async {
        final controller = StreamController<AuthState>();
        when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

        final stream = repository.onAuthStateChange();
        final futures = stream.take(1).toList();

        controller.add(AuthState(AuthChangeEvent.tokenRefreshed, null));
        await controller.close();

        final events = await futures;
        expect(events.first, AuthEvent.tokenRefreshed);
      });

      test('handles stream errors by emitting signedOut', () async {
        final controller = StreamController<AuthState>();
        when(() => mockAuth.onAuthStateChange).thenAnswer((_) => controller.stream);

        final stream = repository.onAuthStateChange();
        final futures = stream.take(1).toList();

        controller.addError(Exception('Stream error'));
        await controller.close();

        final events = await futures;
        expect(events.first, AuthEvent.signedOut);
      });
    });
  });
}
