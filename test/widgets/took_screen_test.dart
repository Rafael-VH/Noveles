import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/presentation/screens/took_screen.dart';
import 'test_helpers.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockGetReadChapterIds extends Mock implements GetReadChapterIds {}
class MockChapterBloc extends Mock implements ChapterBloc {}

void main() {
  final getIt = GetIt.instance;

  late MockAuthBloc mockAuthBloc;
  late MockGetReadChapterIds mockGetReadChapterIds;
  late MockChapterBloc mockChapterBloc;
  late StreamController<AuthState> authController;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockGetReadChapterIds = MockGetReadChapterIds();
    mockChapterBloc = MockChapterBloc();
    authController = StreamController<AuthState>.broadcast();

    when(() => mockAuthBloc.stream).thenAnswer((_) => authController.stream);
    when(() => mockChapterBloc.stream).thenAnswer((_) => const Stream.empty());

    setupCoverUrlService();

    if (!getIt.isRegistered<GetReadChapterIds>()) {
      getIt.registerFactory<GetReadChapterIds>(() => mockGetReadChapterIds);
    }
    if (!getIt.isRegistered<ChapterBloc>()) {
      getIt.registerFactory<ChapterBloc>(() => mockChapterBloc);
    }
  });

  tearDown(() {
    if (getIt.isRegistered<GetReadChapterIds>()) {
      getIt.unregister<GetReadChapterIds>();
    }
    if (getIt.isRegistered<ChapterBloc>()) {
      getIt.unregister<ChapterBloc>();
    }
    authController.close();
  });

  final testChapters = [
    ChapterEntity(
      id: 1,
      createdAt: DateTime(2026),
      number: 'Capítulo 1',
      title: 'El comienzo',
      content: '...',
      tookId: 10,
    ),
    ChapterEntity(
      id: 2,
      createdAt: DateTime(2026),
      number: 'Capítulo 2',
      title: 'El desarrollo',
      content: '...',
      tookId: 10,
    ),
    ChapterEntity(
      id: 3,
      createdAt: DateTime(2026),
      number: 'Capítulo 3',
      title: 'El final',
      content: '...',
      tookId: 10,
    ),
  ];

  final testTook = TookModel(
    id: 10,
    createdAt: DateTime(2026),
    cover: '',
    number: 'Tomo 1',
    title: 'Tomo de prueba',
    chapterCount: 3,
    bookId: 1,
    chapters: testChapters,
  );

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: TookScreen(tooks: testTook),
      ),
    );
  }

  group('TookScreen — read coloring', () {
    testWidgets('capítulos leídos se muestran en gris, no leídos en color default', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockGetReadChapterIds(10, 'user-1'))
          .thenAnswer((_) async => Ok({1, 3})); // chapters 1 and 3 read, 2 not read

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(); // let the Future resolve

      // Find ListTile widgets
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(listTiles.length, 3);

      // Chapter 1 (id=1) is in read set -> grey
      final tile1 = listTiles[0];
      final text1 = tile1.title! as Text;
      expect(text1.style?.color, Colors.grey);

      // Chapter 2 (id=2) is NOT in read set -> default (null)
      final tile2 = listTiles[1];
      final text2 = tile2.title! as Text;
      expect(text2.style?.color, isNull);

      // Chapter 3 (id=3) is in read set -> grey
      final tile3 = listTiles[2];
      final text3 = tile3.title! as Text;
      expect(text3.style?.color, Colors.grey);
    });

    testWidgets('sin autenticación, todos los capítulos se muestran en color default', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(listTiles.length, 3);

      for (final tile in listTiles) {
        final text = tile.title! as Text;
        expect(text.style?.color, isNull);
      }
    });
  });

  group('TookScreen — loading indicator', () {
    testWidgets('muestra CircularProgressIndicator mientras carga ids de capítulos leídos',
        (tester) async {
      final completer = Completer<Result<Set<int>>>();

      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockGetReadChapterIds(10, 'user-1'))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // ListTiles should NOT be visible yet
      expect(find.byType(ListTile), findsNothing);

      // Complete the future
      completer.complete(Ok({}));
      await tester.pump();

      // Loading indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // ListTiles should now be visible
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(listTiles.length, 3);
    });
  });
}
