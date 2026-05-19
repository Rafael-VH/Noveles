# Audit Fixes — Complete: Development Tasks

## Specification Summary
**Original Proposal**: Fix all 7 critical security/bug/architecture issues, 17 high-impact warnings, and critical UI defects identified in a comprehensive audit of the NovelEs project. Goal is production-readiness without expanding scope into full refactoring.

**Technical Stack**: Flutter 3.3+, Dart, BLoC, Supabase Flutter 2.10+, get_it, Mocktail, bloc_test, CachedNetworkImage

**Target Timeline**: 5 phases across 5 batches, estimated 10-15h total development effort.

---

## Batch Execution Plan

```
Batch A: T-1.x (Phase 1 — DB migrations + config + git operations)        — sequential
Batch B: T-5.x (Phase 5 — UI/UX fixes, no dependencies)                    — parallel with A
Batch C: T-2.x + T-3.x (non-DB) (Phase 2 + Phase 3 code-only fixes)       — after A
Batch D: T-3.3 (column mapping migration — needs Phase 1 DB changes)       — after A
Batch E: T-4.x (Phase 4 — tests, depends on all code changes)              — after B+C+D
```

---

## Phase 1: Security & Database (Foundation)

### T-1.1: Enable RLS on genres, books_genres, authors tables
**Description**: Enable Row-Level Security on the 3 tables missing it, add SELECT policies for authenticated users (matching the pattern on `books`, `tooks`, `chapters`).
**Files**:
- `supabase/migrations/20260522000000_audit_fixes.sql` (create — consolidate ALL Phase 1 SQL here)
**Acceptance Criteria**:
- `genres` has RLS enabled with SELECT policy for authenticated users
- `books_genres` has RLS enabled with SELECT policy for authenticated users
- `authors` has RLS enabled (verify), duplicate SELECT policy dropped and recreated cleanly
- `SELECT tablename, rowsecurity FROM pg_tables WHERE tablename IN ('genres', 'books_genres', 'authors')` — all return `true`
- Unauthenticated user gets empty result for writes; authenticated user can SELECT
**Dependencies**: None
**Estimated Effort**: S (15 min)
**Security Relevance**: Yes — RLS disabled means any authenticated user can write

---

### T-1.2: Add admin write policies across all content tables
**Description**: Create INSERT/UPDATE/DELETE policies for `admin` role on `books`, `genres`, `tooks`, `chapters`, `books_genres`, and `authors` using the `public.is_admin()` helper function. Admin policies bypass the `created_by` ownership check that `scan` policies enforce.
**Files**:
- `supabase/migrations/20260522000000_audit_fixes.sql`
**Acceptance Criteria**:
- Admin role user can INSERT/UPDATE/DELETE on all 6 content tables
- Admin can SELECT all books (including invisible ones) via `"Admin can read all books"` policy
- Existing `scan` role policies remain unchanged
- Regular `user` role cannot write to any content table
**Dependencies**: T-1.1 (RLS must be enabled before policies work)
**Estimated Effort**: M (30 min)
**Security Relevance**: Yes — fixes broken admin RBAC; admin was unable to write content

---

### T-1.3: Remove .env from git tracking and scrub history
**Description**: Remove `.env` from git tracking via `git rm --cached`, verify `.gitignore` entry exists, and if `.env` was ever committed, scrub from git history using `git filter-repo` on a clone.
**Files**:
- `.gitignore` (verify line 35 `.env` entry — already exists)
- `.env` (stays on disk, only removed from git)
**Acceptance Criteria**:
- `git ls-files --cached .env` returns empty
- `.env` entry present in `.gitignore`
- `git log --oneline -- .env` shows no commits touching the file
- After scrub: `git filter-repo --path .env --invert-paths` run on clone; force-push cleaned history
**Dependencies**: None
**Estimated Effort**: S (15 min) for removal; M (45 min) for full history scrub
**Security Relevance**: Yes — `.env` contains SUPABASE_URL and SUPABASE_ANON_KEY

---

### T-1.4: Harden password policy — min 8 chars + mixed-case + digits
**Description**: Update `supabase/config.toml` to require minimum 8 characters and `lower_upper_letters_digits` complexity.
**Files**:
- `supabase/config.toml` (line 175: `minimum_password_length = 8`, line 178: `password_requirements = "lower_upper_letters_digits"`)
**Acceptance Criteria**:
- `minimum_password_length` changed from `6` to `8`
- `password_requirements` changed from `""` to `"lower_upper_letters_digits"`
- Registration with `Ab1` (too short, no mixed case) rejected
- Registration with `abcdefgh` (8 chars, all lowercase) rejected
- Registration with `Abcdefgh1` meets requirements, accepted
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: Yes — weak password policy is a top authentication vulnerability

---

### T-1.5: Enable email confirmation for new users
**Description**: Enable email verification requirement for new user signups in `supabase/config.toml`.
**Files**:
- `supabase/config.toml` (line 219: `enable_confirmations = true`)
**Acceptance Criteria**:
- `enable_confirmations` changed from `false` to `true`
- New user receives confirmation email after registration
- User cannot sign in before confirming email
- User can sign in after clicking confirmation link
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: Yes — allows unverified email signups when disabled

