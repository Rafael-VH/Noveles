import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/use_cases/use_cases.dart';
import 'package:noveles/features/presentation/bloc/label/label_bloc.dart';
import 'package:noveles/features/presentation/bloc/label/label_event.dart';
import 'package:noveles/features/presentation/bloc/label/label_state.dart';

class MockGetLabels extends Mock implements GetLabels {}
class MockCreateLabel extends Mock implements CreateLabel {}
class MockDeleteLabel extends Mock implements DeleteLabel {}
class MockAssignLabelToBook extends Mock implements AssignLabelToBook {}
class MockRemoveLabelFromBook extends Mock implements RemoveLabelFromBook {}
class MockGetBookLabels extends Mock implements GetBookLabels {}

void main() {
  late MockGetLabels mockGetLabels;
  late MockCreateLabel mockCreateLabel;
  late MockDeleteLabel mockDeleteLabel;
  late MockAssignLabelToBook mockAssignLabel;
  late MockRemoveLabelFromBook mockRemoveLabel;
  late MockGetBookLabels mockGetBookLabels;

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
      id: 0, createdAt: DateTime(2024), name: '', color: '',
    ));
  });

  setUp(() {
    mockGetLabels = MockGetLabels();
    mockCreateLabel = MockCreateLabel();
    mockDeleteLabel = MockDeleteLabel();
    mockAssignLabel = MockAssignLabelToBook();
    mockRemoveLabel = MockRemoveLabelFromBook();
    mockGetBookLabels = MockGetBookLabels();
  });

  group('LabelBloc', () {
    test('initial state is LabelInitial', () {
      final bloc = LabelBloc(
        getLabels: mockGetLabels,
        createLabel: mockCreateLabel,
        deleteLabel: mockDeleteLabel,
        assignLabel: mockAssignLabel,
        removeLabel: mockRemoveLabel,
        getBookLabels: mockGetBookLabels,
      );
      expect(bloc.state, const LabelInitial());
      bloc.close();
    });

    blocTest<LabelBloc, LabelState>(
      'emits [LabelLoading, LabelLoaded] when LoadLabels succeeds',
      build: () {
        when(() => mockGetLabels()).thenAnswer((_) async => testLabels);
        when(() => mockGetBookLabels())
            .thenAnswer((_) async => testBookLabels);
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
        when(() => mockGetLabels()).thenThrow(Exception('Error de red'));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
        when(() => mockCreateLabel(any())).thenAnswer((_) async {});
        when(() => mockGetLabels()).thenAnswer((_) async => testLabels);
        when(() => mockGetBookLabels())
            .thenAnswer((_) async => testBookLabels);
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
            .thenThrow(Exception('Error al crear'));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
        when(() => mockAssignLabel(any(), any())).thenAnswer((_) async {});
        when(() => mockGetLabels()).thenAnswer((_) async => testLabels);
        when(() => mockGetBookLabels())
            .thenAnswer((_) async => testBookLabels);
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
            .thenThrow(Exception('Error al asignar'));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
        when(() => mockRemoveLabel(any(), any())).thenAnswer((_) async {});
        when(() => mockGetLabels()).thenAnswer((_) async => testLabels);
        when(() => mockGetBookLabels())
            .thenAnswer((_) async => testBookLabels);
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
      'emits LabelError when RemoveLabelEvent fails',
      build: () {
        when(() => mockRemoveLabel(any(), any()))
            .thenThrow(Exception('Error al remover'));
        return LabelBloc(
          getLabels: mockGetLabels,
          createLabel: mockCreateLabel,
          deleteLabel: mockDeleteLabel,
          assignLabel: mockAssignLabel,
          removeLabel: mockRemoveLabel,
          getBookLabels: mockGetBookLabels,
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
  });
}
