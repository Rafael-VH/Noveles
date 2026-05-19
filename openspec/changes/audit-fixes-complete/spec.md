# Spec: Audit Fixes — Complete

> **Type**: Delta specs — modifying existing capabilities
> **Change**: `audit-fixes-complete`
> **Persistent artifacts**: `engram` + file-based (`openspec/changes/audit-fixes-complete/`)
>
> These specs define what must change, what it does now, what it should do after, exact SQL/logic, files affected, and validation criteria — for all 5 phases (30+ fixes).

---

## Spec: Phase 1 — Security & Database

This phase hardens the Supabase database by enabling RLS on unprotected tables, restoring admin write policies, hardening auth config, adding missing indexes, removing hardcoded UUIDs, and consolidating redundant migrations.

---

### Sub-task 1.1: Enable RLS on genres, books_genres, authors

**Requirement**: These 3 tables have RLS disabled, meaning any authenticated (or even anonymous) user can read/write all rows. RLS must be enabled and at minimum a `SELECT` policy for authenticated users must exist.

**Current behavior**:
- `genres` — RLS is NOT enabled (no `ALTER TABLE genres ENABLE ROW LEVEL SECURITY;` in any migration).
- `books_genres` — RLS is NOT enabled.
- `authors` — RLS was enabled in `20260515000000_authors_and_constraints.sql` but no SELECT policy was created initially. A SELECT policy `"Enable read for all users"` was added later in `20260518010000_admin_ownership.sql` and again in `20260518020000_fix_authors_rls.sql` (duplicate).

**Expected behavior**:
- RLS enabled on `genres`, `books_genres`, `authors`.
- All 3 tables have a `SELECT` policy allowing authenticated users to read (same pattern as `books`, `tooks`, `chapters`).
- Write policies are handled by the admin write policies sub-task (1.2).

**Files affected**:
- `supabase/migrations/20260522000000_audit_fixes.sql` (new migration — consolidated audit fix migration)

**SQL logic**:
```sql
-- Enable RLS on tables missing it
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE books_genres ENABLE ROW LEVEL SECURITY;

-- Note: authors already has RLS enabled (from 20260515000000)

-- Add SELECT policies (public read for authenticated)
DROP POLICY IF EXISTS "Enable read for all users" ON genres;
CREATE POLICY "Enable read for all users" ON genres
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable read for all users" ON books_genres;
CREATE POLICY "Enable read for all users" ON books_genres
  FOR SELECT USING (true);

-- Drop duplicate policies on authors (created by both 20260518010000 and 20260518020000)
DROP POLICY IF EXISTS "Enable read for all users" ON authors;
CREATE POLICY "Enable read for all users" ON authors
  FOR SELECT USING (true);
```

**Validation**:
- Run `SELECT tablename, rowsecurity FROM pg_tables WHERE tablename IN ('genres', 'books_genres', 'authors');` — all must return `true`.
- As an unauthenticated user, run `SELECT * FROM genres LIMIT 1;` — should return empty/error.
- As an authenticated user, run `SELECT * FROM genres LIMIT 1;` — should return rows.

---

### Sub-task 1.2: Admin write policies — restore for `admin` role across all content tables

**Requirement**: The `admin` role was renamed to `scan` in `20260520000000_rename_admin_to_scan.sql`, but a new `admin` role was re-added in `20260520010000_add_admin_role.sql`. The write policies created by the DO loop in the rename migration only cover `scan` role. There are no write policies for `admin` role on `genres`, `books_genres`, `authors`, `books`, `tooks`, `chapters`.

**Current behavior**:
- Write policies for `scan` role exist on all 6 tables (created by DO loop in `20260520000000`).
- Write policies for `admin` role exist on `books`, `genres`, `tooks`, `chapters`, `books_genres` (from `20260515161849_profiles_and_auth.sql`) but these check for `role = 'admin'`, which means they evaluate based on the old `admin` role before the rename.
- `authors` has no admin write policies at all.
- Additionally, `20260521000000_fix_scan_rls_own_books.sql` restricted scan policies to `created_by = auth.uid()` for `books`, but admin should bypass this restriction.

**Expected behavior**:
- Both `admin` and `scan` roles can INSERT/UPDATE/DELETE on all 6 content tables (`books`, `genres`, `tooks`, `chapters`, `books_genres`, `authors`).
- Admin policies bypass the `created_by` ownership check (admin can write to any row).
- Existing scan policies remain unchanged.

**Files affected**:
- `supabase/migrations/20260522000000_audit_fixes.sql`

**SQL logic**:
```sql
-- Add admin write policies for all content tables using is_admin() helper
-- (is_admin() was created in 20260520010000_add_admin_role.sql)

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors'])
  LOOP
    -- INSERT
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable insert for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable insert for admin only" ON %I FOR INSERT WITH CHECK (public.is_admin())',
      tbl
    );
    -- UPDATE
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable update for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable update for admin only" ON %I FOR UPDATE USING (public.is_admin())',
      tbl
    );
    -- DELETE
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable delete for admin only" ON %I',
      tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable delete for admin only" ON %I FOR DELETE USING (public.is_admin())',
      tbl
    );
  END LOOP;
END;
$$;

-- Books SELECT: admin can see all books (including invisible ones)
DROP POLICY IF EXISTS "Admin can read all books" ON books;
CREATE POLICY "Admin can read all books"
  ON books FOR SELECT
  USING (public.is_admin());

-- Books SELECT: scan can see own books (existing — ensure not duplicated)
-- (already exists from 20260521000000)
```

**Validation**:
- As a user with `admin` role, run INSERT/UPDATE/DELETE on each table — should succeed.
- As a user with `scan` role, verify existing policies still work (INSERT with `created_by = auth.uid()`, UPDATE/DELETE on own books).
- As a regular `user`, verify write operations are rejected.

---

### Sub-task 1.3: Remove .env from git tracking + scrub history

**Requirement**: The `.env` file contains `SUPABASE_URL` and `SUPABASE_ANON_KEY`. It is listed in `.gitignore` but may have been tracked in earlier commits. Must ensure it is fully removed from git history.

**Current behavior**:
- `.env` is in `.gitignore` (correct).
- But if `.env` was committed before being added to `.gitignore`, it remains in git history.

**Expected behavior**:
- `.env` is not tracked in git (`.gitignore` entry is sufficient going forward).
- If present in history, scrub using `git filter-repo` on a clone.
- The `.env` asset declaration in `pubspec.yaml` (line 52: `- .env`) means the file IS needed at build time — so the file must remain on disk, just not in git.

**Files affected**:
- `.gitignore` (verify `.env` entry exists — it does: line 35)
- `.env` (file stays, just needs git rm --cached)

**Git commands**:
```bash
# If .env is currently tracked:
git rm --cached .env
echo ".env" >> .gitignore

# Commit the removal:
git add .gitignore
git commit -m "chore: remove .env from tracking"
```

**Scrub from history (if needed)**:
```bash
# Check if .env was ever committed:
git log --oneline -- .env

# If present, use filter-repo (run on a fresh clone):
# git clone --mirror <repo-url> repo-temp
# cd repo-temp
# pip install git-filter-repo
# git filter-repo --path .env --invert-paths
```

