# Tasks: Batch 0 — Feature-Grouped Directory Restructure

## Review Workload Forecast

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Medium

| Field | Value |
|-------|-------|
| Estimated changed lines | ~300 (imports + barrels + DI split) |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR (all import changes, zero behavioral risk) |
| Delivery strategy | exception-ok |

## Phase 1: Auth Feature Group

- [ ] 1.1 Create `lib/features/domain/auth/` with barrel `auth.dart` exporting `auth_repository.dart`
- [ ] 1.2 Move `domain/repositories/auth_repository.dart` → `domain/auth/auth_repository.dart`; update its import of `entities.dart` → `profiles/profiles.dart`
- [ ] 1.3 Move use cases: `login.dart`, `logout.dart`, `register.dart`, `get_current_user.dart`, `listen_auth_state.dart`, `change_password.dart` → `domain/auth/`; update each import from `repositories/repositories.dart` to `auth/auth.dart` and `entities/entities.dart` to `profiles/profiles.dart`
- [ ] 1.4 Create `domain/auth/auth.dart` barrel exporting all auth use cases + auth_repository
- [ ] 1.5 Create `lib/features/data/auth/` with barrel `auth.dart` exporting `auth_repository_impl.dart`
- [ ] 1.6 Move `data/repositories/auth_repository_impl.dart` → `data/auth/auth_repository_impl.dart`; update imports from `domain/entities/entities.dart` → `domain/profiles/profiles.dart` and `domain/repositories/repositories.dart` → `domain/auth/auth.dart`
- [ ] 1.7 Create `lib/core/di/injection_auth.dart` with auth repo, 6 use cases, and `AuthBloc` registration; call `initAuthDependencies()`

## Phase 2: Books Feature Group

- [ ] 2.1 Create `lib/features/domain/books/` directories
- [ ] 2.2 Move `domain/entities/book_entity.dart` → `domain/books/book_entity.dart`; update intra-entity imports (genre, label, took) to new paths
- [ ] 2.3 Move `domain/repositories/book_repository.dart` → `domain/books/book_repository.dart`; update entity import
- [ ] 2.4 Move use cases: `create_book.dart`, `get_book.dart`, `get_book_by_id.dart`, `get_books_by_genre.dart`, `update_book.dart`, `delete_book.dart`, `toggle_book_visibility.dart`, `upload_cover.dart`, `get_book_labels.dart` → `domain/books/`; update `repositories/repositories.dart` → `books/books.dart`
- [ ] 2.5 Move `domain/helpers/text_stats.dart` → `domain/books/text_stats.dart`
- [ ] 2.6 Create `domain/books/books.dart` barrel
- [ ] 2.7 Create `lib/features/data/books/` directory
- [ ] 2.8 Move `data/models/book_model.dart` → `data/books/book_model.dart`; update model cross-imports (genre, label, took) and entity import
- [ ] 2.9 Move `data/repositories/book_repository_impl.dart` → `data/books/book_repository_impl.dart`; update imports
- [ ] 2.10 Create `data/books/books.dart` barrel
- [ ] 2.11 Create `lib/core/di/injection_books.dart` with book repo, 9 use cases, and `BookBloc` registration

## Phase 3: Chapters Feature Group

- [ ] 3.1 Create `lib/features/domain/chapters/` directory
- [ ] 3.2 Move `domain/entities/chapter_entity.dart` → `domain/chapters/chapter_entity.dart`
- [ ] 3.3 Move `domain/repositories/chapter_repository.dart` → `domain/chapters/chapter_repository.dart`
- [ ] 3.4 Move use cases: `create_chapter.dart`, `get_chapter.dart`, `get_chapter_by_id.dart`, `get_chapter_content.dart`, `update_chapter.dart`, `delete_chapter.dart` → `domain/chapters/`; update imports
- [ ] 3.5 Create `domain/chapters/chapters.dart` barrel
- [ ] 3.6 Create `lib/features/data/chapters/` directory
- [ ] 3.7 Move `data/models/chapter_model.dart` → `data/chapters/chapter_model.dart`
- [ ] 3.8 Move `data/repositories/chapter_repository_impl.dart` → `data/chapters/chapter_repository_impl.dart`; update imports
- [ ] 3.9 Create `data/chapters/chapters.dart` barrel
- [ ] 3.10 Create `lib/core/di/injection_chapters.dart` with chapter repo, 6 use cases, and `ChapterBloc` registration

## Phase 4: Genres Feature Group

- [ ] 4.1 Create `lib/features/domain/genres/` directory
- [ ] 4.2 Move `domain/entities/genre_entity.dart` → `domain/genres/genre_entity.dart`
- [ ] 4.3 Move `domain/repositories/genre_repository.dart` → `domain/genres/genre_repository.dart`
- [ ] 4.4 Move use cases: `create_genre.dart`, `get_genre.dart`, `get_genre_by_id.dart`, `update_genre.dart`, `delete_genre.dart` → `domain/genres/`; update imports
- [ ] 4.5 Create `domain/genres/genres.dart` barrel
- [ ] 4.6 Create `lib/features/data/genres/` directory
- [ ] 4.7 Move `data/models/genre_model.dart` → `data/genres/genre_model.dart`
- [ ] 4.8 Move `data/repositories/genre_repository_impl.dart` → `data/genres/genre_repository_impl.dart`; update imports
- [ ] 4.9 Create `data/genres/genres.dart` barrel
- [ ] 4.10 Create `lib/core/di/injection_genres.dart` with genre repo, 5 use cases, and `GenreBloc` registration

