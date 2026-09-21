import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/create_chapter.dart';
import 'package:noveles/features/chapters/domain/delete_chapter.dart';
import 'package:noveles/features/chapters/domain/update_chapter.dart';
import 'package:noveles/features/chapters/domain/upload_chapter_content.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_bloc.dart';
import 'package:noveles/features/scan/presentation/screens/scan_chapter_edit_screen.dart';

class MockCreateChapter extends Mock implements CreateChapter {}

class MockUpdateChapter extends Mock implements UpdateChapter {}

class MockDeleteChapter extends Mock implements DeleteChapter {}

class MockUploadChapterContent extends Mock implements UploadChapterContent {}

void main() {
  late MockCreateChapter mockCreateChapter;
  late MockUpdateChapter mockUpdateChapter;
  late MockDeleteChapter mockDeleteChapter;
  late MockUploadChapterContent mockUploadContent;
  late ScanChapterBloc bloc;

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
    bloc = ScanChapterBloc(
      createChapter: mockCreateChapter,
      updateChapter: mockUpdateChapter,
      deleteChapter: mockDeleteChapter,
      uploadContent: mockUploadContent,
    );
  });

  tearDown(() => bloc.close());

  ThemeData theme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      );

  Widget screen(ChapterEntity? chapter, {int tookId = 1}) => MaterialApp(
        theme: theme(),
        home: BlocProvider<ScanChapterBloc>.value(
          value: bloc,
          child: ScanChapterEditScreen(chapter: chapter, tookId: tookId),
        ),
      );

  /// Locates the [TextFormField] whose floating label is [label].
  Finder fieldWithLabel(String label) => find.ancestor(
        of: find.text(label),
        matching: find.byType(TextFormField),
      );

  group('ScanChapterEditScreen — modo de contenido', () {
    testWidgets('por defecto ofrece el modo archivo (storagePath)',
        (tester) async {
      await tester.pumpWidget(screen(null));

      expect(find.text('Archivo'), findsOneWidget);
      expect(find.text('Texto inline'), findsOneWidget);
      expect(find.text('Seleccionar archivo .md o .txt'), findsOneWidget);
      expect(find.text('Texto del capítulo'), findsNothing);
    });

    testWidgets('al elegir Texto inline muestra el editor y oculta el archivo',
        (tester) async {
      await tester.pumpWidget(screen(null));

      final inlineSegment = find.text('Texto inline');
      await tester.ensureVisible(inlineSegment);
      await tester.tap(inlineSegment);
      await tester.pumpAndSettle();

      expect(find.text('Texto del capítulo'), findsOneWidget);
      expect(find.text('Seleccionar archivo .md o .txt'), findsNothing);
      expect(
        find.text('El contenido se subirá a Supabase Storage'),
        findsNothing,
      );
    });

    testWidgets('al editar un capítulo inline precarga su texto',
        (tester) async {
      final chapter = ChapterEntity(
        id: 5,
        createdAt: DateTime(2024),
        number: '3',
        title: 'Capítulo inline',
        content: 'texto guardado inline',
        tookId: 1,
        contentType: ChapterContentType.inline,
      );

      await tester.pumpWidget(screen(chapter));
      await tester.pumpAndSettle();

      expect(find.text('Texto del capítulo'), findsOneWidget);
      expect(find.text('texto guardado inline'), findsOneWidget);
      // En modo inline no se ofrece el flujo de archivo.
      expect(find.text('Seleccionar archivo .md o .txt'), findsNothing);
    });
  });

  group('ScanChapterEditScreen — guardar', () {
    testWidgets('guarda un capítulo inline con contentType inline',
        (tester) async {
      when(() => mockCreateChapter(any())).thenAnswer((_) async => const Ok(1));

      // Se apila la pantalla como segunda ruta para que el Navigator.pop
      // del guardado sea seguro.
      await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider<ScanChapterBloc>.value(
                      value: bloc,
                      child: const ScanChapterEditScreen(tookId: 1),
                    ),
                  ),
                ),
                child: const Text('abrir editor'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir editor'));
      await tester.pumpAndSettle();

      final inlineSegment = find.text('Texto inline');
      await tester.ensureVisible(inlineSegment);
      await tester.tap(inlineSegment);
      await tester.pumpAndSettle();

      await tester.enterText(fieldWithLabel('Número'), '7');
      await tester.enterText(
        fieldWithLabel('Texto del capítulo'),
        'Capítulo escrito inline',
      );
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockCreateChapter(captureAny()),
      ).captured.single as ChapterEntity;

      expect(captured.contentType, ChapterContentType.inline);
      expect(captured.content, 'Capítulo escrito inline');
      expect(captured.number, '7');
      expect(captured.tookId, 1);
    });

    testWidgets('guarda en modo archivo conservando storagePath',
        (tester) async {
      when(() => mockCreateChapter(any())).thenAnswer((_) async => const Ok(1));

      await tester.pumpWidget(screen(null));

      await tester.enterText(fieldWithLabel('Número'), '9');

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => mockCreateChapter(captureAny()),
      ).captured.single as ChapterEntity;

      expect(captured.contentType, ChapterContentType.storagePath);
      expect(captured.number, '9');
    });
  });
}
