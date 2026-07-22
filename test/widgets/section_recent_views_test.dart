import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/section_recent_views.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_state.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

class MockRecentViewsBloc extends Mock implements RecentViewsBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockRecentViewsBloc mockRecentViewsBloc;
  late MockAuthBloc mockAuthBloc;
  late StreamController<RecentViewsState> recentViewsController;
  late StreamController<AuthState> authController;

  setUp(() {
    setupCoverUrlService();
    mockRecentViewsBloc = MockRecentViewsBloc();
    mockAuthBloc = MockAuthBloc();
    recentViewsController = StreamController<RecentViewsState>.broadcast();
    authController = StreamController<AuthState>.broadcast();
    when(() => mockRecentViewsBloc.stream).thenAnswer((_) => recentViewsController.stream);
    when(() => mockAuthBloc.stream).thenAnswer((_) => authController.stream);
  });

  tearDown(() {
    recentViewsController.close();
    authController.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RecentViewsBloc>.value(value: mockRecentViewsBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const Scaffold(
          body: SectionRecentViews(),
        ),
      ),
    );
  }

  group('SectionRecentViews', () {
    testWidgets('muestra SizedBox.shrink cuando estado es RecentViewsInitial', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockRecentViewsBloc.state).thenReturn(const RecentViewsInitial());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es RecentViewsLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockRecentViewsBloc.state).thenReturn(const RecentViewsLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es RecentViewsEmpty', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockRecentViewsBloc.state).thenReturn(const RecentViewsEmpty());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es RecentViewsError', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockRecentViewsBloc.state).thenReturn(const RecentViewsError('error'));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando no hay usuario autenticado', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
      when(() => mockRecentViewsBloc.state).thenReturn(const RecentViewsInitial());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsNothing);
    });

    testWidgets('renderiza header y cards cuando RecentViewsLoaded', (tester) async {
      final books = [
        createTestBook(id: 1, name: 'Libro Reciente A'),
        createTestBook(id: 2, name: 'Libro Reciente B'),
      ];

      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        UserEntity(id: 'user-1', email: 'test@test.com', role: UserRole.user),
      ));
      when(() => mockRecentViewsBloc.state).thenReturn(RecentViewsLoaded(books));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Continuar leyendo'), findsOneWidget);
      expect(find.text('Libro Reciente A'), findsOneWidget);
      expect(find.text('Libro Reciente B'), findsOneWidget);
    });
  });
}