---

### T-1.6: Rate limit email sending to 60s interval
**Description**: Increase email `max_frequency` from 1s to 60s to prevent email bombing abuse.
**Files**:
- `supabase/config.toml` (line 223: `max_frequency = "60s"`)
**Acceptance Criteria**:
- `max_frequency` changed from `"1s"` to `"60s"`
- After deploy, requesting password reset or signup confirmation more than once per 60 seconds is rate-limited
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: Yes — 1s interval enables email bombing attacks

---

### T-1.7: Add missing foreign key indexes for query performance
**Description**: Create B-tree indexes on FK columns that lack them to prevent slow joins at scale.
**Files**:
- `supabase/migrations/20260522000000_audit_fixes.sql`
**Acceptance Criteria**:
- Indexes exist: `idx_tooks_book_id` on `tooks(book_id)`
- Indexes exist: `idx_chapters_took_id` on `chapters(took_id)`
- Indexes exist: `idx_books_author_id` on `books(author_id)` — note: design adds `idx_books_created_by` on `books(created_by)` too
- Indexes exist: `idx_books_labels_book_id` on `books_labels(book_id)`
- Indexes exist: `idx_books_labels_label_id` on `books_labels(label_id)`
- Indexes exist: `idx_books_genres_book_id` on `books_genres(book_id)` — added in design
- Indexes exist: `idx_books_genres_genre_id` on `books_genres(genre_id)` — added in design
- `SELECT indexname FROM pg_indexes WHERE indexname LIKE 'idx_%'` shows all expected
**Dependencies**: None
**Estimated Effort**: S (15 min)
**Security Relevance**: No (performance only)

---

### T-1.8: Replace hardcoded UUIDs with dynamic subquery
**Description**: Instead of hardcoded `c63c361c-...` and `4723bbc3-...` UUIDs in UPDATE statements, use a DO-block subquery that looks up admin user by email with cascading fallbacks.
**Files**:
- `supabase/migrations/20260522000000_audit_fixes.sql`
**Acceptance Criteria**:
- UPDATE statements use `SELECT id FROM auth.users WHERE email = 'rafaelvillahinojosa@gmail.com'` as primary lookup
- Fallback to first `scan` role user, then first auth user
- `WHERE created_by IS NULL` ensures no overwriting of existing assignments
- `RAISE WARNING` if no admin user found (no silent failure)
- After migration: `SELECT COUNT(*) FROM books WHERE created_by IS NULL` returns 0
**Dependencies**: None
**Estimated Effort**: S (15 min)
**Security Relevance**: Yes — hardcoded UUIDs fail on new environments and cause silent data integrity issues

---

### T-1.9: Consolidate redundant migration 20260518020000_fix_authors_rls.sql
**Description**: Remove the duplicate migration file from the repo. Its SQL (authors SELECT policy + UUID correction) is already covered by `20260518010000_admin_ownership.sql` plus the new consolidated migration (T-1.8). Since both migrations already ran on production, only the file needs removal.
**Files**:
- **Delete**: `supabase/migrations/20260518020000_fix_authors_rls.sql`
**Acceptance Criteria**:
- File deleted from repo
- `supabase migration list` no longer shows the deleted file
- `SELECT COUNT(*) FROM pg_policies WHERE policyname = 'Enable read for all users' AND tablename = 'authors'` returns exactly 1
- Fresh `supabase db init` + `supabase db push` on a new project succeeds without this migration
**Dependencies**: T-1.1 (RLS policies on authors are part of the new migration)
**Estimated Effort**: S (5 min)
**Security Relevance**: No

---

## Phase 2: Architecture

### T-2.1: Create DTO models layer (fromJson/toJson per entity)
**Description**: Create dedicated DTO classes in `lib/features/data/models/` for all 5 domain entities (Book, Genre, Label, Took, Chapter) plus a barrel file, each with `fromJson`, `toJson`, `toEntity`, and `fromEntity` methods. Note: Models extend their domain Entity to maintain type compatibility.
**Files**:
- **Create**: `lib/features/data/models/models.dart` (barrel)
- **Create**: `lib/features/data/models/book_model.dart`
- **Create**: `lib/features/data/models/genre_model.dart`
- **Create**: `lib/features/data/models/label_model.dart`
- **Create**: `lib/features/data/models/took_model.dart`
- **Create**: `lib/features/data/models/chapter_model.dart`
**Acceptance Criteria**:
- `BookModel` extends `BookEntity`, maps all fields including nested `authors`, `books_genres→genres`, `books_labels→labels`, `tooks→chapters`
- `GenreModel` extends `GenreEntity`, maps `id`, `created_at`, `name`, `description`
- `LabelModel` extends `LabelEntity`, maps `id`, `created_at`, `name`, `color`
- `TookModel` extends `TookEntity`, maps `id`, `created_at`, `cover`, `number`, `title`, `content→chapterCount`, `book_id`, nested `chapters`
- `ChapterModel` extends `ChapterEntity`, maps `id`, `created_at`, `number`, `title`, `content`, `took_id`
- All DTOs have `factory FromDto.fromJson(Map<String, dynamic>)` — no raw `Map` casting in callers
- All DTOs have `Map<String, dynamic> toJson()` — used for inserts/updates
- All DTOs have `toEntity()` — returns the domain Entity
- Round-trip: `Dto.fromEntity(entity).toEntity()` equals original entity
- Barrel exports all 5 models
**Dependencies**: None (code-only, imports domain entities only)
**Estimated Effort**: L (60 min)
**Security Relevance**: No (architectural improvement)