**Validation**:
- `git ls-files --cached .env` returns empty.
- `.env` entry exists in `.gitignore`.
- `git log --oneline -- .env` shows no commits touching the file.

---

### Sub-task 1.4: Password policy — minimum 8 chars + lower_upper_letters_digits

**Requirement**: Current minimum password length is 6 with no complexity requirement. Increase to 8 with mixed-case + digits.

**Current behavior** (from `config.toml`):
```toml
minimum_password_length = 6      # line 175
password_requirements = ""       # line 178
```

**Expected behavior**:
```toml
minimum_password_length = 8
password_requirements = "lower_upper_letters_digits"
```

**Files affected**:
- `supabase/config.toml` (lines 175, 178)

**Validation**:
- After deploy, attempt to register with `Ab1` (too short + no mixed case) — rejected.
- Attempt to register with `abcdefgh` (8 chars but no uppercase/digit) — rejected.
- Attempt to register with `Abcdefgh1` (meets all) — accepted.

---

### Sub-task 1.5: Enable email confirmations

**Requirement**: Email confirmation is currently disabled, meaning users can sign up without verifying their email. Enable it for production security.

**Current behavior** (from `config.toml`, line 219):
```toml
enable_confirmations = false
```

**Expected behavior**:
```toml
enable_confirmations = true
```

**Files affected**:
- `supabase/config.toml` (line 219)

**Validation**:
- After deploy, register a new user — they receive a confirmation email.
- Before confirming, they cannot sign in.
- After clicking confirmation link, they can sign in.

---

### Sub-task 1.6: Rate limit change — max_frequency to 60s

**Requirement**: Email `max_frequency` is currently 1 second — way too aggressive. This could be abused for email bombing. Increase to 60 seconds.

**Current behavior** (from `config.toml`, line 223):
```toml
max_frequency = "1s"
```

**Expected behavior**:
```toml
max_frequency = "60s"
```

**Files affected**:
- `supabase/config.toml` (line 223)

**Validation**:
- After deploy, request password reset or signup confirmation more than once per 60 seconds — second request is rejected/rate-limited.

---

### Sub-task 1.7: Add missing FK indexes

**Requirement**: Foreign key columns lack indexes, causing slow joins at scale. The `books_genres` junction table already has a composite PK index. Missing indexes:
- `tooks.book_id`
- `chapters.took_id`
- `books.author_id`
- `books_labels.book_id`
- `books_labels.label_id`

**Current behavior**: No explicit indexes on these FK columns (only PK indexes and the composite PK on junction tables).

**Expected behavior**: B-tree indexes exist on all FK columns.

**Files affected**:
- `supabase/migrations/20260522000000_audit_fixes.sql`

**SQL logic**:
```sql
CREATE INDEX IF NOT EXISTS idx_tooks_book_id ON tooks(book_id);
CREATE INDEX IF NOT EXISTS idx_chapters_took_id ON chapters(took_id);
CREATE INDEX IF NOT EXISTS idx_books_author_id ON books(author_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_book_id ON books_labels(book_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_label_id ON books_labels(label_id);
-- Note: books_genres(book_id, genre_id) already covered by PK
```

**Validation**:
- Run `SELECT indexname, tablename FROM pg_indexes WHERE tablename IN ('tooks', 'chapters', 'books', 'books_labels') AND indexname LIKE 'idx_%';` — all 5 indexes must appear.

---

### Sub-task 1.8: Replace hardcoded UUIDs with subquery

**Requirement**: Migration `20260518010000_admin_ownership.sql` contains hardcoded UUIDs `c63c361c-6bc7-4b66-9aac-157e8999271c` and `4723bbc3-1ea8-4747-a3a0-604dd94783a5` used in UPDATE statements. These are fragile — they reference specific user IDs that won't exist on other environments or after DB resets.

**Current behavior**:
```sql
UPDATE books SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE tooks SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
UPDATE chapters SET created_by = '4723bbc3-1ea8-4747-a3a0-604dd94783a5' WHERE created_by IS NOT NULL;
```

**Expected behavior**: Replace with a subquery that looks up the admin user by email (from seed.sql) or the first `scan` role user. Wrap in a DO block with fallback.

**Files affected**:
- `supabase/migrations/20260522000000_audit_fixes.sql` (new migration, not modifying the old one — but the old migration is already applied)

**SQL logic** (in a new migration to fix existing data):
```sql
-- Fix: replace hardcoded UUIDs with dynamic lookup
-- Looks up the admin user by email (matching seed.sql) or the first scan role user
DO $$
DECLARE
  admin_id UUID;
BEGIN
  -- Try to find by email first (matches seed.sql admin@noveles.com)
  SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@noveles.com';
  
  -- Fallback: try the first user with scan role
  IF admin_id IS NULL THEN
    SELECT p.id INTO admin_id FROM public.profiles p
      JOIN auth.users u ON u.id = p.id
      WHERE p.role = 'scan'
      ORDER BY p.created_at ASC
      LIMIT 1;
  END IF;
  
  -- Fallback: first auth user
  IF admin_id IS NULL THEN
    SELECT id INTO admin_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
  END IF;
  
  -- Apply the update
  IF admin_id IS NOT NULL THEN
    UPDATE books SET created_by = admin_id WHERE created_by IS NULL;
    UPDATE tooks SET created_by = admin_id WHERE created_by IS NULL;
    UPDATE chapters SET created_by = admin_id WHERE created_by IS NULL;
    RAISE NOTICE 'Updated created_by to %', admin_id;
  ELSE
    RAISE WARNING 'No admin user found — created_by left as NULL on orphaned rows';
  END IF;
END;
$$;
```

**Validation**:
- Run a query to verify no `created_by` values are NULL on rows that have data:
  `SELECT COUNT(*) FROM books WHERE created_by IS NULL;` — should return 0.
- All `created_by` values should match a valid UUID from `auth.users`.

---

### Sub-task 1.9: Consolidate redundant migrations 20260518010000 + 20260518020000

**Requirement**: Migrations `20260518010000_admin_ownership.sql` and `20260518020000_fix_authors_rls.sql` overlap significantly. Migration `20260518020000` was created as a "fix" but actually duplicates work from `20260518010000` (same `UPDATE books/tooks/chapters SET created_by = ...` statements and same `"Enable read for all users"` policy on `authors`).

**Current behavior**: Two separate migration files with overlapping SQL:
- `20260518010000`: Adds `created_by` columns, assigns UUID `c63c361c-...`, drops Authenticated policies, adds `authors` SELECT policy, then corrects UUID to `4723bbc3-...`.
- `20260518020000`: Adds same `authors` SELECT policy (duplicate) and same UUID update (duplicate).

**Expected behavior**:
- **Going forward**: Remove `20260518020000_fix_authors_rls.sql` entirely. All its logic is already covered by `20260518010000` plus the new consolidated migration.
- **For already-applied databases**: No migration changes needed (both already ran).
- The UUID correction in `20260518020000` (from `c63c361c-...` to `4723bbc3-...`) is already handled by the dynamic subquery in sub-task 1.8.

**Files affected**:
- Delete: `supabase/migrations/20260518020000_fix_authors_rls.sql`
- The contents can be removed since both migrations have already been applied on production.
- **DO NOT** delete a migration that's already been applied on remote — just remove the file from the repo so new setups don't run it.