## Phase 5: Labels Feature Group

- [ ] 5.1 Create `lib/features/domain/labels/` directory
- [ ] 5.2 Move `domain/entities/label_entity.dart` → `domain/labels/label_entity.dart`
- [ ] 5.3 Move `domain/repositories/label_repository.dart` → `domain/labels/label_repository.dart`
- [ ] 5.4 Move use cases: `create_label.dart`, `get_labels.dart`, `update_label.dart`, `delete_label.dart`, `assign_label_to_book.dart`, `remove_label_from_book.dart` → `domain/labels/`; update imports
- [ ] 5.5 Create `domain/labels/labels.dart` barrel
- [ ] 5.6 Create `lib/features/data/labels/` directory
- [ ] 5.7 Move `data/models/label_model.dart` → `data/labels/label_model.dart`
- [ ] 5.8 Move `data/repositories/label_repository_impl.dart` → `data/labels/label_repository_impl.dart`; update imports
- [ ] 5.9 Create `data/labels/labels.dart` barrel
- [ ] 5.10 Create `lib/core/di/injection_labels.dart` with label repo, 7 use cases, and `LabelBloc` registration

## Phase 6: Profiles Feature Group

- [ ] 6.1 Create `lib/features/domain/profiles/` directory
- [ ] 6.2 Move `domain/entities/user_entity.dart` → `domain/profiles/user_entity.dart`
- [ ] 6.3 Move `domain/repositories/profiles_repository.dart` → `domain/profiles/profiles_repository.dart`; update entity import
- [ ] 6.4 Move use cases: `get_profile.dart`, `update_profile.dart`, `upload_avatar.dart`, `get_all_profiles.dart` → `domain/profiles/`; update imports
- [ ] 6.5 Create `domain/profiles/profiles.dart` barrel
- [ ] 6.6 Create `lib/features/data/profiles/` directory
- [ ] 6.7 Move `data/models/user_model.dart` → `data/profiles/user_model.dart`; update entity import
- [ ] 6.8 Move `data/repositories/profiles_repository_impl.dart` → `data/profiles/profiles_repository_impl.dart`; update imports
- [ ] 6.9 Create `data/profiles/profiles.dart` barrel
- [ ] 6.10 Create `lib/core/di/injection_profiles.dart` with profiles repo, 4 use cases, and `ProfileBloc` registration

## Phase 7: Tooks Feature Group

- [ ] 7.1 Create `lib/features/domain/tooks/` directory
- [ ] 7.2 Move `domain/entities/took_entity.dart` → `domain/tooks/took_entity.dart`; update chapter_entity import
- [ ] 7.3 Move `domain/repositories/took_repository.dart` → `domain/tooks/took_repository.dart`
- [ ] 7.4 Move use cases: `create_took.dart`, `get_took.dart`, `get_took_by_id.dart`, `update_took.dart`, `delete_took.dart` → `domain/tooks/`; update imports
- [ ] 7.5 Create `domain/tooks/tooks.dart` barrel
- [ ] 7.6 Create `lib/features/data/tooks/` directory
- [ ] 7.7 Move `data/models/took_model.dart` → `data/tooks/took_model.dart`; update chapter_model import
- [ ] 7.8 Move `data/repositories/took_repository_impl.dart` → `data/tooks/took_repository_impl.dart`; update imports
- [ ] 7.9 Create `data/tooks/tooks.dart` barrel
- [ ] 7.10 Create `lib/core/di/injection_tooks.dart` with took repo and 5 use cases

## Phase 8: Scan + Admin DI

- [ ] 8.1 Create `lib/core/di/injection_scan.dart` — registers `ScanBloc` with all its injected use cases (imports from feature barrels)
- [ ] 8.2 Create `lib/core/di/injection_admin.dart` — registers `AdminBloc` + `AdminUsersBloc`

## Phase 9: Main injection.dart

- [ ] 9.1 Rewrite `lib/core/di/injection.dart` as orchestrator importing and calling all 9 `init*Dependencies()` functions

## Phase 10: Presentation + Widget Import Updates

- [ ] 10.1 Update all imports in `lib/features/presentation/bloc/` files to new feature paths (auth_bloc, book_bloc, chapter_bloc, genre_bloc, label_bloc, profile_bloc, scan_bloc, admin_bloc, admin_users_bloc, and their state/event files)
- [ ] 10.2 Update all imports in `lib/features/presentation/screens/` and `lib/features/presentation/views/` files
- [ ] 10.3 Update imports in `lib/features/presentation/widgets/` (carousel_appbar_sliver.dart imports entities)

## Phase 11: Test Import Updates

- [ ] 11.1 Update imports in `test/repositories/*_test.dart` (3 files)
- [ ] 11.2 Update imports in `test/bloc/*_test.dart` (9 files)
- [ ] 11.3 Update imports in `test/entities/*_test.dart` (4 files)
- [ ] 11.4 Update imports in `test/use_cases/*_test.dart` (2 files)
- [ ] 11.5 Update imports in `test/widgets/*_test.dart` (1 file)

## Phase 12: Cleanup + Verification

- [ ] 12.1 Delete empty old directories: `data/models/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/use_cases/`, `domain/helpers/`
- [ ] 12.2 Run `dart analyze` — fix any remaining import errors
- [ ] 12.3 Run `flutter test` — all tests pass