---

### T-2.2: Refactor all repository implementations to use DTOs
**Description**: Replace all inline `_mapTo*Entity` private methods in repository implementations with DTO-based mapping. Each repo impl uses `BookModel.fromJson(json).toEntity()` (or `TookModel`, `GenreModel`, etc.) instead of manual `Map<String, dynamic>` access. Remove all private mapping methods.
**Files**:
- `lib/features/data/repositories/auth_repository_impl.dart` — use fromJson for user mapping
- `lib/features/data/repositories/book_repository_impl.dart` — replace `_mapToBookEntity` with `BookModel.fromJson`
- `lib/features/data/repositories/chapter_repository_impl.dart` — replace `_mapToChapterEntity` with `ChapterModel.fromJson`
- `lib/features/data/repositories/genre_repository_impl.dart` — replace `_mapToGenreEntity` with `GenreModel.fromJson`
- `lib/features/data/repositories/label_repository_impl.dart` — replace inline mapping with `LabelModel.fromJson`
- `lib/features/data/repositories/profiles_repository_impl.dart` — replace `_mapToEntity` with DTO
- `lib/features/data/repositories/took_repository_impl.dart` — replace `_mapToTookEntity` with `TookModel.fromJson`
**Acceptance Criteria**:
- All 7 repo impls import from `package:noveles/features/data/models/models.dart`
- All `_mapTo*Entity` private methods removed (no raw JSON mapping in repo impls)
- Insert/update calls use DTO `toJson()`: e.g., `TookModel.fromEntity(took).toJson()` instead of `{'content': took.chapterCount}`
- AuthRepository uses `UserDto`/`UserModel` pattern consistently
- Existing test fixtures still compile (DTOs extend entities, so `BookModel` is a `BookEntity`)
- `flutter analyze` passes with no unused imports or type errors
**Dependencies**: T-2.1 (DTOs must exist)
**Estimated Effort**: L (60 min)
**Security Relevance**: No (architectural improvement)

---

### T-2.3: Remove direct Supabase import from AuthBloc via ListenAuthState use case
**Description**: Create `ListenAuthState` use case that wraps `supabase.auth.onAuthStateChange` behind a domain interface. Add `onAuthStateChange()` method to `AuthRepository`/`AuthRepositoryImpl`. Inject the use case into `AuthBloc` instead of importing `supabase_client.dart` directly.
**Files**:
- **Create**: `lib/features/domain/use_cases/listen_auth_state.dart`
- **Modify**: `lib/features/domain/repositories/auth_repository.dart` — add `Stream<AuthChangeEvent> onAuthStateChange()`
- **Modify**: `lib/features/data/repositories/auth_repository_impl.dart` — implement `onAuthStateChange()`
- **Modify**: `lib/features/presentation/bloc/auth/auth_bloc.dart` — remove Supabase imports, inject `ListenAuthState`
- **Modify**: `lib/core/di/injection.dart` — register `ListenAuthState`, pass to `AuthBloc`
**Acceptance Criteria**:
- `auth_bloc.dart` no longer imports `package:noveles/core/supabase/supabase_client.dart` or `package:supabase_flutter/supabase_flutter.dart`
- `ListenAuthState` use case calls `repository.onAuthStateChange()` (no direct Supabase access in use case)
- `_listenAuthChanges()` in AuthBloc uses `listenAuthState().listen(...)` instead of `supabase.auth.onAuthStateChange.listen(...)`
- `_onLogout` removes `supabase.auth.currentUser` check (rely on `logout()` use case which handles it)
- `flutter analyze` passes with no unused imports
- Login/logout flows work end-to-end
**Dependencies**: T-2.1 (DTOs for UserEntity mapping), T-2.2 (repos refactored)
**Estimated Effort**: M (45 min)
**Security Relevance**: No (architectural improvement — removes BLoC coupling to infrastructure)

---

