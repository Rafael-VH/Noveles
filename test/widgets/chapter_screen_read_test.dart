import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockChapterBloc extends Mock implements ChapterBloc {}
class MockMarkChapterAsRead extends Mock implements MarkChapterAsRead {}

void main() {
  final getIt = GetIt.instance;

  late MockAuthBloc mockAuthBloc;
  late MockChapterBloc mockChapterBloc;
  late MockMarkChapterAsRead mockMarkChapterAsRead;
  late StreamController<AuthState> authController;
  late StreamController<ChapterState> chapterController;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockChapterBloc = MockChapterBloc();
    mockMarkChapterAsRead = MockMarkChapterAsRead();
    authController = StreamController<AuthState>.broadcast();
    chapterController = StreamController<ChapterState>.broadcast();

    when(() => mockAuthBloc.stream).thenAnswer((_) => authController.stream);
    when(() => mockChapterBloc.stream).thenAnswer((_) => chapterController.stream);
    when(() => mockChapterBloc.state).thenReturn(ChapterInitial());

    if (!getIt.isRegistered<MarkChapterAsRead>()) {
      getIt.registerFactory<MarkChapterAsRead>(() => mockMarkChapterAsRead);
    }
  });

  tearDown(() {
    authController.close();
    chapterController.close();
  });

  final testChapters = [
    ChapterEntity(
      id: 1,
      createdAt: DateTime(2024),
      number: '1',
      title: 'Capítulo 1',
      content: 'Contenido del capítulo',
      tookId: 1,
    ),
  ];

  group('ChapterScreen — mark as read', () {
    testWidgets('llama a MarkChapterAsRead cuando hay usuario autenticado', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockMarkChapterAsRead(1, 'user-1'))
          .thenAnswer((_) async => const Ok(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
              BlocProvider<ChapterBloc>.value(value: mockChapterBloc),
            ],
            child: ChapterScreen(
              i: 0,
              chapters: testChapters,
            ),
          ),
        ),
      );

      verify(() => mockMarkChapterAsRead(1, 'user-1')).called(1);
    });

    testWidgets('no llama a MarkChapterAsRead cuando no hay usuario autenticado', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
      when(() => mockChapterBloc.state).thenReturn(ChapterInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
              BlocProvider<ChapterBloc>.value(value: mockChapterBloc),
            ],
            child: ChapterScreen(
              i: 0,
              chapters: testChapters,
            ),
          ),
        ),
      );

      verifyNever(() => mockMarkChapterAsRead(any(), any()));
    });
  });
}
