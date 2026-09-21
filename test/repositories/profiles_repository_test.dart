import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/profiles/data/profiles_repository_impl.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

import '../utils/backend_mocks.dart';

void main() {
  late FakeBackend backend;
  late ProfilesRepositoryImpl repository;

  Map<String, dynamic> profileJson({
    String displayName = 'Test User',
    String? bio = 'Bio',
    String role = 'user',
  }) =>
      {
        'id': 'user-1',
        'email': 'test@example.com',
        'role': role,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': null,
      };

  setUp(() {
    backend = FakeBackend();
    repository = ProfilesRepositoryImpl(
      backend.data,
      backend.storage,
      backend.auth,
    );
  });

  group('ProfilesRepositoryImpl', () {
    group('getProfile', () {
      test('returns UserEntity on success', () async {
        backend.signedInAs('user-1');
        backend.maybeRow('profiles', profileJson());

        final result = await repository.getProfile();

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.id, 'user-1');
        expect(value.displayName, 'Test User');
      });

      test('returns Err when no session', () async {
        final result = await repository.getProfile();

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err when profile not found', () async {
        backend.signedInAs('user-1');
        backend.maybeRow('profiles', null);

        final result = await repository.getProfile();

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No se encontró el perfil'));
      });

      test('returns Err on error', () async {
        backend.signedInAs('user-1');
        when(() => backend.query('profiles').eq(any(), any()))
            .thenThrow(Exception('DB error'));

        final result = await repository.getProfile();

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al obtener perfil'));
      });
    });

    group('updateProfile', () {
      test('returns the updated profile', () async {
        backend.signedInAs('user-1');
        backend.updateReturning(
          'profiles',
          profileJson(displayName: 'Updated', bio: 'New bio'),
        );

        final result = await repository.updateProfile(
          displayName: 'Updated',
          bio: 'New bio',
        );

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.displayName, 'Updated');
        expect(value.bio, 'New bio');
        final sent = backend.capturedUpdateReturning('profiles');
        expect(sent, {'display_name': 'Updated', 'bio': 'New bio'});
      });

      test('returns Err when no session', () async {
        final result = await repository.updateProfile(displayName: 'Test');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err when the update returns no row', () async {
        backend.signedInAs('user-1');
        backend.updateReturning('profiles', null);

        final result = await repository.updateProfile(displayName: 'Test');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('No se encontró el perfil'));
      });

      test('returns Err on error', () async {
        backend.signedInAs('user-1');
        when(() => backend.query('profiles').eq(any(), any()))
            .thenThrow(Exception('Update failed'));

        final result = await repository.updateProfile(displayName: 'Test');

        expect(result, isA<Err<UserEntity>>());
        final error = (result as Err<UserEntity>).error;
        expect(error.message, contains('Error al actualizar perfil'));
      });
    });

    group('uploadAvatar', () {
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('avatar_test_');
      });

      tearDown(() => tempDir.deleteSync(recursive: true));

      File writeAvatar() {
        final file = File('${tempDir.path}/avatar.jpg');
        file.writeAsStringSync('fake image data');
        return file;
      }

      test('returns a cache-busted URL on success', () async {
        backend.signedInAs('user-1');
        backend.uploadOkUpsert();
        when(() => backend.storage.publicUrl('avatars', any()))
            .thenReturn('https://example.com/avatar.jpg');

        final result = await repository.uploadAvatar(writeAvatar().path);

        expect(result, isA<Ok<String>>());
        final value = (result as Ok<String>).value;
        expect(value, contains('https://example.com/avatar.jpg'));
        verify(() => backend.storage.upload(
              'avatars',
              'user-1/avatar.jpg',
              any(),
              upsert: true,
            )).called(1);
      });

      test('returns Err when no session', () async {
        final result = await repository.uploadAvatar('test.jpg');

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('No hay sesión activa'));
      });

      test('returns Err for a rejected extension', () async {
        backend.signedInAs('user-1');

        final result = await repository.uploadAvatar('test.gif');

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Formato no permitido'));
      });

      test('returns Err on storage error', () async {
        backend.signedInAs('user-1');
        when(() => backend.storage.upload(
              any(),
              any(),
              any(),
              upsert: any(named: 'upsert'),
            )).thenThrow(Exception('Upload failed'));

        final result = await repository.uploadAvatar(writeAvatar().path);

        expect(result, isA<Err<String>>());
        final error = (result as Err<String>).error;
        expect(error.message, contains('Error al subir avatar'));
      });
    });

    group('changePassword', () {
      test('returns Ok on success', () async {
        when(() => backend.auth.updatePassword(any())).thenAnswer((_) async {});

        final result = await repository.changePassword('newPass123');

        expect(result, isA<Ok<void>>());
        verify(() => backend.auth.updatePassword('newPass123')).called(1);
      });

      test('returns Err on error', () async {
        when(() => backend.auth.updatePassword(any()))
            .thenThrow(Exception('Password change failed'));

        final result = await repository.changePassword('newPass123');

        expect(result, isA<Err<void>>());
        final error = (result as Err<void>).error;
        expect(error.message, contains('Error al cambiar contraseña'));
      });
    });

    group('getAllProfiles', () {
      test('returns list of UserEntity on success', () async {
        backend.rows('profiles', [
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
        expect(value[1].role, UserRole.admin);
      });

      test('returns Err on error', () async {
        when(() => backend.query('profiles').order(
              any(),
              ascending: any(named: 'ascending'),
            )).thenThrow(Exception('DB error'));

        final result = await repository.getAllProfiles();

        expect(result, isA<Err<List<UserEntity>>>());
        final error = (result as Err<List<UserEntity>>).error;
        expect(error.message, contains('Error al obtener perfiles'));
      });

      test('orders by created_at ascending and over-fetches by one', () async {
        backend.rows('profiles', [
          {
            'id': 'user-1',
            'email': 'user1@example.com',
            'role': 'user',
            'display_name': 'User 1',
            'bio': null,
            'avatar_url': null,
          },
        ]);

        final result = await repository.getAllProfiles(limit: 1);

        expect(result, isA<Ok<List<UserEntity>>>());
        expect((result as Ok<List<UserEntity>>).value.length, 1);
        verify(() => backend.query('profiles')
            .order('created_at', ascending: true)).called(1);
        verify(() => backend.query('profiles').limit(2)).called(1);
      });

      test('trims the extra probe row used to detect more pages', () async {
        backend.rows('profiles', [
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
        // limit=1 but 2 rows came back, so only the first is exposed.
        expect((result as Ok<List<UserEntity>>).value.length, 1);
      });
    });

    group('updateUserRole', () {
      test('suspends through the admin RPC and returns the refreshed profile',
          () async {
        when(() => backend.data.rpc('admin_suspend_user',
                params: {'target_uid': 'user-2'}))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        backend.oneRow('profiles', profileJson(role: 'suspended'));

        final result = await repository.updateUserRole(
          userId: 'user-2',
          role: UserRole.suspended.name,
        );

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.role, UserRole.suspended);
        verify(() => backend.data.rpc('admin_suspend_user',
            params: {'target_uid': 'user-2'})).called(1);
      });

      test('reactivates through the admin RPC and returns the refreshed profile',
          () async {
        when(() => backend.data.rpc('admin_reactivate_user',
                params: {'target_uid': 'user-2', 'new_role': 'admin'}))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        backend.oneRow('profiles', profileJson(role: 'admin'));

        final result = await repository.updateUserRole(
          userId: 'user-2',
          role: 'admin',
        );

        expect(result, isA<Ok<UserEntity>>());
        final value = (result as Ok<UserEntity>).value;
        expect(value.role, UserRole.admin);
        verify(() => backend.data.rpc('admin_reactivate_user',
            params: {'target_uid': 'user-2', 'new_role': 'admin'})).called(1);
      });

      test('returns Err on RPC error', () async {
        when(() => backend.data.rpc(any(), params: any(named: 'params')))
            .thenThrow(Exception('RPC error'));

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
