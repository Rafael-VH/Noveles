import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';
import 'package:noveles/features/labels/domain/create_label.dart';
import 'package:noveles/features/labels/domain/get_labels.dart';
import 'package:noveles/features/labels/domain/update_label.dart';
import 'package:noveles/features/labels/domain/delete_label.dart';
import 'package:noveles/features/labels/domain/assign_label_to_book.dart';
import 'package:noveles/features/labels/domain/remove_label_from_book.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

void main() {
  late MockLabelRepository mockRepo;

  setUp(() {
    mockRepo = MockLabelRepository();
  });

  setUpAll(() {
    registerFallbackValue(LabelEntity(
      id: 0,
      createdAt: DateTime(2026),
      name: '',
      color: '',
    ));
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
    test('calls repository.createLabel with LabelEntity', () async {
      final label = LabelEntity(
        id: 0,
        createdAt: DateTime(2026),
        name: 'Staff Pick',
        color: '#71A202',
      );
      when(() => mockRepo.createLabel(any())).thenAnswer((_) async {});

      await CreateLabel(mockRepo)(label);
      verify(() => mockRepo.createLabel(label)).called(1);
    });
  });

  group('UpdateLabel', () {
    test('calls repository.updateLabel', () async {
      when(() => mockRepo.updateLabel(any(), any(), any()))
          .thenAnswer((_) async {});

      await UpdateLabel(mockRepo)(1, 'Staff Pick', '#71A202');
      verify(() => mockRepo.updateLabel(1, 'Staff Pick', '#71A202')).called(1);
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
