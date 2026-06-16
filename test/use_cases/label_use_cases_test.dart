import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
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
    test('returns labels on success', () async {
      final labels = [
        LabelEntity(
          id: 1,
          createdAt: DateTime(2026),
          name: 'Staff Pick',
          color: '#71A202',
        ),
      ];
      when(() => mockRepo.getLabels()).thenAnswer((_) async => Ok(labels));

      final result = await GetLabels(mockRepo)();

      expect(result, isA<Ok<List<LabelEntity>>>());
      result as Ok<List<LabelEntity>>;
      expect(result.value.length, 1);
      expect(result.value.first.name, 'Staff Pick');
    });

    test('returns error on failure', () async {
      when(() => mockRepo.getLabels())
          .thenAnswer((_) async => Err(LabelFailure('Error de red')));

      final result = await GetLabels(mockRepo)();

      expect(result, isA<Err<List<LabelEntity>>>());
      result as Err<List<LabelEntity>>;
      expect(result.error.message, contains('Error de red'));
    });
  });

  group('CreateLabel', () {
    test('returns Ok on success', () async {
      final label = LabelEntity(
        id: 0,
        createdAt: DateTime(2026),
        name: 'Staff Pick',
        color: '#71A202',
      );
      when(() => mockRepo.createLabel(any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await CreateLabel(mockRepo)(label);

      expect(result, isA<Ok<void>>());
      verify(() => mockRepo.createLabel(label)).called(1);
    });

    test('returns error on failure', () async {
      final label = LabelEntity(
        id: 0,
        createdAt: DateTime(2026),
        name: 'Staff Pick',
        color: '#71A202',
      );
      when(() => mockRepo.createLabel(any()))
          .thenAnswer((_) async => Err(LabelFailure('Error al crear')));

      final result = await CreateLabel(mockRepo)(label);

      expect(result, isA<Err<void>>());
      result as Err<void>;
      expect(result.error.message, contains('Error al crear'));
    });
  });

  group('UpdateLabel', () {
    test('returns Ok on success', () async {
      when(() => mockRepo.updateLabel(any(), any(), any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await UpdateLabel(mockRepo)(1, 'Staff Pick', '#71A202');

      expect(result, isA<Ok<void>>());
      verify(() => mockRepo.updateLabel(1, 'Staff Pick', '#71A202')).called(1);
    });

    test('returns error on failure', () async {
      when(() => mockRepo.updateLabel(any(), any(), any()))
          .thenAnswer((_) async => Err(LabelFailure('Error al actualizar')));

      final result = await UpdateLabel(mockRepo)(1, 'Staff Pick', '#71A202');

      expect(result, isA<Err<void>>());
      result as Err<void>;
      expect(result.error.message, contains('Error al actualizar'));
    });
  });

  group('DeleteLabel', () {
    test('returns Ok on success', () async {
      when(() => mockRepo.deleteLabel(any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await DeleteLabel(mockRepo)(1);

      expect(result, isA<Ok<void>>());
      verify(() => mockRepo.deleteLabel(1)).called(1);
    });

    test('returns error on failure', () async {
      when(() => mockRepo.deleteLabel(any()))
          .thenAnswer((_) async => Err(LabelFailure('Error al eliminar')));

      final result = await DeleteLabel(mockRepo)(1);

      expect(result, isA<Err<void>>());
      result as Err<void>;
      expect(result.error.message, contains('Error al eliminar'));
    });
  });

  group('AssignLabelToBook', () {
    test('returns Ok on success', () async {
      when(() => mockRepo.assignLabel(any(), any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await AssignLabelToBook(mockRepo)(1, 2);

      expect(result, isA<Ok<void>>());
      verify(() => mockRepo.assignLabel(1, 2)).called(1);
    });

    test('returns error on failure', () async {
      when(() => mockRepo.assignLabel(any(), any()))
          .thenAnswer((_) async => Err(LabelFailure('Error al asignar')));

      final result = await AssignLabelToBook(mockRepo)(1, 2);

      expect(result, isA<Err<void>>());
      result as Err<void>;
      expect(result.error.message, contains('Error al asignar'));
    });
  });

  group('RemoveLabelFromBook', () {
    test('returns Ok on success', () async {
      when(() => mockRepo.removeLabel(any(), any()))
          .thenAnswer((_) async => const Ok(null));

      final result = await RemoveLabelFromBook(mockRepo)(1, 2);

      expect(result, isA<Ok<void>>());
      verify(() => mockRepo.removeLabel(1, 2)).called(1);
    });

    test('returns error on failure', () async {
      when(() => mockRepo.removeLabel(any(), any()))
          .thenAnswer((_) async => Err(LabelFailure('Error al remover')));

      final result = await RemoveLabelFromBook(mockRepo)(1, 2);

      expect(result, isA<Err<void>>());
      result as Err<void>;
      expect(result.error.message, contains('Error al remover'));
    });
  });
}