**Validation**:
- After deletion, run `supabase migration list` — the deleted file should not appear.
- Run `SELECT COUNT(*) FROM pg_policies WHERE policyname = 'Enable read for all users' AND tablename = 'authors';` — should be exactly 1 (no duplicate).
- New `supabase db init` + `supabase db push` on a fresh project should succeed without the deleted migration.

---

## Spec: Phase 2 — Architecture

This phase adds a DTO layer between Supabase JSON responses and domain entities, removes direct Supabase coupling from BLoCs, fixes barrel exports, preserves exception types, and adds logging.

---

### Sub-task 2.1: DTO models layer — entity list, fromJson/toJson structure

**Requirement**: Currently, each repository impl manually maps Supabase JSON responses to domain entities using raw `Map<String, dynamic>` access (e.g., `json['name'] ?? ''`). This is scattered across 7 repository files. A dedicated DTO layer should encapsulate all JSON mapping in one place per entity.

**Current behavior**: Mapping logic lives inline in each repository impl's private `_mapTo*Entity()` methods. Chapter entity mapping exists in both `book_repository_impl.dart` and `took_repository_impl.dart` (duplicated).

**Expected behavior**: New DTO classes in `lib/features/data/models/` directory. Each DTO has:
- `factory FromDto.fromJson(Map<String, dynamic> json)` — for Supabase responses
- `Map<String, dynamic> toJson()` — for Supabase inserts/updates
- `FromDto toEntity()` — converts to domain entity
- Named constructor from entity — for converting entity → DTO

**DTO entity list** (one per domain entity):

| DTO File | Domain Entity | Fields |
|----------|--------------|--------|
| `book_dto.dart` | `BookEntity` | id, created_at, cover, name, short, alternative, description, author_id, country, state, type, release, took_count, chapter_count, source, link, is_favorite, is_visible, author_data (nested), genres (from books_genres → genres), labels (from books_labels → labels), tooks (nested) |
| `genre_dto.dart` | `GenreEntity` | id, created_at, name, description |
| `label_dto.dart` | `LabelEntity` | id, created_at, name, color |
| `took_dto.dart` | `TookEntity` | id, created_at, cover, number, title, content (→ chapterCount in entity), book_id, chapters (nested list) |
| `chapter_dto.dart` | `ChapterEntity` | id, created_at, number, title, content, took_id |
| `user_dto.dart` | `UserEntity` | id, email, role, display_name, bio, avatar_url |

**Files to create**:
- `lib/features/data/models/models.dart` (barrel)
- `lib/features/data/models/book_dto.dart`
- `lib/features/data/models/genre_dto.dart`
- `lib/features/data/models/label_dto.dart`
- `lib/features/data/models/took_dto.dart`
- `lib/features/data/models/chapter_dto.dart`
- `lib/features/data/models/user_dto.dart`

**Structure template** (e.g. for `genre_dto.dart`):
```dart
import 'package:noveles/features/domain/entities/entities.dart';

class GenreDto {
  final int id;
  final DateTime createdAt;
  final String name;
  final String description;

  const GenreDto({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  factory GenreDto.fromJson(Map<String, dynamic> json) {
    return GenreDto(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'name': name,
    'description': description,
  };

  GenreEntity toEntity() => GenreEntity(
    id: id,
    createdAt: createdAt,
    name: name,
    description: description,
  );

  factory GenreDto.fromEntity(GenreEntity entity) => GenreDto(
    id: entity.id,
    createdAt: entity.createdAt,
    name: entity.name,
    description: entity.description,
  );
}
```

**Validation**:
- Create an instance with `GenreDto.fromJson({'id': 1, 'created_at': '2024-01-01T00:00:00Z', 'name': 'Test', 'description': 'Desc'})` — works without casting exceptions.
- Convert to entity: `dto.toEntity()` returns correct `GenreEntity`.
- Round-trip: `GenreDto.fromEntity(entity).toEntity()` equals original entity.

---

### Sub-task 2.2: Repository refactors — how to inject DTO mapping

**Requirement**: All 7 repository implementations must migrate from inline JSON mapping to DTO-based mapping. Private `_mapTo*Entity` methods should be replaced or supplemented with DTO calls.

**Current behavior**: Each repository impl has a private `_mapTo*Entity` method with raw `Map<String, dynamic>` access. For example, `took_repository_impl.dart` has:
```dart
TookEntity _mapToTookEntity(Map<String, dynamic> json) {
  return TookEntity(
    id: json['id'],
    chapterCount: json['content'] ?? '',  // BUG: maps 'content' to chapterCount
    ...
  );
}
```

**Expected behavior**: Each repository impl uses DTOs:
```dart
// In took_repository_impl.dart:
TookDto _mapToDto(Map<String, dynamic> json) => TookDto.fromJson(json);

// Then either:
TookEntity _mapToEntity(Map<String, dynamic> json) =>
    TookDto.fromJson(json).toEntity();

// Or inline:
final entity = TookDto.fromJson(json).toEntity();
```

The DTO `toJson()` method is used for insert/update calls:
```dart
// Before:
await supabase.from('tooks').insert({
  'id': took.id,
  'content': took.chapterCount,  // BUG
});

// After:
await supabase.from('tooks').insert(TookDto.fromEntity(took).toJson());
```

**Files affected**:
- `lib/features/data/repositories/auth_repository_impl.dart`
- `lib/features/data/repositories/book_repository_impl.dart`
- `lib/features/data/repositories/chapter_repository_impl.dart`
- `lib/features/data/repositories/genre_repository_impl.dart`
- `lib/features/data/repositories/label_repository_impl.dart`
- `lib/features/data/repositories/profiles_repository_impl.dart`
- `lib/features/data/repositories/took_repository_impl.dart`

**Specific DTO mapping changes per file**:

| File | Private method | New approach |
|------|---------------|-------------|
| `auth_repository_impl.dart` | No explicit mapper (inline mapping) | Use `UserDto.fromJson()` |
| `book_repository_impl.dart` | `_mapToBookEntity()` | `BookDto.fromJson(json).toEntity()` |
| `chapter_repository_impl.dart` | `_mapToChapterEntity()` | `ChapterDto.fromJson(json).toEntity()` |
| `genre_repository_impl.dart` | `_mapToGenreEntity()` | `GenreDto.fromJson(json).toEntity()` |
| `label_repository_impl.dart` | No explicit mapper (inline mapping) | `LabelDto.fromJson(json).toEntity()` |
| `profiles_repository_impl.dart` | `_mapToEntity()` | `UserDto.fromJson(data).toEntity()` |
| `took_repository_impl.dart` | `_mapToTookEntity()` | `TookDto.fromJson(json).toEntity()` |

**Validation**:
- Run existing tests — they exercise repository behavior (scan_bloc_test, book_bloc_test, genre_bloc_test indirectly).
- Manual smoke test: Load book list, genre list, took list, labels — all map correctly.

---

### Sub-task 2.3: AuthBloc Supabase removal — inject via use case

**Requirement**: `auth_bloc.dart` imports `supabase_client.dart` directly (line 3) and calls `supabase.auth.onAuthStateChange` and `supabase.auth.currentUser`. The BLoC should not know about Supabase — these should be injected via a use case or injected stream.

