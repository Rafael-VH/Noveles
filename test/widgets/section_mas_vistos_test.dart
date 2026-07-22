import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/section_mas_vistos.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'test_helpers.dart';

class MockPopularViewsBloc extends Mock implements PopularViewsBloc {}

void main() {
  late MockPopularViewsBloc mockPopularViewsBloc;
  late StreamController<PopularViewsState> controller;

  setUp(() {
    setupCoverUrlService();
    mockPopularViewsBloc = MockPopularViewsBloc();
    controller = StreamController<PopularViewsState>.broadcast();
    when(() => mockPopularViewsBloc.stream).thenAnswer((_) => controller.stream);
  });

  tearDown(() {
    controller.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<PopularViewsBloc>.value(
        value: mockPopularViewsBloc,
        child: const Scaffold(
          body: SectionMasVistos(),
        ),
      ),
    );
  }

  group('SectionMasVistos', () {
    testWidgets('muestra SizedBox.shrink cuando estado es PopularViewsInitial', (tester) async {
      when(() => mockPopularViewsBloc.state).thenReturn(const PopularViewsInitial());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Más vistos'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es PopularViewsLoading', (tester) async {
      when(() => mockPopularViewsBloc.state).thenReturn(const PopularViewsLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Más vistos'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es PopularViewsEmpty', (tester) async {
      when(() => mockPopularViewsBloc.state).thenReturn(const PopularViewsEmpty());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Más vistos'), findsNothing);
    });

    testWidgets('muestra SizedBox.shrink cuando estado es PopularViewsError', (tester) async {
      when(() => mockPopularViewsBloc.state).thenReturn(const PopularViewsError('error'));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Más vistos'), findsNothing);
    });

    testWidgets('renderiza header y cards cuando PopularViewsLoaded', (tester) async {
      final books = [
        createTestBook(id: 1, name: 'Popular A'),
        createTestBook(id: 2, name: 'Popular B'),
      ];

      when(() => mockPopularViewsBloc.state).thenReturn(PopularViewsLoaded(books));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Más vistos'), findsOneWidget);
      expect(find.text('Popular A'), findsOneWidget);
      expect(find.text('Popular B'), findsOneWidget);
    });
  });
}
