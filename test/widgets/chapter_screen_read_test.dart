import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';
import 'package:noveles/features/chapters/presentation/screens/widgets/reading_settings_bar.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockChapterBloc extends Mock implements ChapterBloc {}
class MockMarkChapterAsRead extends Mock implements MarkChapterAsRead {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockChapterBloc mockChapterBloc;
  late MockMarkChapterAsRead mockMarkChapterAsRead;
  late StreamController<AuthState> authController;
  late StreamController<ChapterState> chapterController;

  final testChapters = [
    ChapterEntity(
      id: 1,
      createdAt: DateTime(2024),
      number: '1',
      title: 'Capítulo 1',
      content: 'Contenido del capítulo uno con mucho texto para scroll',
      tookId: 1,
    ),
    ChapterEntity(
      id: 2,
      createdAt: DateTime(2024),
      number: '2',
      title: 'Capítulo 2',
      content: 'Contenido del capítulo dos',
      tookId: 1,
    ),
  ];

  final loadedState = ChapterSingleLoaded(
    cache: {
      1: testChapters[0],
      2: testChapters[1],
    },
    currentIndex: 0,
    totalCount: 2,
    chapterOrder: [1, 2],
  );

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockChapterBloc = MockChapterBloc();
    mockMarkChapterAsRead = MockMarkChapterAsRead();
    authController = StreamController<AuthState>.broadcast();
    chapterController = StreamController<ChapterState>.broadcast();

    when(() => mockAuthBloc.stream).thenAnswer((_) => authController.stream);
    when(() => mockChapterBloc.stream).thenAnswer((_) => chapterController.stream);
    when(() => mockChapterBloc.state).thenReturn(ChapterInitial());

    // Register mock use case if not already registered.
    final getIt = GetIt.instance;
    if (getIt.isRegistered<MarkChapterAsRead>()) {
      getIt.unregister<MarkChapterAsRead>();
    }
    getIt.registerFactory<MarkChapterAsRead>(() => mockMarkChapterAsRead);
  });

  tearDown(() {
    authController.close();
    chapterController.close();
  });

  Widget buildTestWidget({List<ChapterEntity>? chapters, int index = 0}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<ChapterBloc>.value(value: mockChapterBloc),
        ],
        child: ChapterScreen(
          i: index,
          chapters: chapters ?? testChapters,
        ),
      ),
    );
  }

  // ─── Bloc event dispatch tests ───

  group('ChapterScreen — bloc events', () {
    testWidgets('dispatches LoadChapterByIndex on init', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      verify(() => mockChapterBloc.add(
            LoadChapterByIndex(
              index: 0,
              refs: testChapters.map(ChapterRef.fromEntity).toList(),
            ),
          )).called(1);
    });
  });

  // ─── Mark-as-read tests ───

  group('ChapterScreen — mark as read', () {
    testWidgets('does NOT call MarkChapterAsRead in initState', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockMarkChapterAsRead(any(), any()))
          .thenAnswer((_) async => const Ok(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Mark-as-read should NOT be called during initState anymore.
      verifyNever(() => mockMarkChapterAsRead(any(), any()));
    });

    testWidgets('does NOT call MarkChapterAsRead when unauthenticated',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      verifyNever(() => mockMarkChapterAsRead(any(), any()));
    });
  });

  // ─── Reading mode tests (require loaded state) ───

  group('ChapterScreen — reading mode', () {
    setUp(() {
      when(() => mockChapterBloc.state).thenReturn(loadedState);
    });

    testWidgets('shows ReadingSettingsBar when visible', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.byType(ReadingSettingsBar), findsOneWidget);
    });

    testWidgets('font size default is 14', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      final bar = tester.widget<ReadingSettingsBar>(
        find.byType(ReadingSettingsBar),
      );
      expect(bar.fontSize, 14.0);
      expect(bar.mode, ReadingMode.normal);
    });

    testWidgets('tapping font increase updates font size', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const Key('font_increase')));
      await tester.pump();

      final bar = tester.widget<ReadingSettingsBar>(
        find.byType(ReadingSettingsBar),
      );
      expect(bar.fontSize, 16.0);
    });

    testWidgets('tapping mode toggle cycles to sepia', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const Key('mode_toggle')));
      await tester.pump();

      final bar = tester.widget<ReadingSettingsBar>(
        find.byType(ReadingSettingsBar),
      );
      expect(bar.mode, ReadingMode.sepia);
    });

    testWidgets('sepia mode sets warm background color', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      // Switch to sepia.
      await tester.tap(find.byKey(const Key('mode_toggle')));
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFFF5E6D3));
    });

    testWidgets('night mode sets dark background color', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      // Switch to sepia, then night.
      await tester.tap(find.byKey(const Key('mode_toggle')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('mode_toggle')));
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFF1A1A2E));
    });
  });

  // ─── Chapter indicator tests (require loaded state) ───

  group('ChapterScreen — chapter indicator', () {
    setUp(() {
      when(() => mockChapterBloc.state).thenReturn(loadedState);
    });

    testWidgets('shows "Chapter X of Y" in AppBar', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Capítulo 1 de 2'), findsOneWidget);
    });
  });
}
