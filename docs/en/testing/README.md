# Testing Strategy

> 65 test files across 6 categories, covering the architecture guard, BLoCs,
entities, repositories, use cases, and widgets.

← [Back to index](../README.md)

## Overview

Noveles has **65 test files** organized by layer, plus shared helpers in
`test/utils/` and `test/widgets/`. Tests use `mocktail` for mocking and
`bloc_test` for BLoC state verification.

## Test Categories

| Category | Count | Path | What's Tested |
| ---------- | ------- | ------ | --------------- |
| Architecture Tests | 1 | test/architecture/ | The backend seam: the vendor SDK stays behind the ports |
| BLoC Tests | 16 | test/bloc/ | State transitions, event handling, error mapping |
| Entity Tests | 5 | test/entities/ | Entity construction, copyWith, props, equality |
| Repo Tests | 9 | test/repositories/ | Data layer: gateway queries, error mapping, payload assertions |
| Use Case Tests | 7 | test/use_cases/ | Business logic: domain rules, Result handling |
| Widget Tests | 27 | `test/widgets/` | UI rendering, user interactions |
| **Total** | **65** | | |

Beware of the counts when adding files: `test/widgets/test_helpers.dart` and
`test/utils/backend_mocks.dart` are shared helpers, not test files, and the
suite does not run them.

### Architecture Tests (1 file)

| File | Guards |
| ------ | -------- |
| `backend_seam_test.dart` | That the vendor SDK stays behind the ports — nothing outside `lib/core/backend/` imports it or names a vendor type, aggregate reads stay inside the adapter, and repository tests double the ports instead of the SDK |

### BLoC Tests (16 files)

| File | BLoC Tested |
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

### Entity Tests (5 files)

| File | Entity Tested |
| ------ | --------------- |
| `book_entity_test.dart` | `BookEntity` |
| `chapter_entity_test.dart` | `ChapterEntity` |
| `label_entity_test.dart` | `LabelEntity` |
| `took_entity_test.dart` | `TookEntity` |
| `user_role_test.dart` | `UserRole` enum |

### Repository Tests (9 files)

| File | Repository Tested |
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

All of them talk to the **backend ports**, not to Supabase: they stub
`DataGateway`, `AuthGateway` and `StorageGateway` through the doubles in
`test/utils/backend_mocks.dart`. See
[Repository Test Pattern](#repository-test-pattern) below.

### Use Case Tests (7 files)

| File | Use Cases Tested |
| ------ | ----------------- |
| `get_all_profiles_test.dart` | `GetAllProfiles` |
| `get_most_viewed_books_test.dart` | `GetMostViewedBooks` |
| `get_read_chapter_ids_test.dart` | `GetReadChapterIds` |
| `get_recent_views_test.dart` | `GetRecentViews` |
| `label_use_cases_test.dart` | Label use cases |
| `mark_chapter_as_read_test.dart` | `MarkChapterAsRead` |
| `track_book_view_test.dart` | `TrackBookView` |

### Widget Tests (27 files)

| File | Component Tested |
| ------ | ----------------- |
| `admin_main_screen_test.dart` | AdminDashScreen |
| `app_drawer_test.dart` | AppDrawer (NavigationDrawer, role-based menus) |
| `book_card_horizontal_test.dart` | Horizontal book card |
| `book_card_vertical_test.dart` | Vertical book card |
| `book_detail_content_test.dart` | Book detail content |
| `book_metadata_grid_test.dart` | Book metadata grid |
| `book_took_list_test.dart` | Book took list |
| `card_info_detail_test.dart` | Card info detail |
| `carousel_dots_test.dart` | Carousel dots indicator |
| `chapter_screen_read_test.dart` | Chapter reading screen |
| `confirmation_dialog_test.dart` | Confirmation dialog |
| `empty_state_test.dart` | Empty state widget |
| `genre_chip_styled_test.dart` | Genre chip styled widget |
| `main_screen_sections_test.dart` | Main screen sections |
| `reading_settings_bar_test.dart` | Reading settings bar |
| `scan_chapter_edit_screen_test.dart` | Chapter editor (content type: storage file vs inline text) |
| `section_title_test.dart` | SectionTitle widget (merged from section_header_test + section_title_test) |
| `section_mas_vistos_test.dart` | Más vistos section |
| `section_novedades_test.dart` | Novedades section |
| `section_populares_test.dart` | Populares section |
| `section_recent_views_test.dart` | Recent views section |
| `sliver_app_bar_book_test.dart` | Sliver app bar for books |
| `snackbar_helper_test.dart` | Snackbar helper |
| `theme_test.dart` | Theme tests |
| `took_screen_test.dart` | Took screen |
| `took_sliver_header_test.dart` | Took sliver header |
| `visual_smoke_test.dart` | Visual smoke tests |

## Patterns Used

### BLoC Test Pattern

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

- Uses `mocktail` for repository mocking (`MockAuthRepository`)
- Uses `bloc_test` `blocTest` helper for arrange-act-assert
- Verifies state emission order

### Entity Test Pattern

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

### Repository Test Pattern

Repositories depend on the backend ports, so their tests double the ports — not
the vendor SDK. `FakeBackend` wires one query builder per table plus the auth and
storage doubles:

```dart
final backend = FakeBackend();
final repository = GenreRepositoryImpl(backend.data);

backend.rows('genres', [
  {'id': 1, 'name': 'Fantasy'},
]);

final result = await repository.getGenres();
expect(result, isA<Ok<List<GenreEntity>>>());
```text

- Stub only the terminal you care about (`rows`, `maybeRow`, `oneRow`, `update`,
  `delete`); the fluent chain is already wired
- Use `capturedInsert` / `capturedUpdate` / `capturedRpcParams` to assert the
  payload — that is how ownership (`created_by`) and `content_type` are verified
- `backend_seam_test.dart` fails the build if a repository test imports the SDK

### Widget Test Pattern

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

## Coverage Gaps

| Area | Status | Notes |
| ------ | -------- | ------- |
| Architecture tests | ✅ 1/1 | Guards the backend seam |
| BLoC tests | ✅ 16/16 | All BLoCs covered |
| Entity tests | ⚠️ 5/13 | Missing: GenreEntity, FavoriteEntity, BookWithRelations, AnalyticsOverview, AnalyticsTrendEntry, AnalyticsTopBook, ... |
| Repository tests | ✅ 9/9 | All repositories covered |
| Use case tests | ⚠️ 7/53 | Only 7 use cases tested out of 53 |
| Widget tests | ✅ 27/27 | All widgets have tests |
| Integration tests | ❌ None | No `integration_test/` directory |

### Missing Use Case Tests

Most use cases lack dedicated tests. The following features have **no use case
tests**:

- Auth (5 use cases untested)
- Books (10 use cases untested)
- Chapters (7 use cases untested)
- Tooks (6 use cases untested)
- Genres (5 use cases untested)
- Profiles (6 untested of 6)
- Labels + Label Rules (4 untested of 11)

## How to Run

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific category
flutter test test/bloc/
flutter test test/entities/

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```text

---

> Last verified: 2026-09-21
