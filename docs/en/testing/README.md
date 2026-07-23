# Testing Strategy

> 55 test files across 5 categories, covering BLoCs, entities, repositories, use
cases, and widgets.

← [Back to index](../README.md)

## Overview

Noveles has **55 test files** organized by layer. Tests use `mocktail` for
mocking and `bloc_test` for BLoC state verification.

## Test Categories

| Category | Count | Path | What's Tested |
| ---------- | ------- | ------ | --------------- |
| BLoC Tests | 14 | test/bloc/ | State transitions,event handling,error map... |
| E Tests | 5 | test/entities/ | E construction,copyWith,props,equality |
| Repo Tests | 8 | test/repositories/ | Data layer: Supabase queries,error ... |
| Use Case Tests | 3 | test/use_cases/ | Business logic: domain rules, Resu... |
| Widget Tests | 20 | `test/widgets/` | UI rendering, user interactions |
| **Total** | **55** | | |

### BLoC Tests (14 files)

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
| `profile_bloc_test.dart` | `ProfileBloc` |
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

### Repository Tests (8 files)

| File | Repository Tested |
| ------ | ------------------- |
| `analytics_repository_test.dart` | `AnalyticsRepository` |
| `auth_repository_test.dart` | `AuthRepository` |
| `book_repository_test.dart` | `BookRepository` |
| `chapter_repository_test.dart` | `ChapterRepository` |
| `genre_repository_test.dart` | `GenreRepository` |
| `label_repository_test.dart` | `LabelRepository` |
| `profiles_repository_test.dart` | `ProfilesRepository` |
| `took_repository_test.dart` | `TookRepository` |

### Use Case Tests (3 files)

| File | Use Cases Tested |
| ------ | ----------------- |
| `get_all_profiles_test.dart` | `GetAllProfiles` |
| `label_use_cases_test.dart` | Label use cases |
| `track_book_view_test.dart` | `TrackBookView` |

### Widget Tests (20 files)

| File | Component Tested |
| ------ | ----------------- |
| `main_screen_sections_test.dart` | Main screen sections |
| `section_header_test.dart` | Section header widget |
| `section_novedades_test.dart` | Novedades section |
| `section_mas_vistos_test.dart` | Más vistos section |
| `section_populares_test.dart` | Populares section |
| `section_recent_views_test.dart` | Recent views section |
| `genre_chip_styled_test.dart` | Genre chip styled widget |
| `book_card_horizontal_test.dart` | Horizontal book card |
| `book_card_vertical_test.dart` | Vertical book card |
| `book_detail_content_test.dart` | Book detail content |
| `book_took_list_test.dart` | Book took list |
| `carousel_dots_test.dart` | Carousel dots indicator |
| `chapter_screen_read_test.dart` | Chapter reading screen |
| `took_screen_test.dart` | Took screen |
| `confirmation_dialog_test.dart` | Confirmation dialog |
| `empty_state_test.dart` | Empty state widget |
| `snackbar_helper_test.dart` | Snackbar helper |
| `admin_main_screen_test.dart` | AdminDashScreen |
| `app_drawer_test.dart` | AppDrawer (NavigationDrawer, role-based menus) |
| `test_helpers.dart` | Shared test utilities (helper file, not a test) |

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
| BLoC tests | ✅ 14/14 | All BLoCs covered |
| E tests | ⚠️ 5/9 | Missing: GenreEntity,FavoriteEntity,BookWithRelations,... |
| Repository tests | ✅ 8/8 | All repositories covered |
| Use case tests | ⚠️ 3/46 | Only 3 use cases tested out of 46 |
| Widget tests | ✅ 20/20 | All widgets have tests now |
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
- Favorites (3 repository methods untested)

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

> Last verified: 2026-07-23
