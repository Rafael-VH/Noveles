import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

final getIt = GetIt.instance;

class MockCoverUrlService extends Mock implements CoverUrlService {}

/// Register a mock CoverUrlService in getIt that returns empty string
/// (so CachedNetworkImage shows its errorWidget without hitting Supabase).
void setupCoverUrlService() {
  if (getIt.isRegistered<CoverUrlService>()) return;
  final mock = MockCoverUrlService();
  when(() => mock.call(any())).thenReturn('');
  getIt.registerSingleton<CoverUrlService>(mock);
}

/// Create a minimal BookWithRelations for testing.
BookWithRelations createTestBook({
  int id = 1,
  DateTime? createdAt,
  String cover = '',
  String name = 'Test Book',
  String author = 'Test Author',
  int tookCount = 5,
  int chapterCount = 10,
}) {
  return BookWithRelations(
    id: id,
    createdAt: createdAt ?? DateTime(2026),
    cover: cover,
    name: name,
    short: name.substring(0, name.length.clamp(0, 20)),
    alternative: '',
    description: 'Descripción de prueba',
    authorId: 1,
    author: author,
    country: 'Argentina',
    state: 'Activo',
    type: 'Novela',
    release: '2026',
    tookCount: tookCount,
    chapterCount: chapterCount,
    source: '',
    link: '',
    isFavorite: false,
    isVisible: true,
    listGenreIds: const [],
    listTookIds: const [],
    listLabelIds: const [],
    createdBy: null,
    listGenre: const [],
    listTook: const [],
    listLabel: const [],
  );
}

/// Wrap a widget in a MaterialApp for testing.
Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: Scaffold(body: child),
  );
}
