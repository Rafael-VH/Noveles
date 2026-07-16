import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_event.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_state.dart';

class MockGetChapterContent extends Mock implements GetChapterContent {}

void main() {
  late MockGetChapterContent mockGetChapterContent;

  final testChapters = [
    ChapterEntity(
      id: 1,
      createdAt: DateTime(2024),
      number: '1',
      title: 'Chapter 1',
      content: 'ch1.txt',
      tookId: 1,
    ),
    ChapterEntity(
      id: 2,
      createdAt: DateTime(2024),
      number: '2',
      title: 'Chapter 2',
      content: 'ch2.txt',
      tookId: 1,
    ),
  ];

  setUp(() {
    mockGetChapterContent = MockGetChapterContent();
  });

  group('ChapterBloc', () {
    test('initial state is ChapterInitial', () {
      final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
      expect(bloc.state, equals(ChapterInitial()));
      bloc.close();
    });

    blocTest<ChapterBloc, ChapterState>(
      'emits [ChapterLoading, ChapterLoaded] when LoadChapterContent succeeds',
      build: () {
        when(() => mockGetChapterContent(any()))
            .thenAnswer((_) async => Ok('Resolved content'));
        return ChapterBloc(getChapterContent: mockGetChapterContent);
      },
      act: (bloc) => bloc.add(LoadChapterContent(
        initialIndex: 0,
        chapters: testChapters,
      )),
      expect: () => [
        isA<ChapterLoading>(),
        isA<ChapterLoaded>()
            .having((s) => s.chapters.length, 'chapter count', 2)
            .having(
              (s) => s.chapters.first.content,
              'first resolved content',
              'Resolved content',
            ),
      ],
    );

    blocTest<ChapterBloc, ChapterState>(
      'emits [ChapterLoading, ChapterError] when LoadChapterContent fails',
      build: () {
        when(() => mockGetChapterContent(any()))
            .thenAnswer((_) async => Err(ChapterFailure('Error al descargar')));
        return ChapterBloc(getChapterContent: mockGetChapterContent);
      },
      act: (bloc) => bloc.add(LoadChapterContent(
        initialIndex: 0,
        chapters: testChapters,
      )),
      expect: () => [
        isA<ChapterLoading>(),
        isA<ChapterError>().having(
          (s) => s.message,
          'message',
          contains('Error al cargar capítulos'),
        ),
      ],
    );

    blocTest<ChapterBloc, ChapterState>(
      'handles empty chapters list',
      build: () {
        return ChapterBloc(getChapterContent: mockGetChapterContent);
      },
      act: (bloc) => bloc.add(LoadChapterContent(
        initialIndex: 0,
        chapters: const [],
      )),
      expect: () => [
        isA<ChapterLoading>(),
        isA<ChapterLoaded>().having(
          (s) => s.chapters.length,
          'chapter count',
          0,
        ),
      ],
    );
  });
}
