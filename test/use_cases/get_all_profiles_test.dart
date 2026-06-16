import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/profiles_repository.dart';
import 'package:noveles/features/profiles/domain/get_all_profiles.dart';

class MockProfilesRepository extends Mock implements ProfilesRepository {}

void main() {
  late MockProfilesRepository mockRepo;

  setUp(() {
    mockRepo = MockProfilesRepository();
  });

  group('GetAllProfiles', () {
    test('returns user list from repository', () async {
      final users = [
        const UserEntity(
          id: '1',
          email: 'admin@test.com',
          role: 'admin',
          displayName: 'Admin',
        ),
      ];
      when(() => mockRepo.getAllProfiles()).thenAnswer((_) async => Ok(users));

      final result = await GetAllProfiles(mockRepo)();
      expect(result, isA<Ok<List<UserEntity>>>());
      verify(() => mockRepo.getAllProfiles()).called(1);
    });

    test('returns Err when repository fails', () async {
      when(() => mockRepo.getAllProfiles())
          .thenAnswer((_) async => Err(ProfileFailure('DB error')));

      final result = await GetAllProfiles(mockRepo)();
      expect(result, isA<Err<List<UserEntity>>>());
    });
  });
}