**Current behavior**:
```dart
// auth_bloc.dart line 3:
import 'package:noveles/core/supabase/supabase_client.dart';
// line 33:
_authSubscription = supabase.auth.onAuthStateChange.listen((data) { ... });
// line 101:
if (supabase.auth.currentUser != null) { ... }
```

**Expected behavior**: Create a `ListenAuthChanges` use case that returns a `Stream<AuthEvent>` (or a simple callback stream), injected into `AuthBloc`. The BLoC only knows about use cases, never about Supabase.

**New file**: `lib/features/domain/use_cases/listen_auth_changes.dart`
```dart
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/presentation/bloc/auth/auth_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class ListenAuthChanges {
  Stream<AuthEvent> call() {
    return supabase.auth.onAuthStateChange.map((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        return LogoutRequested();
      }
      // session restored
      return CheckAuthSession();
    });
  }
}
```

**Changes to `auth_bloc.dart`**:
- Remove `import 'package:noveles/core/supabase/supabase_client.dart';`
- Remove `import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;`
- Add `final ListenAuthChanges listenAuthChanges;` parameter
- Replace `_listenAuthChanges()`:
```dart
void _listenAuthChanges() {
  _authSubscription = listenAuthChanges().listen((event) {
    if (event is LogoutRequested && !_manualLogoutInProgress) {
      add(event);
    }
  });
}
```

**Changes to `injection.dart`**:
- Register `getIt.registerLazySingleton(() => ListenAuthChanges(getIt()));`
  Wait — `ListenAuthChanges` doesn't need constructor injection since it uses the global `supabase` instance directly. Register simply as:
  `getIt.registerLazySingleton(() => ListenAuthChanges());`
- Pass to `AuthBloc`:
```dart
getIt.registerFactory(
  () => AuthBloc(
    login: getIt(),
    register: getIt(),
    logout: getIt(),
    getCurrentUser: getIt(),
    listenAuthChanges: getIt(),
  ),
);
```

**Remove `_onLogout` Supabase reference**:
- Line 101 in auth_bloc.dart: `if (supabase.auth.currentUser != null)` — replace this check. The `logout()` use case already handles this internally. Simply always call `await logout();` — if no session, it's a no-op.

**Validation**:
- `AuthBloc` no longer imports `supabase_client.dart` or `supabase_flutter`.
- Run `flutter analyze` — no unused imports.
- Verify login flow: login → authenticated state → close app → reopen → session restored.
- Verify logout flow: logout → unauthenticated → cannot access protected routes.

---

### Sub-task 2.4: LabelBloc Supabase removal — inject via use case

**Requirement**: `label_bloc.dart` imports `supabase_client.dart` directly (line 2) and calls `supabase.from('books_labels').select()` in `_fetchBookLabels()`.

**Current behavior**:
```dart
// label_bloc.dart line 2:
import 'package:noveles/core/supabase/supabase_client.dart';
// line 29:
final rows = await supabase.from('books_labels').select();
```

**Expected behavior**: Create a `GetBookLabels` use case that encapsulates the `books_labels` query. The BLoC only knows about use cases.

**New file**: `lib/features/domain/use_cases/get_book_labels.dart`
```dart
import 'package:noveles/core/supabase/supabase_client.dart';

class GetBookLabels {
  Future<Map<int, Set<int>>> call() async {
    final rows = await supabase.from('books_labels').select();
    final map = <int, Set<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
    }
    return map;
  }
}
```

**Changes to `label_bloc.dart`**:
- Remove `import 'package:noveles/core/supabase/supabase_client.dart';`
- Add `final GetBookLabels getBookLabels;` parameter
- Replace `_fetchBookLabels()` body with `return await getBookLabels();`

**Changes to `injection.dart`**:
- Register `getIt.registerLazySingleton(() => GetBookLabels());`
- Pass to `LabelBloc`:
```dart
getIt.registerFactory(
  () => LabelBloc(
    getLabels: getIt(),
    createLabel: getIt(),
    deleteLabel: getIt(),
    assignLabel: getIt(),
    removeLabel: getIt(),
    getBookLabels: getIt(),
  ),
);
```

**Validation**:
- `LabelBloc` no longer imports `supabase_client.dart`.
- Run `flutter analyze` — no unused imports.
- Verify label management screen: assign label to book → label appears, reload → persists.

---

### Sub-task 2.5: LabelRepositoryImpl export — which barrel file

**Requirement**: `LabelRepositoryImpl` is NOT exported from `lib/features/data/repositories/repositories.dart`, causing `injection.dart` to import it directly by exact path. All other repository impls ARE exported from the barrel.

**Current behavior**:
- `lib/features/data/repositories/repositories.dart` exports: `auth_repository_impl`, `book_repository_impl`, `chapter_repository_impl`, `genre_repository_impl`, `profiles_repository_impl`, `took_repository_impl` — but NOT `label_repository_impl`.

**Expected behavior**: Add the export to the barrel file.

**Files affected**:
- `lib/features/data/repositories/repositories.dart`

**Change** (add after `profiles_repository_impl` line):
```dart
export 'package:noveles/features/data/repositories/label_repository_impl.dart';
```

**Validation**:
- After change, `import 'package:noveles/features/data/repositories/repositories.dart'` provides `LabelRepositoryImpl`.
- `injection.dart` can import from the barrel instead of the direct path.

---

### Sub-task 2.6: Exception preservation pattern

**Requirement**: All repository implementations catch exceptions and re-throw as `Exception('Error al [X]: $e')`, which loses the original exception type. For example, a `PostgrestException` becomes a plain `Exception`. Downstream callers can't differentiate between a network error, a permission error, or a validation error.

**Current behavior** (same pattern in all 7 repo impls):
```dart
try {
  // ... supabase call
} catch (e) {
  throw Exception('Error al obtener libros: $e');
}
```

**Expected behavior**: Wrap the original exception in a typed application exception or preserve the original exception type. Create an `AppException` class that preserves the original exception.

**New file**: `lib/core/exceptions/app_exception.dart`
```dart
class AppException implements Exception {
  final String message;
  final Object? originalException;
  final String? code;

  const AppException(this.message, {this.originalException, this.code});

  @override
  String toString() => message;
}

class RepositoryException extends AppException {
  const RepositoryException(super.message, {super.originalException, super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.originalException, super.code});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.originalException, super.code});
}
```

**Update pattern in all 7 repo impls** (example for `took_repository_impl.dart`):
```dart
try {
  // ... supabase call
} on PostgrestException catch (e) {
  throw RepositoryException('Error al obtener tomos: $e',
      originalException: e, code: e.code);
} catch (e) {
  throw RepositoryException('Error al obtener tomos: $e',
      originalException: e);
}
```

**Files affected**:
- New: `lib/core/exceptions/app_exception.dart`
- New: `lib/core/exceptions/exceptions.dart` (barrel)
- Modified: All 7 repository impl files + `profiles_repository_impl.dart`

**Validation**:
- Catch block in a BLoC: `catch (e) { if (e is RepositoryException) { /* handle repo error */ } }` — type check works.
- Original exception accessible via `(e as AppException).originalException`.

---

### Sub-task 2.7: ChapterCache logging — what to log

**Requirement**: `ChapterCache` catch blocks swallow all exceptions silently (`catch (_) { return null; }` and `catch (_) {}`). This makes debugging cache failures impossible.