### T-2.4: Remove direct Supabase import from LabelBloc via GetBookLabels use case
**Description**: Create `GetBookLabels` use case that encapsulates the `books_labels` query and routes through `BookRepository`. Add `getBookLabels()` method to `BookRepository`/`BookRepositoryImpl`. Inject the use case into `LabelBloc`.
**Files**:
- **Create**: `lib/features/domain/use_cases/get_book_labels.dart`
- **Modify**: `lib/features/domain/repositories/book_repository.dart` — add `Future<Map<int, Set<int>>> getBookLabels()`
- **Modify**: `lib/features/data/repositories/book_repository_impl.dart` — implement `getBookLabels()`
- **Modify**: `lib/features/presentation/bloc/label/label_bloc.dart` — remove Supabase import, inject `GetBookLabels`, use `getBookLabels()` instead of `_fetchBookLabels()`
- **Modify**: `lib/core/di/injection.dart` — register `GetBookLabels`, pass to `LabelBloc`
**Acceptance Criteria**:
- `label_bloc.dart` no longer imports `package:noveles/core/supabase/supabase_client.dart`
- `GetBookLabels` use case calls `repository.getBookLabels()` (no direct Supabase access)
- `_fetchBookLabels()` removed or replaced with one-liner: `getBookLabels()`
- Barrel file `use_cases.dart` exports the new use case
- Label management CRUD works end-to-end (assign/remove labels on books)
- `flutter analyze` passes
**Dependencies**: T-2.1 (DTOs), T-2.2 (repos refactored)
**Estimated Effort**: M (45 min)
**Security Relevance**: No (architectural improvement — removes BLoC coupling to infrastructure)

---

### T-2.5: Export LabelRepositoryImpl from repositories.dart barrel
**Description**: Add `LabelRepositoryImpl` export to the data repositories barrel file so `injection.dart` can import from the barrel instead of the direct file path (like all other repo impls).
**Files**:
- `lib/features/data/repositories/repositories.dart` — add `export 'package:noveles/features/data/repositories/label_repository_impl.dart';` after profiles line
**Acceptance Criteria**:
- `import 'package:noveles/features/data/repositories/repositories.dart'` provides `LabelRepositoryImpl`
- `injection.dart` can import `LabelRepositoryImpl` from the barrel (optional — direct path still works, but consistency is fixed)
- `flutter analyze` passes
- No duplicate exports
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: No

---

### T-2.6: Preserve original exception types — create and use RepositoryException
**Description**: Create an `RepositoryException` class that wraps original exceptions so callers can differentiate network errors from permission errors from validation errors. Update all 7 repository implementations to use `RepositoryException` instead of `Exception('Error al...: $e')`.
**Files**:
- **Create**: `lib/core/errors/repository_exception.dart`
- **Modify**: `lib/features/data/repositories/auth_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/book_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/chapter_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/genre_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/label_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/profiles_repository_impl.dart`
- **Modify**: `lib/features/data/repositories/took_repository_impl.dart`
**Acceptance Criteria**:
- `RepositoryException` has `message`, `originalException`, `repositoryName` fields
- `RepositoryException.toString()` includes prefix and original cause for debugging
- Each repo impl uses `on PostgrestException catch (e) { throw RepositoryException(...); }` pattern to preserve type
- Non-Postgrest exceptions also wrapped in `RepositoryException`
- Downstream callers can type-check: `catch (e) { if (e is RepositoryException) { /* type known */ } }`
- Original exception accessible via `(e as RepositoryException).originalException`
- `flutter analyze` passes
**Dependencies**: None (code-only, self-contained)
**Estimated Effort**: M (30 min)
**Security Relevance**: No (improves debugging, no security boundary change)

---

### T-2.7: Add logging to ChapterCache silent catch blocks
**Description**: Replace empty `catch (_) {}` blocks in `ChapterCache.read()` and `ChapterCache.save()` with `debugPrint()` calls that log the error for debugging cache failures.
**Files**:
- `lib/core/supabase/chapter_cache.dart`
**Acceptance Criteria**:
- `ChapterCache.read()` catch block logs: `debugPrint('ChapterCache.read error for $filename: $e')`
- `ChapterCache.save()` catch block logs: `debugPrint('ChapterCache.save error for $filename: $e')`
- Import `package:flutter/foundation.dart` added for `debugPrint`
- Silent failures still return `null` (behavior unchanged, just logged)
- In debug mode, corrupt cache files show error messages in console
**Dependencies**: None
**Estimated Effort**: S (10 min)
**Security Relevance**: No

---

## Phase 3: Bug Fixes

### T-3.1: GenreScreen filter fix — use `filteredBooks` instead of `widget.books`
**Description**: The `GenreScreen` computes `filteredBooks` in `initState` via `GetBooksByGenre` use case but the grid builder uses `widget.books` (unfiltered). Replace all references to `widget.books` in the build method with `filteredBooks`.
**Files**:
- `lib/features/presentation/screens/genre/genre_screen.dart`
**Acceptance Criteria**:
- Line 38: `widget.books.isEmpty` changed to `filteredBooks.isEmpty`
- Line 49: `childCount: widget.books.length` changed to `childCount: filteredBooks.length`
- Line 51: `final book = widget.books[index]` changed to `final book = filteredBooks[index]`
- Genre filtering works: navigating to "Fantasia" shows only fantasy books
- Switching genre shows different subset
- Empty genre shows "No books available for this genre" message
**Dependencies**: None (self-contained UI fix)
**Estimated Effort**: S (10 min)
**Security Relevance**: No

---

