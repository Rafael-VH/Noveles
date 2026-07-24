# Estrategia de testing

> 63 archivos de test en 5 categorías, cubriendo BLoCs, entidades,
> repositorios, casos de uso y widgets.

← [Volver al índice](../README.md)

## Visión general

Noveles tiene **63 archivos de test** organizados por capa. Los tests
usan `mocktail` para mocking y `bloc_test` para verificación de estado de
BLoCs.

## Categorías de test

| Categoría | Cantidad | Ruta | Lo que se testea |
| ---------- | ------- | ------ | --------------- |
| Tests BLoC | 16 | test/bloc/ | Transiciones, eventos, mapeo de errores |
| Tests de Entidades | 5 | test/entities/ | copyWith, props, igualdad |
| Tests de Repos | 9 | test/repositories/ | Queries Supabase, mapeo errores |
| Tests de Casos de Uso | 7 | test/use_cases/ | Reglas de dominio, Result |
| Tests de Widgets | 26 | `test/widgets/` | Renderizado e interacciones |
| **Total** | **63** | | |

### Tests BLoC (16 archivos)

| Archivo | BLoC testeado |
| ------ | ------------- |
| `admin_analytics_bloc_test.dart` | `AdminAnalyticsBloc` |
| `admin_bloc_test.dart` | `AdminBloc` |
| `admin_users_bloc_test.dart` | `AdminUsersBloc` |
| `auth_bloc_test.dart` | `AuthBloc` |
| `book_bloc_test.dart` | `BookBloc` |
| `chapter_bloc_test.dart` | `ChapterBloc` |
| `genre_bloc_test.dart` | `GenreBloc` |
| `genre_cubit_test.dart` | `GenreCubit` |
| `label_bloc_test.dart` | `LabelBloc` |
| `popular_views_bloc_test.dart` | `PopularViewsBloc` |
| `profile_bloc_test.dart` | `ProfileBloc` |
| `recent_views_bloc_test.dart` | `RecentViewsBloc` |
| `scan_book_bloc_test.dart` | `ScanBookBloc` |
| `scan_chapter_bloc_test.dart` | `ScanChapterBloc` |
| `scan_cover_bloc_test.dart` | `ScanCoverBloc` |
| `scan_took_bloc_test.dart` | `ScanTookBloc` |

### Tests de Entidades (5 archivos)

| Archivo | Entidad testeada |
| ------ | --------------- |
| `book_entity_test.dart` | `BookEntity` |
| `chapter_entity_test.dart` | `ChapterEntity` |
| `label_entity_test.dart` | `LabelEntity` |
| `took_entity_test.dart` | `TookEntity` |
| `user_role_test.dart` | enum `UserRole` |

### Tests de Repositorios (9 archivos)

| Archivo | Repositorio testeado |
| ------ | ------------------- |
| `analytics_repository_test.dart` | `AnalyticsRepository` |
| `auth_repository_test.dart` | `AuthRepository` |
| `book_repository_test.dart` | `BookRepository` |
| `chapter_cache_test.dart` | `ChapterCache` |
| `chapter_repository_test.dart` | `ChapterRepository` |
| `genre_repository_test.dart` | `GenreRepository` |
| `label_repository_test.dart` | `LabelRepository` |
| `profiles_repository_test.dart` | `ProfilesRepository` |
| `took_repository_test.dart` | `TookRepository` |

### Tests de Casos de Uso (7 archivos)

| Archivo | Casos de uso testeados |
| ------ | ----------------- |
| `get_all_profiles_test.dart` | `GetAllProfiles` |
| `get_most_viewed_books_test.dart` | `GetMostViewedBooks` |
| `get_read_chapter_ids_test.dart` | `GetReadChapterIds` |
| `get_recent_views_test.dart` | `GetRecentViews` |
| `label_use_cases_test.dart` | Casos de uso de etiquetas |
| `mark_chapter_as_read_test.dart` | `MarkChapterAsRead` |
| `track_book_view_test.dart` | `TrackBookView` |

### Tests de Widgets (26 archivos)

