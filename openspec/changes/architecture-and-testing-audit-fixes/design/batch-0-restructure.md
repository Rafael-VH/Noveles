# Design: Batch 0 — Feature-Grouped Directory Restructure

## Technical Approach

Move files from flat layer directories into feature-grouped subdirectories under `lib/features/data/{feature}/` and `lib/features/domain/{feature}/`, matching the existing `presentation/{feature}/` structure. Update every import path that references the old locations. Split the monolithic `injection.dart` into per-feature DI files with a main orchestrator. No code is added, removed, or modified beyond import paths and the DI split.

## Architecture Decisions

| Decision | Choice | Alternatives | Rationale |
|----------|--------|-------------|-----------|
| `UserEntity` location | `domain/profiles/` | `domain/auth/` or shared | "User profile" is the owning domain concept; auth imports from profiles, not vice versa |
| `text_stats.dart` location | `domain/books/` | Separate `domain/helpers/` | Only used by `ChapterScreen` for book text stats; keeping a single-file directory is unnecessary overhead |
| Per-feature DI files | `injection_{feature}.dart` | Single monolithic file | One change per feature, parallel-friendly, matches presentation BLoC lifecycle pattern |
| Barrel files | Per-feature barrels | Single flat barrel | Eliminates ambiguous imports; each feature exports only its own types |

## File-by-File Mapping

### data/models/ → data/{feature}/

| Source | Target | Intra-feature dep? |
|--------|--------|--------------------|
| `data/models/book_model.dart` | `data/books/book_model.dart` | Imports genre, label, took models |
| `data/models/chapter_model.dart` | `data/chapters/chapter_model.dart` | None |
| `data/models/genre_model.dart` | `data/genres/genre_model.dart` | None |
| `data/models/label_model.dart` | `data/labels/label_model.dart` | None |
| `data/models/took_model.dart` | `data/tooks/took_model.dart` | Imports chapter model |
| `data/models/user_model.dart` | `data/profiles/user_model.dart` | None |

### data/repositories/ → data/{feature}/

| Source | Target |
|--------|--------|
| `data/repositories/auth_repository_impl.dart` | `data/auth/auth_repository_impl.dart` |
| `data/repositories/book_repository_impl.dart` | `data/books/book_repository_impl.dart` |
| `data/repositories/chapter_repository_impl.dart` | `data/chapters/chapter_repository_impl.dart` |
| `data/repositories/genre_repository_impl.dart` | `data/genres/genre_repository_impl.dart` |
| `data/repositories/label_repository_impl.dart` | `data/labels/label_repository_impl.dart` |
| `data/repositories/profiles_repository_impl.dart` | `data/profiles/profiles_repository_impl.dart` |
| `data/repositories/took_repository_impl.dart` | `data/tooks/took_repository_impl.dart` |

### domain/entities/ → domain/{feature}/

| Source | Target |
|--------|--------|
| `domain/entities/book_entity.dart` | `domain/books/book_entity.dart` |
| `domain/entities/chapter_entity.dart` | `domain/chapters/chapter_entity.dart` |
| `domain/entities/genre_entity.dart` | `domain/genres/genre_entity.dart` |
| `domain/entities/label_entity.dart` | `domain/labels/label_entity.dart` |
| `domain/entities/took_entity.dart` | `domain/tooks/took_entity.dart` |
| `domain/entities/user_entity.dart` | `domain/profiles/user_entity.dart` |

### domain/repositories/ → domain/{feature}/

| Source | Target |
|--------|--------|
| `domain/repositories/auth_repository.dart` | `domain/auth/auth_repository.dart` |
| `domain/repositories/book_repository.dart` | `domain/books/book_repository.dart` |
| `domain/repositories/chapter_repository.dart` | `domain/chapters/chapter_repository.dart` |
| `domain/repositories/genre_repository.dart` | `domain/genres/genre_repository.dart` |
| `domain/repositories/label_repository.dart` | `domain/labels/label_repository.dart` |
| `domain/repositories/profiles_repository.dart` | `domain/profiles/profiles_repository.dart` |
| `domain/repositories/took_repository.dart` | `domain/tooks/took_repository.dart` |

### domain/use_cases/ → domain/{feature}/