### T-3.2: GenreScreen — wrap in Scaffold + AppBar with back navigation
**Description**: `GenreScreen` uses a raw `CustomScrollView` without a `Scaffold` wrapper. Wrap the screen content in a `Scaffold` with a standard `AppBar` (with back arrow), replacing the current `SliverAppBar` approach.
**Files**:
- `lib/features/presentation/screens/genre/genre_screen.dart`
**Acceptance Criteria**:
- Root widget is `Scaffold` with `AppBar`
- AppBar title shows `'Género: ${widget.genre}'` (note: accent on the e)
- AppBar has automatic back navigation (leading back arrow)
- Grid content is scrollable within the scaffold body
- Empty state shows `'No hay libros disponibles para este género'`
- No more `SliverAppBar` inside the widget tree
**Dependencies**: T-3.1 (both modify genre_screen.dart — merge or sequence)
**Estimated Effort**: M (20 min)
**Security Relevance**: No

---

### T-3.3: TookEntity/content column mapping fix — add `chapter_count` DB column, fix DTO mapping
**Description**: The `tooks.content` column stores chapter count data (semantic mismatch). Add a `chapter_count` TEXT column to `tooks`, migrate existing data from `content` → `chapter_count`, and fix the DTO mapping to use `json['chapter_count']` (with fallback to `json['content']` for legacy rows). Update write operations to use `'chapter_count'` column.
**Files**:
- `supabase/migrations/20260522000000_audit_fixes.sql` — add `ALTER TABLE tooks ADD COLUMN IF NOT EXISTS chapter_count TEXT DEFAULT ''; UPDATE tooks SET chapter_count = content WHERE chapter_count = '' AND content != '';`
- `lib/features/data/models/took_model.dart` — `chapterCount: json['chapter_count'] ?? json['content'] ?? ''` and `'chapter_count': chapterCount`
- `lib/features/data/repositories/took_repository_impl.dart` — update insert/update to use `'chapter_count'`
- `lib/features/data/repositories/book_repository_impl.dart` — update nested took mapping to use `chapter_count` column (via DTO after T-2.2)
**Acceptance Criteria**:
- DB migration adds `chapter_count` column and copies existing data from `content`
- Entity field `chapterCount` reads from DB column `chapter_count` (with `content` fallback for legacy rows)
- Insert/update operations write to `chapter_count` column
- All `chapterCount` references in UI continue to work (field name unchanged)
- `flutter analyze` passes
- No data loss: `SELECT COUNT(*) FROM tooks WHERE chapter_count = '' AND content != ''` returns 0
**Dependencies**: Phase 1 migration (T-1.1 through T-1.9) must be applied first (DB schema change)
**Estimated Effort**: M (30 min)
**Security Relevance**: No

---

### T-3.4: BookScreen — remove `showInfoDialog()` dead code and associated IconButton
**Description**: `BookScreen` has a `showInfoDialog()` method (lines 50-75) that displays an empty dialog with a non-functional button. Remove the method entirely and remove the `infoIcon` parameter from `SliverAppBarBook`.
**Files**:
- `lib/features/presentation/screens/book/book_screen.dart` — remove `showInfoDialog()` method (lines 50-75), remove `infoIcon` parameter in `SliverAppBarBook` call
- `lib/features/presentation/screens/book/widgets/sliver_app_bar_book.dart` — remove required `infoIcon` parameter, remove `actions: [infoIcon]` block
**Acceptance Criteria**:
- `showInfoDialog()` method removed from `book_screen.dart`
- `infoIcon` parameter removed from `SliverAppBarBook` constructor
- No more `IconButton` with `Icons.info_outlined` in the book screen app bar
- Book screen renders with a clean app bar (no info icon)
- `flutter analyze` passes with no unused code warnings
**Dependencies**: None
**Estimated Effort**: S (10 min)
**Security Relevance**: No

---

### T-3.5: Remove explicit `id` on create for tooks and chapters
**Description**: `createTook` and `createChapter` send an explicit `'id'` field in INSERT calls, but both `tooks` and `chapters` use `SERIAL PRIMARY KEY`. Remove `'id': took.id` and `'id': chapter.id` from their respective insert maps. Keep `'id': genre.id` for genres (uses `INT PRIMARY KEY`, needed for seed data with specific IDs).
**Files**:
- `lib/features/data/repositories/took_repository_impl.dart` — remove line `'id': took.id,` from `createTook()` insert
- `lib/features/data/repositories/chapter_repository_impl.dart` — remove line `'id': chapter.id,` from `createChapter()` insert
**Acceptance Criteria**:
- `took_repository_impl.dart` insert no longer includes `'id'` field
- `chapter_repository_impl.dart` insert no longer includes `'id'` field
- `genre_repository_impl.dart` insert STILL includes `'id'` (genres use INT PK with seed data)
- Creating a took via scan screen gets auto-generated sequential ID
- Creating a chapter gets auto-generated sequential ID
- Existing data unaffected (already-assigned IDs remain)
- `flutter analyze` passes
**Dependencies**: T-2.2 (repos refactored with DTOs — insert/update logic changes)
**Estimated Effort**: S (10 min)
**Security Relevance**: No

---

