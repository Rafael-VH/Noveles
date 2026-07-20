import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';
import 'package:noveles/features/chapters/domain/upload_chapter_content.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_bloc.dart';

class MockCreateChapter extends Mock implements CreateChapter {}

class MockUpdateChapter extends Mock implements UpdateChapter {}

class MockDeleteChapter extends Mock implements DeleteChapter {}

class MockUploadChapterContent extends Mock implements UploadChapterContent {}

void main() {
  late MockCreateChapter mockCreateChapter;
  late MockUpdateChapter mockUpdateChapter;
  late MockDeleteChapter mockDeleteChapter;
  late MockUploadChapterContent mockUploadContent;
  late ScanChapterBloc scanChapterBloc;

  final testChapter = ChapterEntity(
    id: 1,
    createdAt: DateTime(2024),
    number: '1',
    title: 'Capítulo 1',
    content: 'content.txt',
    tookId: 1,
  );

  setUpAll(() {
    registerFallbackValue(ChapterEntity(
      id: 0,
      createdAt: DateTime(2024),
      number: '',
      title: '',
      content: '',
      tookId: 0,
    ));
  });

  setUp(() {
    mockCreateChapter = MockCreateChapter();
    mockUpdateChapter = MockUpdateChapter();
    mockDeleteChapter = MockDeleteChapter();
    mockUploadContent = MockUploadChapterContent();
    scanChapterBloc = ScanChapterBloc(
      createChapter: mockCreateChapter,
      updateChapter: mockUpdateChapter,
      deleteChapter: mockDeleteChapter,
      uploadContent: mockUploadContent,
    );
  });

  tearDown(() {
    scanChapterBloc.close();
  });

  group('ScanChapterBloc', () {
    test('initial state is ScanChapterInitial', () {
      expect(scanChapterBloc.state, equals(ScanChapterInitial()));
    });

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterLoaded] when SaveScanChapter create succeeds',
      build: () {
        when(() => mockCreateChapter(any()))
            .thenAnswer((_) async => const Ok(1));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(testChapter, isUpdate: false)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterLoaded>().having(
          (s) => s.message,
          'message',
          'Capítulo creado',
        ),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterError] when SaveScanChapter create fails',
      build: () {
        when(() => mockCreateChapter(any()))
            .thenAnswer((_) async => Err(ChapterFailure('Error al crear')));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(testChapter, isUpdate: false)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterError>().having(
          (s) => s.message,
          'message',
          contains('Error al crear'),
        ),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterLoaded] when SaveScanChapter update succeeds',
      build: () {
        when(() => mockUpdateChapter(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(testChapter, isUpdate: true)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterLoaded>().having(
          (s) => s.message,
          'message',
          'Capítulo guardado',
        ),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterError] when SaveScanChapter update fails',
      build: () {
        when(() => mockUpdateChapter(any()))
            .thenAnswer((_) async => Err(ChapterFailure('Error al guardar')));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(SaveScanChapter(testChapter, isUpdate: true)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterError>().having(
          (s) => s.message,
          'message',
          contains('Error al guardar'),
        ),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterLoaded] when DeleteScanChapter succeeds',
      build: () {
        when(() => mockDeleteChapter(any()))
            .thenAnswer((_) async => const Ok(null));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(DeleteScanChapter(1)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterLoaded>().having(
          (s) => s.message,
          'message',
          'Capítulo eliminado',
        ),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits [ScanChapterLoading, ScanChapterError] when DeleteScanChapter fails',
      build: () {
        when(() => mockDeleteChapter(any()))
            .thenAnswer((_) async => Err(ChapterFailure('Error al eliminar')));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(DeleteScanChapter(1)),
      expect: () => [
        isA<ScanChapterLoading>(),
        isA<ScanChapterError>().having(
          (s) => s.message,
          'message',
          contains('Error al eliminar'),
        ),
      ],
    );

    // --- P0: UploadChapterFile coverage ---

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits ScanChapterContentUploaded when UploadChapterFile succeeds',
      build: () {
        when(() => mockUploadContent(any()))
            .thenAnswer((_) async => const Ok('https://storage.example.com/ch1.txt'));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(const UploadChapterFile('/local/path/ch1.txt')),
      expect: () => [
        isA<ScanChapterContentUploaded>()
            .having((s) => s.url, 'url', 'https://storage.example.com/ch1.txt'),
      ],
    );

    blocTest<ScanChapterBloc, ScanChapterState>(
      'emits ScanChapterError when UploadChapterFile fails',
      build: () {
        when(() => mockUploadContent(any()))
            .thenAnswer((_) async => Err(ChapterFailure('Upload failed')));
        return scanChapterBloc;
      },
      act: (bloc) => bloc.add(const UploadChapterFile('/local/path/ch1.txt')),
      expect: () => [
        isA<ScanChapterError>().having(
          (s) => s.message,
          'message',
          contains('Upload failed'),
        ),
      ],
    );
  });
}
