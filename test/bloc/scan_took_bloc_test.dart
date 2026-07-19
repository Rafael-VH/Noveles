import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/create_took.dart';
import 'package:noveles/features/tooks/domain/update_took.dart';
import 'package:noveles/features/tooks/domain/delete_took.dart';
import 'package:noveles/features/books/domain/upload_cover.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';

class MockCreateTook extends Mock implements CreateTook {}

class MockUpdateTook extends Mock implements UpdateTook {}

class MockDeleteTook extends Mock implements DeleteTook {}

class MockUploadCover extends Mock implements UploadCover {}

void main() {
  late MockCreateTook mockCreateTook;
  late MockUpdateTook mockUpdateTook;
  late MockDeleteTook mockDeleteTook;
  late MockUploadCover mockUploadCover;
  late ScanTookBloc scanTookBloc;

  final testTook = TookEntity(
    id: 1,
    createdAt: DateTime(2024),
    cover: 'cover.png',
    number: '1',
    title: 'Tomo 1',
    chapterCount: 5,
    bookId: 1,
    listChapter: const [],
  );

  setUpAll(() {
    registerFallbackValue(TookEntity(
      id: 0,
      createdAt: DateTime(2024),
      cover: '',
      number: '',
      title: '',
      chapterCount: 0,
      bookId: 0,
      listChapter: const [],
    ));
  });

  setUp(() {
    mockCreateTook = MockCreateTook();
    mockUpdateTook = MockUpdateTook();
    mockDeleteTook = MockDeleteTook();
    mockUploadCover = MockUploadCover();
    scanTookBloc = ScanTookBloc(
      createTook: mockCreateTook,
      updateTook: mockUpdateTook,
      deleteTook: mockDeleteTook,
      uploadCover: mockUploadCover,
    );
  });

  tearDown(() {
    scanTookBloc.close();
  });

  group('ScanTookBloc', () {
    test('initial state is ScanTookInitial', () {
      expect(scanTookBloc.state, equals(ScanTookInitial()));
    });

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookLoaded] when SaveScanTook create succeeds',
      build: () {
        when(() => mockCreateTook(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(testTook, isUpdate: false)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookLoaded>().having(
          (s) => s.message,
          'message',
          'Tomo creado',
        ),
      ],
    );

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookError] when SaveScanTook create fails',
      build: () {
        when(() => mockCreateTook(any()))
            .thenAnswer((_) async => Err(TookFailure('Error al crear')));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(testTook, isUpdate: false)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookError>().having(
          (s) => s.message,
          'message',
          contains('Error al crear'),
        ),
      ],
    );

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookLoaded] when SaveScanTook update succeeds',
      build: () {
        when(() => mockUpdateTook(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(testTook, isUpdate: true)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookLoaded>().having(
          (s) => s.message,
          'message',
          'Tomo guardado',
        ),
      ],
    );

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookError] when SaveScanTook update fails',
      build: () {
        when(() => mockUpdateTook(any()))
            .thenAnswer((_) async => Err(TookFailure('Error al guardar')));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(SaveScanTook(testTook, isUpdate: true)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookError>().having(
          (s) => s.message,
          'message',
          contains('Error al guardar'),
        ),
      ],
    );

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookLoaded] when DeleteScanTook succeeds',
      build: () {
        when(() => mockDeleteTook(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(DeleteScanTook(1)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookLoaded>().having(
          (s) => s.message,
          'message',
          'Tomo eliminado',
        ),
      ],
    );

    blocTest<ScanTookBloc, ScanTookState>(
      'emits [ScanTookLoading, ScanTookError] when DeleteScanTook fails',
      build: () {
        when(() => mockDeleteTook(any()))
            .thenAnswer((_) async => Err(TookFailure('Error al eliminar')));
        return scanTookBloc;
      },
      act: (bloc) => bloc.add(DeleteScanTook(1)),
      expect: () => [
        isA<ScanTookLoading>(),
        isA<ScanTookError>().having(
          (s) => s.message,
          'message',
          contains('Error al eliminar'),
        ),
      ],
    );
  });
}