**Current behavior**:
```dart
// chapter_cache.dart lines 25-27:
} catch (_) {
  return null;
}

// lines 34-35:
} catch (_) {}
```

**Expected behavior**: Log exceptions using `print()` or `debugPrint()`. In production, this could be upgraded to a proper logger, but for now `debugPrint()` is sufficient and won't appear in release builds.

**Changes** (in `lib/core/supabase/chapter_cache.dart`):
```dart
// Replace line 25-27:
} catch (e) {
  debugPrint('ChapterCache.read error for $filename: $e');
  return null;
}

// Replace line 34-35:
} catch (e) {
  debugPrint('ChapterCache.save error for $filename: $e');
}
```

**Add import**: `import 'package:flutter/foundation.dart';` (for `debugPrint`)

**Validation**:
- Manually test: corrupt a cache file by writing invalid bytes → read returns null but logs the error.
- In debug mode, console shows `ChapterCache.read error for ...` message.

---

## Spec: Phase 3 — Bug Fixes

This phase fixes UI bugs, data mapping errors, dead code, and other regressions.

---

### Sub-task 3.1: GenreScreen filter fix — use `filteredBooks` instead of `widget.books`

**Requirement**: The `GenreScreen` computes `filteredBooks` in `initState` via `GetBooksByGenre` use case, but the grid builder uses `widget.books` instead. This means genre filtering does NOT work — the screen shows all books regardless of genre.

**Current behavior** (`genre_screen.dart`):
```dart
// Line 23: computed but never used in the grid
late final List<BookEntity> filteredBooks;

// Line 28: correct filtering logic
filteredBooks = getIt<GetBooksByGenre>()(widget.books, widget.genre);

// Line 38: BUG — uses widget.books instead of filteredBooks
widget.books.isEmpty
    ? ...
    : SliverGrid(
        ...
        childCount: widget.books.length,     // BUG
        ...
        final book = widget.books[index];    // BUG
```

**Expected behavior**: Replace all references to `widget.books` in the build method with `filteredBooks`.

**Changes** (in `genre_screen.dart`):
```dart
// Line 38:
filteredBooks.isEmpty   // was: widget.books.isEmpty

// Line 49:
childCount: filteredBooks.length,   // was: widget.books.length

// Line 51:
final book = filteredBooks[index];  // was: widget.books[index]
```

**Validation**:
- Navigate to a genre screen (e.g., "Fantasia") → only books with that genre appear.
- Switch to a different genre → different subset appears.
- If a genre has 0 books, show "No books available for this genre".

---

### Sub-task 3.2: GenreScreen scaffold — wrap in Scaffold + AppBar with back nav

**Requirement**: `GenreScreen` uses `CustomScrollView` directly without a `Scaffold` wrapper, meaning there's no back navigation and the layout is structurally incomplete. The screen is pushed via `Navigator.push` in the main screen's genre list.

**Current behavior**:
```dart
// genre_screen.dart line 32-33:
Widget build(BuildContext context) {
  return CustomScrollView(
    slivers: [
      SliverAppBar(
        title: Text('Genero: ${widget.genre}'),
      ),
```

No `Scaffold`, no `AppBar` with back button. `SliverAppBar` inside a raw `CustomScrollView` doesn't provide proper navigation scaffolding.

**Expected behavior**: Wrap the `CustomScrollView` in a `Scaffold`. Use a standard `AppBar` (not a `SliverAppBar`) with automatic back navigation.

**Changes** (in `genre_screen.dart`):
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Género: ${widget.genre}'),
    ),
    body: CustomScrollView(
      slivers: [
        // Remove the old SliverAppBar
        // Grid content stays the same
        filteredBooks.isEmpty
            ? const SliverToBoxAdapter(
                child: Center(child: Text('No hay libros disponibles para este género')))
            : SliverGrid(
                ...
              ),
      ],
    ),
  );
}
```

**Validation**:
- Navigate to genre screen → AppBar shows with genre name and back arrow.
- Tap back → returns to previous screen.
- Grid content is still scrollable.

---

### Sub-task 3.3: TookEntity `chapterCount` → `content` column mapping fix

**Requirement**: The `tooks` table has a column named `content` (not `chapter_count`). The `TookEntity` has a field `chapterCount` that incorrectly maps to `json['content']`. This is semantically wrong — `content` in the DB stores the chapter count as a string (e.g., `'12'`), not actual content.

**Current behavior**:
- `took_entity.dart` line 10: `final String chapterCount;`
- `took_repository_impl.dart` line 57: `chapterCount: json['content'] ?? ''` — reads from wrong column name semantically
- `took_repository_impl.dart` line 72: `'content': took.chapterCount` — writes to a column named `content` with chapter count data
- `book_repository_impl.dart` line 84: `chapterCount: took['content'] ?? ''` — same bug

**Expected behavior**:
- Rename `TookEntity.chapterCount` to `TookEntity.content` to match the database column.
- All references update to use `.content` instead of `.chapterCount`.
- The database column stays as `content` (no schema migration needed — this is a mapping fix).

**Changes**:
1. `lib/features/domain/entities/took_entity.dart`:
   - Rename field: `final String chapterCount;` → `final String content;`
   - Update constructor parameter name
   - Update `props` list

2. `lib/features/data/repositories/took_repository_impl.dart`:
   - `chapterCount: json['content']` → `content: json['content']`
   - `'content': took.chapterCount` → `'content': took.content`

3. `lib/features/data/repositories/book_repository_impl.dart`:
   - `chapterCount: took['content']` → `content: took['content']`

4. All usages of `TookEntity.chapterCount` in:
   - `lib/features/presentation/views/took/took_view.dart` (renders chapter count)
   - Scan-related screens that access `took.chapterCount`

**Files affected**:
- `lib/features/domain/entities/took_entity.dart`
- `lib/features/data/repositories/took_repository_impl.dart`
- `lib/features/data/repositories/book_repository_impl.dart`
- `lib/features/presentation/views/took/took_view.dart`
- `lib/features/presentation/screens/scan/scan_took_edit_screen.dart`

**Validation**:
- After rename, `took.content` returns the value from DB column `content`.
- Took view shows the chapter count value correctly.
- `flutter analyze` passes (no references to `.chapterCount`).

---

### Sub-task 3.4: BookScreen dead code removal — `showInfoDialog()`

**Requirement**: `BookScreen` has a `showInfoDialog()` method (lines 50-75) that shows an empty dialog ("Información" with an empty `Column(children: [])` and a non-functional "Aceptar" button). The `infoIcon` in the `SliverAppBarBook` references this dead code.

**Current behavior**: `showInfoDialog()` method is defined, called from `IconButton(onPressed: () => showInfoDialog())` in the build method, but the dialog has no content and the button does nothing.

**Expected behavior**: Remove the `showInfoDialog()` method and the `IconButton` that calls it from `SliverAppBarBook`.

**Changes** (in `book_screen.dart`):
```dart
// Remove lines 50-75 (showInfoDialog method entirely)

