import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/failure.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';

class MockGetChapterContent extends Mock implements GetChapterContent {}

void main() {
  late MockGetChapterContent mockGetChapterContent;

  setUpAll(() {
    registerFallbackValue(ChapterContentType.storagePath);
  });

  final testRefs = [
    const ChapterRef(
      id: 1,
      number: '1',
      title: 'Chapter 1',
      content: 'ch1.txt',
      tookId: 1,
      contentType: ChapterContentType.storagePath,
    ),
    const ChapterRef(
      id: 2,
      number: '2',
      title: 'Chapter 2',
      content: 'Chapter two inline text',
      tookId: 1,
      contentType: ChapterContentType.inline,
    ),
    const ChapterRef(
      id: 3,
      number: '3',
      title: 'Chapter 3',
      content: 'ch3.txt',
      tookId: 1,
      contentType: ChapterContentType.storagePath,
    ),
    const ChapterRef(
      id: 4,
      number: '4',
      title: 'Chapter 4',
      content: 'ch4.txt',
      tookId: 1,
      contentType: ChapterContentType.storagePath,
    ),
    const ChapterRef(
      id: 5,
      number: '5',
      title: 'Chapter 5',
      content: 'ch5.txt',
      tookId: 1,
      contentType: ChapterContentType.storagePath,
    ),
  ];

  setUp(() {
    mockGetChapterContent = MockGetChapterContent();
  });

  // ── Event & State unit tests ──

  group('ChapterEvents', () {
    test('LoadChapterByIndex stores index and refs', () {
      final event = LoadChapterByIndex(index: 0, refs: testRefs);
      expect(event.index, 0);
      expect(event.refs, testRefs);
    });

    test('LoadChapterByIndex equatable works', () {
      final a = LoadChapterByIndex(index: 0, refs: testRefs);
      final b = LoadChapterByIndex(index: 0, refs: testRefs);
      final c = LoadChapterByIndex(index: 1, refs: testRefs);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('PreloadAdjacent stores currentIndex and refs', () {
      final event = PreloadAdjacent(currentIndex: 2, refs: testRefs);
      expect(event.currentIndex, 2);
      expect(event.refs, testRefs);
    });

    test('PreloadAdjacent equatable works', () {
      final a = PreloadAdjacent(currentIndex: 2, refs: testRefs);
      final b = PreloadAdjacent(currentIndex: 2, refs: testRefs);
      final c = PreloadAdjacent(currentIndex: 3, refs: testRefs);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ChapterStates', () {
    test('ChapterSingleLoaded stores cache, currentIndex, totalCount, chapterOrder', () {
      final cache = <int, ChapterEntity>{1: mockChapterEntity(1)};
      final state = ChapterSingleLoaded(
        cache: cache,
        currentIndex: 0,
        totalCount: 5,
        chapterOrder: [1],
      );
      expect(state.cache, cache);
      expect(state.currentIndex, 0);
      expect(state.totalCount, 5);
      expect(state.chapterOrder, [1]);
    });

    test('ChapterSingleLoaded equatable works', () {
      final cache = <int, ChapterEntity>{1: mockChapterEntity(1)};
      final a = ChapterSingleLoaded(
        cache: cache,
        currentIndex: 0,
        totalCount: 5,
        chapterOrder: [1],
      );
      final b = ChapterSingleLoaded(
        cache: cache,
        currentIndex: 0,
        totalCount: 5,
        chapterOrder: [1],
      );
      expect(a, equals(b));
    });

    test('ChapterLoadError stores index and message', () {
      final state = ChapterLoadError(index: 1, message: 'Failed to load');
      expect(state.index, 1);
      expect(state.message, 'Failed to load');
    });

    test('ChapterLoadError equatable works', () {
      final a = ChapterLoadError(index: 1, message: 'Failed');
      final b = ChapterLoadError(index: 1, message: 'Failed');
      final c = ChapterLoadError(index: 2, message: 'Failed');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('ChapterPreloading stores indices set', () {
      final indices = {1, 2, 3};
      final state = ChapterPreloading(indices: indices);
      expect(state.indices, indices);
    });

    test('ChapterPreloading equatable works', () {
      const a = ChapterPreloading(indices: {1, 2});
      const b = ChapterPreloading(indices: {1, 2});
      const c = ChapterPreloading(indices: {3, 4});
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ── Bloc behavior tests ──

  group('ChapterBloc', () {
    test('initial state is ChapterInitial', () {
      final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
      expect(bloc.state, equals(ChapterInitial()));
      bloc.close();
    });

    group('LoadChapterByIndex', () {
      test('loads single chapter and emits ChapterSingleLoaded', () async {
        when(() => mockGetChapterContent(
              'ch1.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Chapter 1 content'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ChapterSingleLoaded>()
                .having((s) => s.currentIndex, 'currentIndex', 0)
                .having((s) => s.totalCount, 'totalCount', 5)
                .having((s) => s.cache.length, 'cache length', 1)
                .having((s) => s.cache[1]!.content, 'chapter 1 content', 'Chapter 1 content'),
          ]),
        );

        await bloc.close();
      });

      test('passes contentType to getChapterContent', () async {
        when(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            )).thenAnswer((_) async => const Ok('Chapter two inline text'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
        bloc.add(LoadChapterByIndex(index: 1, refs: testRefs));

        await expectLater(
          bloc.stream,
          emits(isA<ChapterSingleLoaded>()),
        );

        verify(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            )).called(1);

        await bloc.close();
      });

      test('emits ChapterLoadError on failure without clearing cache', () async {
        // First load chapter 1 successfully
        when(() => mockGetChapterContent(
              'ch1.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 1'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));
        await expectLater(
          bloc.stream,
          emits(isA<ChapterSingleLoaded>()),
        );

        // Now try to load chapter 2 which fails
        when(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            )).thenAnswer((_) async => const Err(ChapterFailure('Network error')));

        bloc.add(LoadChapterByIndex(index: 1, refs: testRefs));
        await expectLater(
          bloc.stream,
          emits(isA<ChapterLoadError>()
              .having((e) => e.index, 'index', 1)
              .having((e) => e.message, 'message', 'Network error')),
        );

        await bloc.close();
      });
    });

    group('PreloadAdjacent', () {
      test('loads next 3 chapters and emits ChapterPreloading then ChapterSingleLoaded', () async {
        // Pre-populate cache by loading chapter at index 0 first
        when(() => mockGetChapterContent(
              'ch1.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 1'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));
        await expectLater(
          bloc.stream,
          emits(isA<ChapterSingleLoaded>()),
        );

        // Now preload adjacent
        when(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            )).thenAnswer((_) async => const Ok('Inline content 2'));
        when(() => mockGetChapterContent(
              'ch3.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 3'));
        when(() => mockGetChapterContent(
              'ch4.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 4'));

        bloc.add(PreloadAdjacent(currentIndex: 0, refs: testRefs));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ChapterPreloading>(),
            isA<ChapterSingleLoaded>()
                .having((s) => s.cache.length, 'cache size', 4) // ch1 + ch2 + ch3 + ch4
                .having((s) => s.currentIndex, 'currentIndex', 0),
          ]),
        );

        await bloc.close();
      });

      test('skips already-cached chapters during preload', () async {
        when(() => mockGetChapterContent(
              'ch1.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 1'));
        when(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            )).thenAnswer((_) async => const Ok('Inline 2'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);

        // Load chapters 0 and 1 first
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));
        await expectLater(bloc.stream, emits(isA<ChapterSingleLoaded>()));

        bloc.add(LoadChapterByIndex(index: 1, refs: testRefs));
        await expectLater(bloc.stream, emits(isA<ChapterSingleLoaded>()));

        // Clear interactions so verify only sees preload calls
        clearInteractions(mockGetChapterContent);

        // Now preload from index 0 — should only load ch3 and ch4 (ch2 is cached)
        when(() => mockGetChapterContent(
              'ch3.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 3'));
        when(() => mockGetChapterContent(
              'ch4.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 4'));

        bloc.add(PreloadAdjacent(currentIndex: 0, refs: testRefs));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ChapterPreloading>(),
            isA<ChapterSingleLoaded>()
                .having((s) => s.cache.length, 'cache size', 4),
          ]),
        );

        // Verify ch2 was NOT fetched during preload (only ch3 and ch4)
        verify(() => mockGetChapterContent(
              'ch3.txt',
              contentType: ChapterContentType.storagePath,
            )).called(1);
        verify(() => mockGetChapterContent(
              'ch4.txt',
              contentType: ChapterContentType.storagePath,
            )).called(1);
        verifyNever(() => mockGetChapterContent(
              'Chapter two inline text',
              contentType: ChapterContentType.inline,
            ));

        await bloc.close();
      });

      test('stops at end of list during preload', () async {
        when(() => mockGetChapterContent(
              'ch5.txt',
              contentType: ChapterContentType.storagePath,
            )).thenAnswer((_) async => const Ok('Content 5'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);

        // Load last chapter (index 4)
        bloc.add(LoadChapterByIndex(index: 4, refs: testRefs));
        await expectLater(bloc.stream, emits(isA<ChapterSingleLoaded>()));

        // Preload adjacent from last index — nothing to preload
        bloc.add(PreloadAdjacent(currentIndex: 4, refs: testRefs));

        // Allow microtask to settle — no new state should be emitted
        await Future<void>.delayed(Duration.zero);

        // State should still be the ChapterSingleLoaded from the initial load
        expect(bloc.state, isA<ChapterSingleLoaded>());

        await bloc.close();
      });

      test('emits nothing when all adjacent chapters are already cached', () async {
        when(() => mockGetChapterContent(
              any(),
              contentType: any(named: 'contentType'),
            )).thenAnswer((_) async => const Ok('Content'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);

        // Load chapter at index 0
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));
        await expectLater(bloc.stream, emits(isA<ChapterSingleLoaded>()));

        // Preload adjacent — ch2, ch3, ch4 load
        bloc.add(PreloadAdjacent(currentIndex: 0, refs: testRefs));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ChapterPreloading>(),
            isA<ChapterSingleLoaded>()
                .having((s) => s.cache.length, 'cache size', 4),
          ]),
        );

        // Clear interactions so we only verify the second preload call
        clearInteractions(mockGetChapterContent);

        // Preload again from index 0 — all are now cached, nothing emitted
        bloc.add(PreloadAdjacent(currentIndex: 0, refs: testRefs));

        // Allow microtask to settle
        await Future<void>.delayed(Duration.zero);

        // No calls to getChapterContent during second preload
        verifyNever(() => mockGetChapterContent(
              any(),
              contentType: any(named: 'contentType'),
            ));

        await bloc.close();
      });
    });

    group('Chapter order preservation', () {
      test('chapterOrder is preserved across multiple loads', () async {
        when(() => mockGetChapterContent(
              any(),
              contentType: any(named: 'contentType'),
            )).thenAnswer((_) async => const Ok('Content'));

        final bloc = ChapterBloc(getChapterContent: mockGetChapterContent);

        // Load chapter 2 first
        bloc.add(LoadChapterByIndex(index: 2, refs: testRefs));
        final state1 = await bloc.stream.first;
        expect(state1, isA<ChapterSingleLoaded>());
        expect((state1 as ChapterSingleLoaded).chapterOrder, [1, 2, 3, 4, 5]);

        // Load chapter 0
        bloc.add(LoadChapterByIndex(index: 0, refs: testRefs));
        final state2 = await bloc.stream.first;
        expect(state2, isA<ChapterSingleLoaded>());
        expect((state2 as ChapterSingleLoaded).chapterOrder, [1, 2, 3, 4, 5]);

        await bloc.close();
      });
    });
  });
}

ChapterEntity mockChapterEntity(int id) {
  return ChapterEntity(
    id: id,
    createdAt: DateTime(2026),
    number: '$id',
    title: 'Chapter $id',
    content: 'content',
    tookId: 1,
  );
}
