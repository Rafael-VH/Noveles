import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';

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
      when(() => mockRepo.getAllProfiles()).thenAnswer((_) async => users);

      final result = await GetAllProfiles(mockRepo)();
      expect(result, users);
      verify(() => mockRepo.getAllProfiles()).called(1);
    });

    test('throws when repository fails', () async {
      when(() => mockRepo.getAllProfiles()).thenThrow(Exception('DB error'));

      expect(() => GetAllProfiles(mockRepo)(), throwsA(isA<Exception>()));
    });
  });
}
