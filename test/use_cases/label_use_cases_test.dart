import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

void main() {
  late MockLabelRepository mockRepo;

  setUp(() {
    mockRepo = MockLabelRepository();
  });

  group('GetLabels', () {
    test('returns label list from repository', () async {
      final labels = [
        LabelEntity(
          id: 1,
          createdAt: DateTime(2026),
          name: 'Staff Pick',
          color: '#71A202',
        ),
      ];
      when(() => mockRepo.getLabels()).thenAnswer((_) async => labels);

      final result = await GetLabels(mockRepo)();
      expect(result, labels);
      verify(() => mockRepo.getLabels()).called(1);
    });
  });

  group('CreateLabel', () {
    test('calls repository.createLabel', () async {
      when(() => mockRepo.createLabel(any(), any())).thenAnswer((_) async {});

      await CreateLabel(mockRepo)('Staff Pick', '#71A202');
      verify(() => mockRepo.createLabel('Staff Pick', '#71A202')).called(1);
    });
  });

  group('DeleteLabel', () {
    test('calls repository.deleteLabel', () async {
      when(() => mockRepo.deleteLabel(any())).thenAnswer((_) async {});

      await DeleteLabel(mockRepo)(1);
      verify(() => mockRepo.deleteLabel(1)).called(1);
    });
  });

  group('AssignLabelToBook', () {
    test('calls repository.assignLabel', () async {
      when(() => mockRepo.assignLabel(any(), any())).thenAnswer((_) async {});

      await AssignLabelToBook(mockRepo)(1, 2);
      verify(() => mockRepo.assignLabel(1, 2)).called(1);
    });
  });

  group('RemoveLabelFromBook', () {
    test('calls repository.removeLabel', () async {
      when(() => mockRepo.removeLabel(any(), any())).thenAnswer((_) async {});

      await RemoveLabelFromBook(mockRepo)(1, 2);
      verify(() => mockRepo.removeLabel(1, 2)).called(1);
    });
  });
}