### T-3.6: Strip AI-generated boilerplate comments from all BLoC and use case files
**Description**: Remove verbose Spanish AI-generated boilerplate comments that restate what the code clearly says. Keep only essential comments that explain non-obvious logic (e.g., `_manualLogoutInProgress` explanation, error handling intent).
**Files** (27 files):
- `lib/features/presentation/bloc/auth/auth_bloc.dart`
- `lib/features/presentation/bloc/auth/auth_event.dart`
- `lib/features/presentation/bloc/auth/auth_state.dart`
- `lib/features/presentation/bloc/book/book_bloc.dart`
- `lib/features/presentation/bloc/book/book_event.dart`
- `lib/features/presentation/bloc/book/book_state.dart`
- `lib/features/presentation/bloc/chapter/chapter_bloc.dart`
- `lib/features/presentation/bloc/chapter/chapter_event.dart`
- `lib/features/presentation/bloc/chapter/chapter_state.dart`
- `lib/features/presentation/bloc/genre/genre_bloc.dart`
- `lib/features/presentation/bloc/genre/genre_event.dart`
- `lib/features/presentation/bloc/genre/genre_state.dart`
- `lib/features/presentation/bloc/label/label_bloc.dart`
- `lib/features/presentation/bloc/label/label_event.dart`
- `lib/features/presentation/bloc/label/label_state.dart`
- `lib/features/presentation/bloc/profile/profile_bloc.dart`
- `lib/features/presentation/bloc/profile/profile_event.dart`
- `lib/features/presentation/bloc/profile/profile_state.dart`
- `lib/features/presentation/bloc/admin/admin_bloc.dart`
- `lib/features/presentation/bloc/admin/admin_event.dart`
- `lib/features/presentation/bloc/admin/admin_state.dart`
- `lib/features/presentation/bloc/scan/scan_bloc.dart`
- `lib/features/presentation/bloc/scan/scan_event.dart`
- `lib/features/presentation/bloc/scan/scan_state.dart`
- `lib/features/domain/repositories/repositories.dart` (line 1 `//`)
- `lib/features/data/repositories/repositories.dart` (line 1 `//`)
- `lib/features/domain/use_cases/use_cases.dart` (category comment headers)
**Acceptance Criteria**:
- No multi-line Spanish boilerplate comments in any BLoC file
- Essential logic comments preserved (e.g., `_manualLogoutInProgress` guard explanation)
- Barrel file comments simplified (category headers like `//  CREATE` are fine, remove the `//  AUTH` spacing noise)
- `flutter analyze` passes
- Files are significantly shorter
**Dependencies**: None
**Estimated Effort**: M (45 min)
**Security Relevance**: No

---

### T-3.7: Validate `coverUrl()` — return empty string if cover is empty
**Description**: `coverUrl('')` calls `supabase.storage.from('covers').getPublicUrl('')` which returns a broken URL. Add an early return for empty cover to prevent broken image loading.
**Files**:
- `lib/core/supabase/storage_helper.dart`
**Acceptance Criteria**:
- `coverUrl('')` returns `''` (empty string)
- `coverUrl('cr/soloLeveling.png')` returns valid public URL
- Book cards with no cover show the `CachedNetworkImage` error placeholder widget gracefully
- No attempt to load a broken URL for empty cover paths
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: No

---

## Phase 4: Testing ✅

- [x] T-4.1: AuthBloc unit tests — 9 tests (auth_bloc_test.dart)
- [x] T-4.2: ProfileBloc unit tests — 8 tests (profile_bloc_test.dart, use-case imports aliased)
- [x] T-4.3: LabelBloc unit tests — 8 tests (label_bloc_test.dart)
- [x] T-4.4: AdminBloc unit tests — 6 tests (admin_bloc_test.dart)
- [x] T-4.5: ChapterBloc unit tests — 4 tests (chapter_bloc_test.dart)
- [x] T-4.6: Repository tests — 22 tests across book (9), chapter (8), took (5)

### T-4.1: AuthBloc unit tests
**Description**: Create comprehensive bloc tests for AuthBloc covering login, register, logout, session check — including success, error, and edge case flows. Follow existing `scan_bloc_test.dart` pattern using Mocktail.
**Files**:
- **Create**: `test/bloc/auth_bloc_test.dart`
**Acceptance Criteria**:
- Mocks: `MockLogin`, `MockRegister`, `MockLogout`, `MockGetCurrentUser`, `MockListenAuthState`
- Tests: initial state is `AuthInitial`
- Tests: login success → `[AuthLoading, AuthAuthenticated]`
- Tests: login error → `[AuthLoading, AuthError]`
- Tests: register success → `[AuthLoading, AuthAuthenticated]`
- Tests: register error → `[AuthLoading, AuthError]`
- Tests: logout success → `[AuthLoading, AuthUnauthenticated]`
- Tests: logout error → `[AuthLoading, AuthError]`
- Tests: CheckAuthSession with user → `[AuthLoading, AuthAuthenticated]`
- Tests: CheckAuthSession no user → `[AuthLoading, AuthUnauthenticated]`
- Tests: CheckAuthSession throws → `[AuthLoading, AuthUnauthenticated]`
- Tests assert `AuthAuthenticated.user.email` and `AuthError.message` content
- All tests pass with `flutter test`
**Dependencies**: T-2.3 (AuthBloc dependency injection changes), T-2.6 (RepositoryException)
**Estimated Effort**: M (45 min)
**Security Relevance**: No