| Source | Feature | Source | Feature |
|--------|---------|--------|---------|
| `login.dart` | auth | `logout.dart` | auth |
| `register.dart` | auth | `get_current_user.dart` | auth |
| `listen_auth_state.dart` | auth | `change_password.dart` | auth |
| `create_book.dart` | books | `get_book.dart` | books |
| `get_book_by_id.dart` | books | `get_books_by_genre.dart` | books |
| `update_book.dart` | books | `delete_book.dart` | books |
| `toggle_book_visibility.dart` | books | `upload_cover.dart` | books |
| `get_book_labels.dart` | books | | |
| `create_chapter.dart` | chapters | `get_chapter.dart` | chapters |
| `get_chapter_by_id.dart` | chapters | `get_chapter_content.dart` | chapters |
| `update_chapter.dart` | chapters | `delete_chapter.dart` | chapters |
| `create_genre.dart` | genres | `get_genre.dart` | genres |
| `get_genre_by_id.dart` | genres | `update_genre.dart` | genres |
| `delete_genre.dart` | genres | | |
| `create_label.dart` | labels | `get_labels.dart` | labels |
| `update_label.dart` | labels | `delete_label.dart` | labels |
| `assign_label_to_book.dart` | labels | `remove_label_from_book.dart` | labels |
| `create_took.dart` | tooks | `get_took.dart` | tooks |
| `get_took_by_id.dart` | tooks | `update_took.dart` | tooks |
| `delete_took.dart` | tooks | | |
| `get_profile.dart` | profiles | `update_profile.dart` | profiles |
| `upload_avatar.dart` | profiles | `get_all_profiles.dart` | profiles |

### domain/helpers/ → domain/{feature}/

| Source | Target |
|--------|--------|
| `domain/helpers/text_stats.dart` | `domain/books/text_stats.dart` |

## Import Path Change Patterns

### Pattern A: Files importing flat barrel → import feature barrel
Most use cases, repos, and presentation files import the flat barrels (`entities.dart`, `repositories.dart`, etc.). These become barrel paths per feature, e.g.:
- `import 'package:noveles/features/domain/entities/entities.dart'` → `import 'package:noveles/features/domain/books/books.dart'` (or relevant feature barrel)

### Pattern B: Model cross-imports within data/
`book_model.dart` imports `genre_model.dart`, `label_model.dart`, `took_model.dart`. After move:
- `import 'package:noveles/features/data/models/genre_model.dart'` → `import 'package:noveles/features/data/genres/genre_model.dart'`

### Pattern C: Repository impls importing models and entities
All 7 `*_repository_impl.dart` files import from `data/models/models.dart`, `domain/entities/entities.dart`, `domain/repositories/repositories.dart`. After move, they import their feature's specific files instead.

### Pattern D: Injection.dart imports
All 59 import lines in `injection.dart` must change to feature-grouped paths. After split, each `injection_{feature}.dart` imports only its feature's use cases.

## DI Split Plan

### New files created

| File | Registers |
|------|-----------|
| `lib/core/di/injection_auth.dart` | `AuthRepository` impl, auth use cases (6), `AuthBloc` |
| `lib/core/di/injection_books.dart` | `BookRepository` impl, books use cases (9), `BookBloc` |
| `lib/core/di/injection_chapters.dart` | `ChapterRepository` impl, chapters use cases (6), `ChapterBloc` |
| `lib/core/di/injection_genres.dart` | `GenreRepository` impl, genres use cases (5), `GenreBloc` |
| `lib/core/di/injection_labels.dart` | `LabelRepository` impl, labels use cases (7), `LabelBloc` |
| `lib/core/di/injection_profiles.dart` | `ProfilesRepository` impl, profiles use cases (4), `ProfileBloc` |
| `lib/core/di/injection_tooks.dart` | `TookRepository` impl, tooks use cases (5) |
| `lib/core/di/injection_scan.dart` | `ScanBloc` only (uses repos from other features) |
| `lib/core/di/injection_admin.dart` | `AdminBloc`, `AdminUsersBloc` only (uses repos/use cases from books) |

### Main injection.dart (replaces current 200-line file)

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  initAuthDependencies();
  initBooksDependencies();
  initChaptersDependencies();
  initGenresDependencies();
  initLabelsDependencies();
  initProfilesDependencies();
  initTooksDependencies();
  initScanDependencies();
  initAdminDependencies();
}
```

## Test File Migration

Test files in `test/` use imports referencing the old flat paths. These MUST be updated to the new paths. Test directories stay flat for now (test restructure is deferred to a future batch).

| Test file | Changed imports |
|-----------|----------------|
| `test/repositories/*_test.dart` | Imports entity barrel, repo impl |
| `test/bloc/*_test.dart` | Imports entity barrel, use cases |
| `test/entities/*_test.dart` | Imports entity barrel |
| `test/use_cases/*_test.dart` | Imports entity barrel, repos barrel, use cases |
| `test/widgets/*_test.dart` | Imports entity barrel |

**Total import changes**: ~250 import lines across ~120 files (lib + test).