| Archivo | Componente testeado |
| ------ | ----------------- |
| `admin_main_screen_test.dart` | AdminDashScreen |
| `app_drawer_test.dart` | AppDrawer (NavigationDrawer, menús por rol) |
| `book_card_horizontal_test.dart` | Tarjeta de libro horizontal |
| `book_card_vertical_test.dart` | Tarjeta de libro vertical |
| `book_detail_content_test.dart` | Contenido de detalle de libro |
| `book_took_list_test.dart` | Lista de tomos de libro |
| `card_info_detail_test.dart` | Tarjeta de info detalle |
| `carousel_dots_test.dart` | Indicador de puntos de carrusel |
| `chapter_screen_read_test.dart` | Pantalla de lectura de capítulos |
| `confirmation_dialog_test.dart` | Diálogo de confirmación |
| `empty_state_test.dart` | Widget de estado vacío |
| `genre_chip_styled_test.dart` | Widget de chip de género estilizado |
| `main_screen_sections_test.dart` | Secciones de pantalla principal |
| `reading_settings_bar_test.dart` | Barra de ajustes de lectura |
| `section_header_test.dart` | Widget de encabezado de sección |
| `section_mas_vistos_test.dart` | Sección de más vistos |
| `section_novedades_test.dart` | Sección de novedades |
| `section_populares_test.dart` | Sección de populares |
| `section_recent_views_test.dart` | Sección de vistas recientes |
| `section_title_test.dart` | Widget de título de sección |
| `sliver_app_bar_book_test.dart` | Sliver app bar para libros |
| `snackbar_helper_test.dart` | Helper de snackbar |
| `theme_test.dart` | Tests de tema |
| `took_screen_test.dart` | Pantalla de tomo |
| `took_sliver_header_test.dart` | Sliver header de tomo |
| `visual_smoke_test.dart` | Tests visuales smoke |

## Patrones usados

### Patrón de test BLoC

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] on CheckAuthSession',
  build: () => AuthBloc(mockAuthRepository),
  act: (bloc) => bloc.add(CheckAuthSession()),
  expect: () => [
    isA<AuthLoading>(),
    isA<AuthAuthenticated>(),
  ],
);
```text

- Usa `mocktail` para mocking de repositorios (`MockAuthRepository`)
- Usa el helper `blocTest` de `bloc_test` para arrange-act-assert
- Verifica el orden de emisión de estados

### Patrón de test de Entidades

```dart
test('equality', () {
  final a = BookEntity(id: 1, name: 'Test', ...);
  final b = BookEntity(id: 1, name: 'Test', ...);
  expect(a, equals(b));
});

test('copyWith', () {
  final original = BookEntity(id: 1, name: 'Test', ...);
  final updated = original.copyWith(name: 'Updated');
  expect(updated.name, 'Updated');
  expect(updated.id, original.id);
});
```text

### Patrón de test de Widgets

```dart
testWidgets('renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => MockBloc<...>(),
        child: const MyWidget(),
      ),
    ),
  );
  expect(find.text('Expected'), findsOneWidget);
});
```text

## Brechas de cobertura

| Área | Estado | Notas |
| ------ | -------- | ------- |
| Tests BLoC | ✅ 16/16 | Todos los BLoCs cubiertos |
| Tests de Entidades | ⚠️ 5/13 | Faltan: GenreEntity, FavoriteEntity, BookWithRelations, AnalyticsOverview, AnalyticsTrendEntry, AnalyticsTopBook, ... |
| Tests de Repositorios | ✅ 9/9 | Todos los repositorios cubiertos |
| Tests de Casos de Uso | ⚠️ 7/53 | Solo 7 casos de uso testeados de 53 |
| Tests de Widgets | ✅ 26/26 | Todos los widgets tienen tests |
| Tests de Integración | ❌ Ninguno | No hay directorio `integration_test/` |

### Casos de uso sin testear

La mayoría de los casos de uso carecen de tests dedicados. Las siguientes
funcionalidades **no tienen tests de casos de uso**:

- Auth (5 casos de uso sin testear)
- Books (10 casos de uso sin testear)
- Chapters (7 casos de uso sin testear)
- Tooks (6 casos de uso sin testear)
- Genres (5 casos de uso sin testear)
- Profiles (6 sin testear de 6)
- Labels + Label Rules (4 sin testear de 11)

## Cómo ejecutar

```bash
# Ejecutá todos los tests
flutter test

# Ejecutá con cobertura
flutter test --coverage

# Ejecutá una categoría específica
flutter test test/bloc/
flutter test test/entities/

# Ver la cobertura (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```text

---

> Última verificación: 2026-07-24