---

### T-4.2: ProfileBloc unit tests
**Description**: Create bloc tests for ProfileBloc covering load profile, update profile, change password — success and error paths.
**Files**:
- **Create**: `test/bloc/profile_bloc_test.dart`
**Acceptance Criteria**:
- Mocks: `MockGetProfile`, `MockUpdateProfile`, `MockUploadAvatar`, `MockChangePassword`
- Tests: initial state is `ProfileInitial`
- Tests: load profile success → `[ProfileLoading, ProfileLoaded]`
- Tests: load profile error → `[ProfileLoading, ProfileError]`
- Tests: update profile success → `[ProfileSaving, ProfileLoaded(updated)]`
- Tests: update profile error → `[ProfileSaving, ProfileError(user: current)]`
- Tests: change password success → `[ProfileSaving, ProfileLoaded(message)]`
- Tests: change password error → `[ProfileSaving, ProfileError]`
- Tests guard: calling update when state is `ProfileInitial` is handled appropriately
- All tests pass with `flutter test`
**Dependencies**: T-2.6 (exception types)
**Estimated Effort**: M (30 min)
**Security Relevance**: No

---

### T-4.3: LabelBloc unit tests
**Description**: Create bloc tests for LabelBloc covering load labels, create, delete, assign, remove — success and error paths.
**Files**:
- **Create**: `test/bloc/label_bloc_test.dart`
**Acceptance Criteria**:
- Mocks: `MockGetLabels`, `MockCreateLabel`, `MockDeleteLabel`, `MockAssignLabelToBook`, `MockRemoveLabelFromBook`, `MockGetBookLabels`
- Tests: initial state is `LabelInitial`
- Tests: load labels success → `[LabelLoading, LabelLoaded]`
- Tests: load labels error → `[LabelLoading, LabelError]`
- Tests: create label success → `[LabelLoaded(message)]`
- Tests: create label error → `[LabelError]`
- Tests: assign label success → `[LabelLoaded(message)]`
- Tests: remove label success → `[LabelLoaded(message)]`
- Tests: assign/remove error → `[LabelError]`
- All tests pass with `flutter test`
**Dependencies**: T-2.4 (LabelBloc dependency injection changes), T-2.6 (exception types)
**Estimated Effort**: M (30 min)
**Security Relevance**: No

---

### T-4.4: AdminBloc unit tests
**Description**: Create bloc tests for AdminBloc covering load admin books and toggle book visibility — success and error paths.
**Files**:
- **Create**: `test/bloc/admin_bloc_test.dart`
**Acceptance Criteria**:
- Mocks: `MockGetBooks`, `MockToggleBookVisibility`
- Tests: initial state is `AdminInitial`
- Tests: load admin books success → `[AdminLoading, AdminLoaded]`
- Tests: load admin books error → `[AdminLoading, AdminError]`
- Tests: toggle visibility success → `[AdminLoaded]`
- Tests: toggle visibility error → `[AdminError]`
- All tests pass with `flutter test`
**Dependencies**: T-2.6 (exception types)
**Estimated Effort**: S (20 min)
**Security Relevance**: No

---

### T-4.5: ChapterBloc unit tests
**Description**: Create bloc tests for ChapterBloc covering load chapter content — success and error paths.
**Files**:
- **Create**: `test/bloc/chapter_bloc_test.dart`
**Acceptance Criteria**:
- Mocks: `MockGetChapterContent`
- Tests: initial state is `ChapterInitial`
- Tests: load chapter content success → `[ChapterLoading, ChapterLoaded]`
- Tests: load chapter content error → `[ChapterLoading, ChapterError]`
- All tests pass with `flutter test`
**Dependencies**: T-2.6 (exception types)
**Estimated Effort**: S (15 min)
**Security Relevance**: No

---

### T-4.6: Repository implementation unit tests
**Description**: Create tests for repository implementations (BookRepositoryImpl, TookRepositoryImpl, ChapterRepositoryImpl) by mocking the global `supabase` client. Test basic CRUD operations — get, getById, create, update, delete.
**Files**:
- **Create**: `test/repositories/book_repository_test.dart`
- **Create**: `test/repositories/took_repository_test.dart`
- **Create**: `test/repositories/chapter_repository_test.dart`
**Acceptance Criteria**:
- Mock Supabase client using Mocktail (`MockSupabaseClient`, `MockSupabaseQuery`, `MockSupabaseFilter`)
- Tests use `setUp`/`tearDown` to replace/revert global `supabase` variable
- `BookRepositoryImpl`: test `getBooks()`, `getBookById()`, `createBook()`, `updateBook()`, `deleteBook()`
- `TookRepositoryImpl`: test `getTooks()`, `getTookById()`, `createTook()`, `updateTook()`, `deleteTook()`
- `ChapterRepositoryImpl`: test `getChapters()`, `getChapterById()`, `createChapter()`, `updateChapter()`, `deleteChapter()`
- Error paths: Supabase throws → repository wraps in `RepositoryException`
- All tests pass with `flutter test`
**Dependencies**: T-2.2 (DTO-based repos), T-2.6 (RepositoryException)
**Estimated Effort**: M (45 min)
**Security Relevance**: No

