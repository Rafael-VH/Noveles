import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/get_labels.dart';
import 'package:noveles/features/labels/domain/create_label.dart';
import 'package:noveles/features/labels/domain/delete_label.dart';
import 'package:noveles/features/labels/domain/assign_label_to_book.dart';
import 'package:noveles/features/labels/domain/remove_label_from_book.dart';
import 'package:noveles/features/labels/domain/get_labels_for_books.dart';
import 'package:noveles/features/labels/presentation/bloc/label_bloc.dart';
import 'package:noveles/features/labels/presentation/bloc/label_event.dart';
import 'package:noveles/features/labels/presentation/bloc/label_state.dart';

class MockGetLabels extends Mock implements GetLabels {}

class MockCreateLabel extends Mock implements CreateLabel {}

class MockDeleteLabel extends Mock implements DeleteLabel {}

class MockAssignLabelToBook extends Mock implements AssignLabelToBook {}

class MockRemoveLabelFromBook extends Mock implements RemoveLabelFromBook {}

class MockGetLabelsForBooks extends Mock implements GetLabelsForBooks {}

void main() {
  late MockGetLabels mockGetLabels;
  late MockCreateLabel mockCreateLabel;
  late MockDeleteLabel mockDeleteLabel;
  late MockAssignLabelToBook mockAssignLabel;
  late MockRemoveLabelFromBook mockRemoveLabel;
  late MockGetLabelsForBooks mockGetLabelsForBooks;

  final testLabels = [
    LabelEntity(
      id: 1,
      createdAt: DateTime(2024),
      name: 'Favorito',
      color: '#ff0000',
    ),
    LabelEntity(
      id: 2,
      createdAt: DateTime(2024),
      name: 'Pendiente',
      color: '#00ff00',
    ),
  ];

  final testBookLabels = <int, Set<int>>{
    1: {1, 2},
    2: {1},
  };

  setUpAll(() {
    registerFallbackValue(LabelEntity(
      id: 0,
      createdAt: DateTime(2024),
      name: '',
      color: '',
    ));
  });

  setUp(() {
    mockGetLabels = MockGetLabels();
    mockCreateLabel = MockCreateLabel();
    mockDeleteLabel = MockDeleteLabel();
    mockAssignLabel = MockAssignLabelToBook();
    mockRemoveLabel = MockRemoveLabelFromBook();
    mockGetLabelsForBooks = MockGetLabelsForBooks();
  });

  group('LabelBloc', () {
    test('initial state is LabelInitial', () {
      final bloc = LabelBloc(
        getLabels: mockGetLabels,
        createLabel: mockCreateLabel,
        deleteLabel: mockDeleteLabel,
        assignLabel: mockAssignLabel,
        removeLabel: mockRemoveLabel,
        getLabelsForBooks: mockGetLabelsForBooks,
      );
      expect(bloc.state, const LabelInitial());
      bloc.close();
    });

    blocTest<LabelBloc, LabelState>(
      'emits [LabelLoading, LabelLoaded] when LoadLabels succeeds',
      build: () {
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const LoadLabels()),
      expect: () => [
        const LabelLoading(),
        isA<LabelLoaded>()
            .having((s) => s.labels.length, 'label count', 2)
            .having((s) => s.bookLabels, 'bookLabels', testBookLabels),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits [LabelLoading, LabelError] when LoadLabels fails',
      build: () {
        when(() => mockGetLabels())
            .thenAnswer((_) async => Err(LabelFailure('Error de red')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const LoadLabels()),
      expect: () => [
        const LabelLoading(),
        isA<LabelError>().having(
          (s) => s.message,
          'message',
          contains('Error de red'),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelLoaded with message when CreateLabelEvent succeeds',
      build: () {
        when(() => mockCreateLabel(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const CreateLabelEvent('New', '#fff')),
      expect: () => [
        isA<LabelLoaded>().having(
          (s) => s.message,
          'message',
          'Etiqueta creada',
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelError when CreateLabelEvent fails',
      build: () {
        when(() => mockCreateLabel(any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al crear')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const CreateLabelEvent('New', '#fff')),
      expect: () => [
        isA<LabelError>().having(
          (s) => s.message,
          'message',
          contains('Error al crear'),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelLoaded with message when AssignLabelEvent succeeds',
      build: () {
        when(() => mockAssignLabel(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const AssignLabelEvent(1, 2)),
      expect: () => [
        isA<LabelLoaded>().having(
          (s) => s.message,
          'message',
          'Etiqueta asignada',
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelError when AssignLabelEvent fails',
      build: () {
        when(() => mockAssignLabel(any(), any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al asignar')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const AssignLabelEvent(1, 2)),
      expect: () => [
        isA<LabelError>().having(
          (s) => s.message,
          'message',
          contains('Error al asignar'),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelLoaded with message when RemoveLabelEvent succeeds',
      build: () {
        when(() => mockRemoveLabel(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const RemoveLabelEvent(1, 1)),
      expect: () => [
        isA<LabelLoaded>().having(
          (s) => s.message,
          'message',
          'Etiqueta removida',
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelLoaded with message when DeleteLabelEvent succeeds',
      build: () {
        when(() => mockDeleteLabel(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const DeleteLabelEvent(1)),
      expect: () => [
        isA<LabelLoaded>().having(
          (s) => s.message,
          'message',
          'Etiqueta eliminada',
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelError when DeleteLabelEvent fails',
      build: () {
        when(() => mockDeleteLabel(any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al eliminar')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const DeleteLabelEvent(1)),
      expect: () => [
        isA<LabelError>().having(
          (s) => s.message,
          'message',
          contains('Error al eliminar'),
        ),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'emits LabelError when RemoveLabelEvent fails',
      build: () {
        when(() => mockRemoveLabel(any(), any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al remover')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const RemoveLabelEvent(1, 1)),
      expect: () => [
        isA<LabelError>().having(
          (s) => s.message,
          'message',
          contains('Error al remover'),
        ),
      ],
    );

    // --- P0: H1/H2 fix verification ---

    blocTest<LabelBloc, LabelState>(
      'AssignLabel from LabelLoaded preserves bookLabels (H1)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockAssignLabel(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const AssignLabelEvent(2, 2)),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels[1], 'book 1 labels', {1, 2})
            .having((s) => s.bookLabels[2], 'book 2 labels', {1, 2})
            .having((s) => s.message, 'message', 'Etiqueta asignada'),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'RemoveLabel from LabelLoaded preserves bookLabels (H1)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockRemoveLabel(any(), any()))
            .thenAnswer((_) async => const Ok(null));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const RemoveLabelEvent(1, 1)),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels[1], 'book 1 after remove', {2})
            .having((s) => s.bookLabels[2], 'book 2 untouched', {1})
            .having((s) => s.message, 'message', 'Etiqueta removida'),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'CreateLabel error from LabelLoaded keeps labels (H2)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockCreateLabel(any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al crear')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const CreateLabelEvent('New', '#fff')),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels, 'bookLabels', testBookLabels)
            .having((s) => s.message, 'message', contains('Error al crear')),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'AssignLabel error from LabelLoaded keeps labels (H2)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockAssignLabel(any(), any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al asignar')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const AssignLabelEvent(1, 2)),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels, 'bookLabels', testBookLabels)
            .having((s) => s.message, 'message', contains('Error al asignar')),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'RemoveLabel error from LabelLoaded keeps labels (H2)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockRemoveLabel(any(), any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al remover')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const RemoveLabelEvent(1, 1)),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels, 'bookLabels', testBookLabels)
            .having((s) => s.message, 'message', contains('Error al remover')),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'DeleteLabel error from LabelLoaded keeps labels (H2)',
      seed: () => LabelLoaded(testLabels, testBookLabels),
      build: () {
        when(() => mockDeleteLabel(any()))
            .thenAnswer((_) async => Err(LabelFailure('Error al eliminar')));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const DeleteLabelEvent(1)),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels, 'labels', testLabels)
            .having((s) => s.bookLabels, 'bookLabels', testBookLabels)
            .having((s) => s.message, 'message', contains('Error al eliminar')),
      ],
    );

    blocTest<LabelBloc, LabelState>(
      'CreateLabel success from non-Loaded re-fetches via getLabels',
      build: () {
        when(() => mockCreateLabel(any()))
            .thenAnswer((_) async => const Ok(null));
        when(() => mockGetLabels()).thenAnswer((_) async => Ok(testLabels));
        when(() => mockGetLabelsForBooks(any()))
            .thenAnswer((_) async => Ok(testBookLabels));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getLabelsForBooks: mockGetLabelsForBooks,
        );
      },
      act: (bloc) => bloc.add(const CreateLabelEvent('New', '#fff')),
      expect: () => [
        isA<LabelLoaded>()
            .having((s) => s.labels.length, 'label count', 2)
            .having((s) => s.message, 'message', 'Etiqueta creada'),
      ],
    );
  });
}
