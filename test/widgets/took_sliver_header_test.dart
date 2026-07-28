import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/presentation/screens/widgets/took_sliver_header.dart';
import 'test_helpers.dart';

class _ReturningCoverUrlService extends Mock implements CoverUrlService {}

void main() {
  setUp(() {
    setupCoverUrlService();
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<CoverUrlService>()) {
      GetIt.instance.unregister<CoverUrlService>();
    }
    setupCoverUrlService();
  });

  TookEntity makeTook({
    String cover = '',
    String title = 'Tomo de prueba',
    String number = 'Tomo 1',
  }) {
    return TookEntity(
      id: 10,
      createdAt: DateTime(2026),
      cover: cover,
      number: number,
      title: title,
      chapterCount: 3,
      bookId: 1,
    );
  }

  Widget buildHeader(TookEntity tooks) {
    return wrapWithMaterial(
      Scaffold(
        body: CustomScrollView(
          slivers: [
            TookSliverHeader(tooks: tooks),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    );
  }

  group('TookSliverHeader', () {
    testWidgets('muestra título y número del tomo', (tester) async {
      final tooks = makeTook(title: 'La Guerra', number: 'Tomo 3');

      await tester.pumpWidget(buildHeader(tooks));
      await tester.pump();

      expect(find.text('La Guerra'), findsWidgets);
      expect(find.text('Tomo 3'), findsOneWidget);
    });

    testWidgets('BackdropFilter (blur overlay) está presente', (tester) async {
      await tester.pumpWidget(buildHeader(makeTook()));
      await tester.pump();

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stretch mode activo', (tester) async {
      await tester.pumpWidget(buildHeader(makeTook()));
      await tester.pump();

      final sliverAppBar =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.stretch, isTrue);
    });

    testWidgets('cuando cover está vacío, muestra icono de fallback',
        (tester) async {
      await tester.pumpWidget(buildHeader(makeTook(cover: '')));
      await tester.pump();

      expect(find.byIcon(Icons.menu_book), findsWidgets);
    });

    testWidgets(
        'cuando cover tiene valor, CachedNetworkImage está presente',
        (tester) async {
      // Register a mock that returns the cover string as-is (non-empty → hasCover = true)
      final returningMock = _ReturningCoverUrlService();
      when(() => returningMock.call(any())).thenAnswer((inv) {
        final arg = inv.positionalArguments[0] as String?;
        if (arg == null || arg.isEmpty) return '';
        return 'https://example.com/$arg';
      });

      final getIt = GetIt.instance;
      if (getIt.isRegistered<CoverUrlService>()) {
        getIt.unregister<CoverUrlService>();
      }
      getIt.registerSingleton<CoverUrlService>(returningMock);

      await tester.pumpWidget(buildHeader(makeTook(cover: 'cover.jpg')));
      await tester.pump();

      // Both background and thumbnail CachedNetworkImage should be present
      expect(find.byType(CachedNetworkImage), findsWidgets);

      // Fallback icon should NOT be shown (cover is present)
      expect(find.byIcon(Icons.menu_book), findsNothing);

    });
  });
}