// In build, line 86-89:
SliverAppBarBook(
  books: widget.books,
  // Remove: infoIcon: IconButton(...)
),
```

**Check `sliver_app_bar_book.dart`**: The `infoIcon` parameter should either be removed or made optional. If it's required, simplify the widget to not need it.

**Files affected**:
- `lib/features/presentation/screens/book/book_screen.dart`
- `lib/features/presentation/screens/book/widgets/sliver_app_bar_book.dart` (remove/render optional the infoIcon parameter)

**Validation**:
- `BookScreen` no longer has `showInfoDialog` method.
- AppBar on book screen no longer shows the info icon button.
- `flutter analyze` passes.

---

### Sub-task 3.5: Explicit `id` removal on create

**Requirement**: `createTook` and `createChapter` (and `createGenre`) send an explicit `id` field in INSERT calls. For `tooks` and `chapters`, `id` is `SERIAL PRIMARY KEY` — the database should auto-generate it. Explicitly setting `id: 0` (as seen in scan_bloc_test fallback values with `id: 0`) or any explicit id risks conflicts and breaks auto-generation.

**Current behavior**:
```dart
// took_repository_impl.dart line 66-74:
await supabase.from('tooks').insert({
  'id': took.id,  // BUG: should not set id for SERIAL PK
  ...
});

// chapter_repository_impl.dart line 49-56:
await supabase.from('chapters').insert({
  'id': chapter.id,  // BUG
  ...
});

// genre_repository_impl.dart line 41-46:
await supabase.from('genres').insert({
  'id': genre.id,  // BUG for genres table too (INT PRIMARY KEY, not SERIAL but still)
  ...
});
```

**Note**: `genres` uses `INT PRIMARY KEY` (not `SERIAL`) — explicit `id` IS needed for genres because the seed data uses specific IDs (0-19). So `createGenre` should keep the explicit `id`.

**Expected behavior**:
- Remove `'id': took.id` from `took_repository_impl.dart` insert.
- Remove `'id': chapter.id` from `chapter_repository_impl.dart` insert.
- Keep `'id': genre.id` in `genre_repository_impl.dart`.

**Files affected**:
- `lib/features/data/repositories/took_repository_impl.dart` (remove line 67: `'id': took.id,`)
- `lib/features/data/repositories/chapter_repository_impl.dart` (remove line 50: `'id': chapter.id,`)

**Validation**:
- Create a new took via scan screen — takes gets an auto-generated ID (sequential).
- Create a new chapter — chapter gets auto-generated ID.
- Existing data is not affected (IDs already assigned remain).
- `flutter analyze` passes.

---

### Sub-task 3.6: AI boilerplate comments cleanup scope

**Requirement**: Many BLoC and use case files contain AI-generated boilerplate comments in Spanish that describe every method in verbose detail. For example, `auth_event.dart` has 8-line comments on each event class, `auth_bloc.dart` has multi-line comments on every method, `theme_bloc.dart`, `theme_state.dart`, `theme_event.dart`, `profile_bloc.dart`, `chapter_bloc.dart`, `admin_bloc.dart` all have similar boilerplate.

**Current behavior** (example from `auth_bloc.dart` line 9):
```dart
// AuthBloc es un Bloc que maneja los eventos y estados relacionados con la autenticación de usuarios en la aplicación. Utiliza casos de uso para interactuar con el dominio y actualizar el estado en consecuencia. El AuthBloc escucha eventos como verificar la sesión de autenticación, iniciar sesión, registrarse y cerrar sesión, y emite estados que reflejan el resultado de esas operaciones, como autenticado, no autenticado, carga en progreso o error.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
```

**Expected behavior**: Strip all AI-generated boilerplate comments. Keep only essential comments that explain non-obvious logic. The rule: if a comment just restates what the code clearly says, delete it.

**Scope** — files to clean:
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
- `lib/features/presentation/bloc/theme/theme_bloc.dart` (if not deleted)
- `lib/features/presentation/bloc/theme/theme_state.dart` (if not deleted)
- `lib/features/presentation/bloc/theme/theme_event.dart` (if not deleted)
- `lib/features/domain/repositories/repositories.dart` (line 1 has `//`)
- `lib/features/data/repositories/repositories.dart` (line 1 has `//`)
- `lib/features/domain/use_cases/use_cases.dart` (comments like `//  CREATE`, `//  DELETE`, etc.)

**Validation**:
- Files are shorter, cleaner, no multi-line Spanish boilerplate.
- All essential logic comments remain (e.g., `_manualLogoutInProgress` explanation).
- `flutter analyze` passes.

---

### Sub-task 3.7: `coverUrl()` validation — return placeholder if cover empty

**Requirement**: `coverUrl('')` currently calls `supabase.storage.from('covers').getPublicUrl('')` which returns a broken URL. If cover is empty, return a placeholder image URL or an empty string.

**Current behavior**:
```dart
// storage_helper.dart:
String coverUrl(String cover) =>
    supabase.storage.from('covers').getPublicUrl(cover);
// coverUrl('') → "http://.../storage/v1/object/public/covers/" — broken
```

**Expected behavior**:
```dart
String coverUrl(String cover) {
  if (cover.isEmpty) return '';
  return supabase.storage.from('covers').getPublicUrl(cover);
}
```

Also, consumers that use `coverUrl` should handle empty URL gracefully. The `CachedNetworkImage` in `genre_screen.dart` already has an `errorWidget` fallback, but better to not attempt loading a broken URL at all.

**Files affected**:
- `lib/core/supabase/storage_helper.dart`

**Validation**:
- `coverUrl('')` returns `''` (empty string).
- `coverUrl('cr/soloLeveling.png')` returns the valid public URL.
- Book cards with no cover show the error placeholder.

---

## Spec: Phase 4 — Testing

This phase adds test coverage for all untested blocs and repository implementations. Existing tests (`book_bloc_test.dart`, `genre_bloc_test.dart`, `scan_bloc_test.dart`) serve as the pattern reference.

---

### Sub-task 4.1: AuthBloc tests

**Current state**: NO tests exist for `AuthBloc`.

**Files to create**: `test/bloc/auth_bloc_test.dart`

**Mock setup**:
```dart
class MockLogin extends Mock implements Login {}
class MockRegister extends Mock implements Register {}
class MockLogout extends Mock implements Logout {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}
class MockListenAuthChanges extends Mock implements ListenAuthChanges {}
```

**Minimum test scenarios**:

| # | Scenario | Event | Mock setup | Expected state sequence |
|---|----------|-------|------------|------------------------|
| 1 | Initial state | — | — | `AuthInitial` |
| 2 | Login success | `LoginRequested('a@b.com', 'pass')` | `login()` returns `UserEntity(...)` | `[AuthLoading, AuthAuthenticated(user)]` |
| 3 | Login error | `LoginRequested('a@b.com', 'wrong')` | `login()` throws `Exception('Invalid credentials')` | `[AuthLoading, AuthError('Invalid credentials')]` |
| 4 | Register success | `RegisterRequested('a@b.com', 'pass')` | `register()` returns `UserEntity(...)` | `[AuthLoading, AuthAuthenticated(user)]` |
| 5 | Register error | `RegisterRequested('a@b.com', 'pass')` | `register()` throws `Exception('Email taken')` | `[AuthLoading, AuthError('Email taken')]` |
| 6 | Logout success | `LogoutRequested()` | `logout()` returns void | `[AuthLoading, AuthUnauthenticated]` |
| 7 | Logout error | `LogoutRequested()` | `logout()` throws `Exception('Error')` | `[AuthLoading, AuthError('Error')]` |
| 8 | Session check — authenticated | `CheckAuthSession()` | `getCurrentUser()` returns `UserEntity(...)` | `[AuthLoading, AuthAuthenticated(user)]` |
| 9 | Session check — unauthenticated | `CheckAuthSession()` | `getCurrentUser()` returns `null` | `[AuthLoading, AuthUnauthenticated]` |
| 10 | Session check — error | `CheckAuthSession()` | `getCurrentUser()` throws | `[AuthLoading, AuthUnauthenticated]` |

