import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/profiles/data/profiles_repository_impl.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClientProvider extends Mock implements SupabaseClientProvider {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

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
  Map<String, dynamic>? _data;

  void thenReturns(Map<String, dynamic>? data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>? value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data);
    if (result is Future<U>) return result;
    return result;
  }
}

/// Mock for PostgrestTransformBuilder<List<Map<String, dynamic>>> — used by
/// filterBuilder.select() in the update().eq().select().maybeSingle() chain.
// ignore: must_be_immutable
class MockSelectBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>>? _data;

  void thenReturns(List<Map<String, dynamic>> data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
    if (result is Future<U>) return result;
    return result;
  }
}

/// Mock for PostgrestTransformBuilder<Map<String, dynamic>> — used by
/// .select().single() in updateUserRole.
// ignore: must_be_immutable
class MockSingleBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  Map<String, dynamic>? _data;

  void thenReturns(Map<String, dynamic> data) {
    _data = data;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) async {
    final result = onValue(_data!);
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
  late MockSelectBuilder mockSelectBuilder;
  late MockSingleBuilder mockSingleBuilder;
  late MockSupabaseStorageClient mockStorage;
  late MockStorageFileApi mockStorageFileApi;
  late ProfilesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(FileOptions());
    registerFallbackValue(UserAttributes(password: ''));
  });

  setUp(() {
    mockProvider = MockSupabaseClientProvider();
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilter = MockFilterBuilder();
    mockTransform = MockTransformBuilder();
    mockSelectBuilder = MockSelectBuilder();
    mockSingleBuilder = MockSingleBuilder();
    mockStorage = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();

    when(() => mockProvider.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockClient.storage).thenReturn(mockStorage);

    repository = ProfilesRepositoryImpl(mockProvider);

    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.insert(
          any(),
          defaultToNull: any(named: 'defaultToNull'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockFilter);
    when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockFilter);
    when(() => mockFilter.eq(any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.gt(any(), any())).thenAnswer((_) => mockFilter);
    when(() => mockFilter.order(
          any(),
          ascending: any(named: 'ascending'),
          nullsFirst: any(named: 'nullsFirst'),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.limit(
          any(),
          referencedTable: any(named: 'referencedTable'),
        )).thenAnswer((_) => mockFilter);
    when(() => mockFilter.maybeSingle()).thenAnswer((_) => mockTransform);
    when(() => mockFilter.select(any())).thenAnswer((_) => mockSelectBuilder);
    when(() => mockSelectBuilder.maybeSingle()).thenAnswer((_) => mockTransform);
    when(() => mockSelectBuilder.single()).thenAnswer((_) => mockSingleBuilder);
  });

  tearDown(() {
    // No cleanup needed - setUp reinitializes all mocks
  });

  group('ProfilesRepositoryImpl', () {
    final testUser = User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: null,
      aud: '',
      createdAt: '2024-01-01T00:00:00.000',
      email: 'test@example.com',
      role: '',
      isAnonymous: false,
    );

    group('getProfile', () {
      test('returns UserEntity on success', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        mockTransform.thenReturns({
          'id': 'user-1',
          'email': 'test@example.com',
          'role': 'user',
          'display_name': 'Test User',
          'bio': 'Bio',
          'avatar_url': null,
        });

        final result = await repository.getProfile();

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.displayName, 'Test User');
      });

      test('returns Err when no session', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await repository.getProfile();
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err when profile not found', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        mockTransform.thenReturns(null);

        final result = await repository.getProfile();
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No se encontró el perfil'));
      });

      test('returns Err on error', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getProfile();
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al obtener perfil'));
      });
    });

    group('updateProfile', () {
      test('returns UserEntity on success', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        mockTransform.thenReturns({
          'id': 'user-1',
          'email': 'test@example.com',
          'role': 'user',
          'display_name': 'Updated',
          'bio': 'New bio',
          'avatar_url': null,
        });

        final result = await repository.updateProfile(
          displayName: 'Updated',
          bio: 'New bio',
        );

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.displayName, 'Updated');
        expect(value.bio, 'New bio');
      });

      test('returns Err when no session', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await repository.updateProfile(displayName: 'Test');
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err when profile not found after update', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        mockTransform.thenReturns(null);

        final result = await repository.updateProfile(displayName: 'Test');
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No se encontró el perfil'));
      });

      test('returns Err on error', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        when(() => mockFilter.eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateProfile(displayName: 'Test');
        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al actualizar perfil'));
      });
    });

    group('uploadAvatar', () {
      test('returns URL on success', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        when(() => mockStorage.from('avatars')).thenReturn(mockStorageFileApi);
        when(() => mockStorageFileApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenAnswer((_) async => 'user-1/avatar.jpg');
        when(() => mockStorageFileApi.getPublicUrl(any()))
            .thenReturn('https://example.com/avatar.jpg');

        final tempDir = Directory.systemTemp.createTempSync('avatar_test_');
        final tempFile = File('${tempDir.path}/test.jpg');
        await tempFile.writeAsString('fake image data');
        final filePath = tempFile.path;

        final result = await repository.uploadAvatar(filePath);

        expect(result, isA<Ok<String>>());
        final value = (result as Ok<String>).value;
        expect(value, contains('https://example.com/avatar.jpg'));

        await tempFile.delete();
        await tempDir.delete(recursive: true);
      });

      test('returns Err when no session', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await repository.uploadAvatar('test.jpg');
        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err on storage error', () async {
        when(() => mockAuth.currentUser).thenReturn(testUser);
        when(() => mockStorage.from('avatars')).thenReturn(mockStorageFileApi);
        when(() => mockStorageFileApi.upload(
              any(),
              any(),
              fileOptions: any(named: 'fileOptions'),
            )).thenThrow(Exception('Upload failed'));

        final result = await repository.uploadAvatar('test.jpg');
        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al subir avatar'));
      });
    });

    group('changePassword', () {
      test('returns Ok on success', () async {
        when(() => mockAuth.updateUser(any()))
            .thenAnswer((_) async => UserResponse.fromJson({
                  'id': 'user-1',
                }));

        final result = await repository.changePassword('newPass123');

        expect(result, isA<Ok<void>>());
        verify(() => mockAuth.updateUser(any())).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockAuth.updateUser(any()))
            .thenThrow(Exception('Password change failed'));

        final result = await repository.changePassword('newPass123');
        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cambiar contraseña'));
      });
    });

    group('getAllProfiles', () {
      test('returns list of UserEntity on success', () async {
        mockFilter.thenReturns([
          {
            'id': 'user-1',
            'email': 'user1@example.com',
            'role': 'user',
            'display_name': 'User 1',
            'bio': null,
            'avatar_url': null,
          },
          {
            'id': 'user-2',
            'email': 'user2@example.com',
            'role': 'admin',
            'display_name': 'User 2',
            'bio': null,
            'avatar_url': null,
          },
        ]);

        final result = await repository.getAllProfiles();

        expect(result, isA<Ok<List<UserEntity>>>());
        final value = (result as Ok<List<UserEntity>>).value;
        expect(value.length, 2);
        expect(value[0].email, 'user1@example.com');
        expect(value[1].role, 'admin');
        verify(() => mockClient.from('profiles')).called(1);
      });

      test('returns Err on error', () async {
        when(() => mockFilter.order(
              any(),
              ascending: any(named: 'ascending'),
              nullsFirst: any(named: 'nullsFirst'),
              referencedTable: any(named: 'referencedTable'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getAllProfiles();
        expect(result, isA<Err<List<UserEntity>>>());
        final error = (result as Err<List<UserEntity>>).error;
        expect(error.message, contains('Error al obtener perfiles'));
      });

      test('paginates with afterEmail parameter', () async {
        mockFilter.thenReturns([
          {
            'id': 'user-3',
            'email': 'user3@example.com',
            'role': 'user',
            'display_name': 'User 3',
            'bio': null,
            'avatar_url': null,
          },
        ]);

        final result = await repository.getAllProfiles(
          limit: 1,
          afterEmail: 'user2@example.com',
        );

        expect(result, isA<Ok<List<UserEntity>>>());
        final value = (result as Ok<List<UserEntity>>).value;
        expect(value.length, 1);
        expect(value[0].email, 'user3@example.com');
        verify(() => mockFilter.gt('email', 'user2@example.com')).called(1);
      });

      test('hasMore is true when extra record fetched', () async {
        mockFilter.thenReturns([
          {
            'id': 'user-3',
            'email': 'user3@example.com',
            'role': 'user',
            'display_name': 'User 3',
            'bio': null,
            'avatar_url': null,
          },
          {
            'id': 'user-4',
            'email': 'user4@example.com',
            'role': 'scan',
            'display_name': 'User 4',
            'bio': null,
            'avatar_url': null,
          },
        ]);

        final result = await repository.getAllProfiles(limit: 1);

        expect(result, isA<Ok<List<UserEntity>>>());
        final value = (result as Ok<List<UserEntity>>).value;
        // limit=1 but got 2 records, so only 1 returned
        expect(value.length, 1);
      });
    });

    group('updateUserRole', () {
      test('returns updated UserEntity on success', () async {
        mockSingleBuilder.thenReturns({
          'id': 'user-2',
          'email': 'scan@test.com',
          'role': 'admin',
          'display_name': 'Scanner',
          'bio': null,
          'avatar_url': null,
        });

        final result = await repository.updateUserRole(
          userId: 'user-2',
          role: 'admin',
        );

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-2');
        expect(value.role, 'admin');
        verify(() => mockFilter.eq('id', 'user-2')).called(1);
      });

      test('returns Err on database error', () async {
        when(() => mockSelectBuilder.single())
            .thenThrow(Exception('DB error'));

        final result = await repository.updateUserRole(
          userId: 'user-2',
          role: 'admin',
        );

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al cambiar rol'));
      });
    });
  });
}