---

## Phase 5: UI/UX

### T-5.1: Move immersive mode from main.dart to ChapterScreen only
**Description**: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)` is currently called globally in `main.dart`, hiding system UI on all screens. Move this call to `ChapterScreen.initState()` and restore `edgeToEdge` in `dispose()` for proper screen-specific immersive mode.
**Files**:
- `lib/main.dart` — remove line 17: `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);`
- `lib/features/presentation/screens/chapter/chapter_screen.dart` — add `import 'package:flutter/services.dart'`, call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive)` in `initState()`, call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` in `dispose()`
**Acceptance Criteria**:
- `main.dart` no longer calls `SystemChrome.setEnabledSystemUIMode`
- `ChapterScreen.initState()` enables immersive mode
- `ChapterScreen.dispose()` restores edge-to-edge mode (preventing stuck immersive mode on other screens)
- All other screens show system UI (status bar, navigation bar) normally
- Chapter reading uses full-screen immersive experience
**Dependencies**: None
**Estimated Effort**: S (15 min)
**Security Relevance**: No

---

### T-5.2: Remove unused Cupertino Icons dependency
**Description**: `cupertino_icons: ^1.0.8` is listed in `pubspec.yaml` but no Cupertino icons are used (all UI uses Material icons). Remove the unused dependency.
**Files**:
- `pubspec.yaml` — remove line 14: `cupertino_icons: ^1.0.8`
**Acceptance Criteria**:
- `cupertino_icons` removed from `dependencies` section
- `flutter pub get` succeeds
- App builds without warnings about missing imports
- Search for `CupertinoIcons.` across the codebase returns no results
**Dependencies**: None
**Estimated Effort**: S (5 min)
**Security Relevance**: No

---

## Complete Dependency Graph

```
T-1.1 ──► T-1.2
  │
  ├──► T-1.3 (independent)
  ├──► T-1.4 (independent)
  ├──► T-1.5 (independent)
  ├──► T-1.6 (independent)
  ├──► T-1.7 (independent, same file)
  ├──► T-1.8 (independent, same file)
  └──► T-1.9 (independent, same file)
  
T-2.1 ──► T-2.2 ──┬──► T-2.3 ──► T-4.1
                  ├──► T-2.4 ──► T-4.3
                  └──► T-2.5 (independent, no dep)
                  
T-2.6 (independent) ──► T-4.1, T-4.2, T-4.3, T-4.4, T-4.5, T-4.6
T-2.7 (independent)

T-3.1 ──► T-3.2 (same file)
T-3.3 ──► Phase 1 DB (T-1.1–T-1.9 must be applied)
T-3.4 (independent)
T-3.5 ──► T-2.2 (repos refactored)
T-3.6 (independent)
T-3.7 (independent)

T-5.1 (independent)
T-5.2 (independent)
```

## Batch C Completion (T-2.x + T-3.x non-DB)
- [x] T-2.1: DTO models layer created (BookModel, GenreModel, LabelModel, TookModel, ChapterModel, UserModel, barrel)
- [x] T-2.2: All 7 repo impls refactored to use DTOs (fromJson/toJson), removed _mapTo*Entity methods
- [x] T-2.3: AuthBloc Supabase removed — ListenAuthState use case injected, onAuthStateChange() added to AuthRepository
- [x] T-2.4: LabelBloc Supabase removed — GetBookLabels use case injected, getBookLabels() added to BookRepository
- [x] T-2.5: LabelRepositoryImpl exported from repositories.dart barrel
- [x] T-2.6: RepositoryException created and used in all 7 repo impls
- [x] T-2.7: ChapterCache debugPrint logging added
- [x] T-3.1: GenreScreen filter fix — uses filteredBooks instead of widget.books
- [x] T-3.2: GenreScreen wrapped in Scaffold + AppBar with back navigation
- [x] T-3.4: BookScreen dead code removed (showInfoDialog, infoIcon from SliverAppBarBook)
- [x] T-3.5: Explicit id removed from createTook/createChapter inserts (genres kept)
- [x] T-3.6: All BLoC/event/state files stripped of AI boilerplate comments
- [x] T-3.7: coverUrl() returns empty string for empty cover

## Overall Quality Requirements
- [x] All tasks pass `flutter analyze` (7 info-level only — const style + dev_dependency notices)
- [x] All 100 tests pass with `flutter test` (45 BLoC + 22 repo + 2 entity + 5 use_case + 25 scan + 1 smoke)
- [ ] Consoles show no broken URL errors for empty cover paths
- [x] Immersive mode only on chapter screen (not globally) — Batch B
- [x] No Cupertino icons dependency — Batch B
- [x] `.env` removed from git tracking — Batch A
- [ ] All migration SQL can apply cleanly on staging DB — Batch A