**Assertions**:
- `AuthAuthenticated` has `user` with correct `email` and `role`.
- `AuthError` has `message` containing the error string.
- `AuthUnauthenticated` has no extra properties.

---

### Sub-task 4.2: ProfileBloc tests

**Current state**: NO tests exist for `ProfileBloc`.

**Files to create**: `test/bloc/profile_bloc_test.dart`

**Mock setup**:
```dart
class MockGetProfile extends Mock implements GetProfile {}
class MockUpdateProfile extends Mock implements UpdateProfile {}
class MockUploadAvatar extends Mock implements UploadAvatar {}
class MockChangePassword extends Mock implements ChangePassword {}
```

**Minimum test scenarios**:

| # | Scenario | Event | Mock setup | Expected |
|---|----------|-------|------------|----------|
| 1 | Initial state | — | — | `ProfileInitial` |
| 2 | Load profile success | `LoadProfile()` | `getProfile()` returns `UserEntity(...)` | `[ProfileLoading, ProfileLoaded(user)]` |
| 3 | Load profile error | `LoadProfile()` | `getProfile()` throws `Exception('Error')` | `[ProfileLoading, ProfileError('Error')]` |
| 4 | Update profile success | `UpdateProfile(displayName: 'New', bio: 'Bio')` | `updateProfile()` returns updated entity | `[ProfileSaving, ProfileLoaded(updated)]` |
| 5 | Update profile error | `UpdateProfile(...)` | `updateProfile()` throws | `[ProfileSaving, ProfileError(..., user: current)]` |
| 6 | Change password success | `ChangePassword('newPass')` | `changePassword()` returns void | `[ProfileSaving, ProfileLoaded(message: ...)]` |
| 7 | Change password error | `ChangePassword('newPass')` | `changePassword()` throws | `[ProfileSaving, ProfileError(...)]` |

**Assertions**:
- `ProfileLoaded` has `user.email` matching mock.
- `ProfileError` has `message` and optionally `user`.
- Profile must be loaded before update/changePassword — test guards against calling update when state is `ProfileInitial`.

---

### Sub-task 4.3: LabelBloc tests

**Current state**: NO tests exist for `LabelBloc`.

**Files to create**: `test/bloc/label_bloc_test.dart`

**Mock setup**:
```dart
class MockGetLabels extends Mock implements GetLabels {}
class MockCreateLabel extends Mock implements CreateLabel {}
class MockDeleteLabel extends Mock implements DeleteLabel {}
class MockAssignLabelToBook extends Mock implements AssignLabelToBook {}
class MockRemoveLabelFromBook extends Mock implements RemoveLabelFromBook {}
class MockGetBookLabels extends Mock implements GetBookLabels {}
```

**Minimum test scenarios**:

| # | Scenario | Event | Mock setup | Expected |
|---|----------|-------|------------|----------|
| 1 | Initial state | — | — | `LabelInitial` |
| 2 | Load labels success | `LoadLabels()` | `getLabels()` returns `[LabelEntity(...)]`, `getBookLabels()` returns `{1: {2}}` | `[LabelLoading, LabelLoaded(labels, bookLabels)]` |
| 3 | Load labels error | `LoadLabels()` | `getLabels()` throws | `[LabelLoading, LabelError(...)]` |
| 4 | Create label success | `CreateLabelEvent('New', '#fff')` | `createLabel()` returns void, then reload succeeds | `[LabelLoaded(...)]` (via _emitLoaded) |
| 5 | Create label error | `CreateLabelEvent(...)` | `createLabel()` throws | `[LabelError(...)]` |
| 6 | Delete label success | `DeleteLabelEvent(1)` | `deleteLabel()` returns void, then reload | `[LabelLoaded(...)]` |
| 7 | Assign label success | `AssignLabelEvent(1, 2)` | `assignLabel()` returns void, then reload | `[LabelLoaded(...)]` |
| 8 | Remove label success | `RemoveLabelEvent(1, 2)` | `removeLabel()` returns void, then reload | `[LabelLoaded(...)]` |

**Assertions**:
- `LabelLoaded` has `labels` list and `bookLabels` map.
- `LabelError` has `message` string.
- After create/delete/assign/remove, a new `LabelLoaded` is emitted with fresh data (not cached).

---

### Sub-task 4.4: AdminBloc tests

**Current state**: NO tests exist for `AdminBloc`.

**Files to create**: `test/bloc/admin_bloc_test.dart`

**Mock setup**:
```dart
class MockGetBooks extends Mock implements GetBooks {}
class MockToggleBookVisibility extends Mock implements ToggleBookVisibility {}
```

**Minimum test scenarios**:

| # | Scenario | Event | Mock setup | Expected |
|---|----------|-------|------------|----------|
| 1 | Initial state | — | — | `AdminInitial` |
| 2 | Load books success | `LoadAdminBooks()` | `getBooks()` returns `[BookEntity(...)]` | `[AdminLoading, AdminLoaded(books)]` |
| 3 | Load books error | `LoadAdminBooks()` | `getBooks()` throws | `[AdminLoading, AdminError(...)]` |
| 4 | Toggle visibility success | `ToggleBookVisibility(1, false)` | `toggleVisibility()` returns void, `getBooks()` returns updated | `[AdminLoaded(..., message: 'Libro ocultado')]` |
| 5 | Toggle visibility error | `ToggleBookVisibility(1, false)` | `toggleVisibility()` throws | `[AdminError(...)]` |

**Assertions**:
- `AdminLoaded` has `books` list and optional `message`.
- `AdminError` has `message`.

---

### Sub-task 4.5: ChapterBloc tests

**Current state**: NO tests exist for `ChapterBloc`.

**Files to create**: `test/bloc/chapter_bloc_test.dart`

**Mock setup**:
```dart
class MockGetChapterContent extends Mock implements GetChapterContent {}
```

**Minimum test scenarios**:

| # | Scenario | Event | Mock setup | Expected |
|---|----------|-------|------------|----------|
| 1 | Initial state | — | — | `ChapterInitial` |
| 2 | Load content success | `LoadChapterContent(initialIndex: 0, chapters: [...])` | `getChapterContent()` returns content strings | `[ChapterLoading, ChapterLoaded(chapters, initialIndex: 0)]` |
| 3 | Load content error | `LoadChapterContent(...)` | `getChapterContent()` throws | `[ChapterLoading, ChapterError(...)]` |
| 4 | Load content with multiple chapters | `LoadChapterContent(initialIndex: 0, chapters: [ch1, ch2])` | `getChapterContent()` returns different content per path | `[ChapterLoading, ChapterLoaded]` with 2 chapters |

**Assertions**:
- `ChapterLoaded` has `chapters` list and `initialIndex`.
- Each `ChapterEntity` in result has `content` resolved from the use case.
- `ChapterError` has `message`.

---

### Sub-task 4.6: Repository impl tests (book, took, chapter)

**Current state**: NO repository tests exist. The existing bloc tests mock the use case layer, so repository impls are not tested.

**Files to create**:
- `test/repositories/book_repository_impl_test.dart`
- `test/repositories/took_repository_impl_test.dart`
- `test/repositories/chapter_repository_impl_test.dart`

**Approach**: These tests require a mock Supabase client. Use the `supabase_flutter` mock pattern. Since the app uses the global `supabase` instance (from `supabase_client.dart`), the tests need to either:
- Use dependency injection to swap the Supabase client
- Or create integration-level tests

**Recommended approach**: Create the test structure but mark as **integration-level** (requires Supabase local/dev instance or mock HTTP client). For unit-level testing, the tests should verify that:
- `from().select()` calls are made with correct parameters
- Mapping logic produces correct entities
- Error handling wraps exceptions correctly

Due to the global `supabase` instance complexity, these tests may need `mocktail`'s `registerFallbackValue` and a mock Supabase client. Consider using a `SupabaseClient` mock approach:

```dart
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements PostgrestQueryBuilder {}
class MockSupabaseResponse extends Mock implements PostgrestResponse {}
```

**Minimum test scenarios per repository**:

**BookRepositoryImpl**:
- `getBooks()` returns list of BookEntity with nested genres, labels, tooks, chapters
- `getBookById(1)` returns single BookEntity
- `getBookById(999)` returns null
- `createBook()` calls insert with correct data
- `updateBook()` calls update with correct data
- `deleteBook()` deletes cascading (books_genres, chapters, tooks, book)

**TookRepositoryImpl**:
- `getTooks()` returns list of TookEntity with nested chapters
- `getTookById(1)` returns single TookEntity
- `createTook()` calls insert (without id field)
- `updateTook()` calls update
- `deleteTook()` deletes chapters first, then took

**ChapterRepositoryImpl**:
- `getChapters()` returns list of ChapterEntity
- `getChapterById(1)` returns single ChapterEntity
- `createChapter()` calls insert (without id field)
- `downloadContent(path)` returns cached content if available
- `downloadContent(path)` downloads from storage if not cached

**Validation**:
- All 5 new test files pass: `flutter test test/bloc/auth_bloc_test.dart test/bloc/profile_bloc_test.dart test/bloc/label_bloc_test.dart test/bloc/admin_bloc_test.dart test/bloc/chapter_bloc_test.dart`
- Output shows all tests passing (expected: ~30+ test cases across 5 files).

---

## Spec: Phase 5 — UI/UX

This phase moves the immersive mode to the correct screen and removes the unused Cupertino icons dependency.

---

### Sub-task 5.1: Immersive mode relocation — from main.dart to ChapterScreen only

**Requirement**: `SystemUiMode.immersive` is set globally in `main.dart` line 17, which hides status and navigation bars throughout the entire app. This should only be active on the `ChapterScreen` (reading screen), where a distraction-free experience makes sense. All other screens should use the default system UI mode.

**Current behavior** (`main.dart` line 17):
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
```
This is called once at startup and applies to the entire app lifecycle. There's no way to restore system UI except by restarting the app.

**Expected behavior**:
- Remove the global `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);` from `main.dart`.
- In `ChapterScreen`, enable immersive mode in `initState` and restore to `SystemUiMode.edgeToEdge` in `dispose`.

**Changes**:

1. `lib/main.dart` — remove line 17:
```dart
// Remove this line:
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
```

2. `lib/features/presentation/screens/chapter/chapter_screen.dart` — add in `initState` and `dispose`:
```dart
@override
void initState() {
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // ... existing code ...
}

@override
void dispose() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // ... existing code ...
}
```

**Add import**: `import 'package:flutter/services.dart';` (already available — check if `flutter/rendering.dart` import covers it; `services.dart` is the correct import).

**Validation**:
- App launches with default system UI (status bar visible, navigation bar visible).
- Navigate to ChapterScreen → status/navigation bars hide (immersive mode).
- Leave ChapterScreen (pop back) → bars reappear.
- Test with system gestures: swiping from bottom shows navigation bar temporarily (standard immersive behavior).

---

### Sub-task 5.2: Cupertino icons removal

**Requirement**: The `cupertino_icons` dependency is declared in `pubspec.yaml` but may not be used anywhere in the app (the codebase uses Material Icons via `Icons.*`). Remove the unused dependency.

**Current behavior** (`pubspec.yaml` line 14):
```yaml
cupertino_icons: ^1.0.8
```

**Expected behavior**: Remove the line from `pubspec.yaml`. Check the codebase for any `CupertinoIcons.*` usage first — if any exist, replace with equivalent `Icons.*`.

**Check**: Search `lib/` for `CupertinoIcons` or `cupertino` references.

**Files affected**:
- `pubspec.yaml` (remove line 14: `cupertino_icons: ^1.0.8`)

**Validation**:
- `flutter pub get` succeeds without `cupertino_icons`.
- `flutter analyze` passes.
- No UI elements show missing icons.

---

## Success Criteria Verification

| Criterion | Phase | How to verify |
|-----------|-------|---------------|
| RLS enabled on genres, books_genres, authors | 1 | `SELECT tablename, rowsecurity FROM pg_tables WHERE tablename IN ('genres', 'books_genres', 'authors')` — all true |
| Admin (role) can INSERT/UPDATE/DELETE on all content tables | 1 | Test with admin user on each table |
| `filteredBooks` used in GenreScreen | 3 | Visual verify — only matching genre books shown |
| `.env` removed from git tracking | 1 | `git ls-files --cached .env` — empty |
| `LabelRepositoryImpl` importable from barrel | 2 | `import` from barrel works in analyzer |
| AuthBloc no longer imports supabase | 2 | Check imports in auth_bloc.dart |
| DTOs exist for all 5 main entities | 2 | Files exist in `lib/features/data/models/` |
| Untested blocs have smoke tests | 4 | `flutter test` passes for all 5 new test files |
| `coverUrl('')` returns placeholder | 3 | Function returns `''` for empty input |
| Immersive mode only on chapter screen | 5 | Navigate to chapter — bars hidden; leave — bars visible |
| Password policy enforced | 1 | Register with weak password — rejected |
| Email confirmations enabled | 1 | New user must confirm email |
| Hardcoded UUIDs replaced with subquery | 1 | Migration uses dynamic lookup |
| Redundant migration removed | 1 | File 20260518020000 deleted from repo |
| FK indexes exist | 1 | All 5 indexes in pg_indexes |
| GenreScreen wrapped in Scaffold | 3 | AppBar with back button visible |
| `TookEntity.chapterCount` renamed to `content` | 3 | No references to `chapterCount` |
| Dead `showInfoDialog` removed | 3 | Method absent from BookScreen |
| Explicit `id` not sent on create | 3 | INSERT calls omit `id` for SERIAL tables |
| ThemeBloc simplified/removed | 3 | No events registered or files deleted |
| AI comments stripped | 3 | BLoC files have minimal essential comments |
| Exception types preserved | 2 | Throws typed AppException subclasses |
| ChapterCache logs errors | 2 | `debugPrint` in catch blocks |
| Cupertino icons removed | 5 | Dependency absent from pubspec.yaml |
