# Design: Audit Fixes — Complete

> Based on proposal at `openspec/changes/audit-fixes-complete/proposal.md`
> Codebase: Flutter 3.3+, Clean Architecture, BLoC, Supabase Flutter, get_it, Mocktail

---

## Phase 1 — Security & Database

### Migration File
**File:** `supabase/migrations/20260519000001_audit_fixes.sql`

Order of operations matters. Run in this exact sequence:

```sql
-- ===========================================================
-- ORDER OF OPERATIONS (do NOT reorder):
--   1. Enable RLS on tables missing it
--   2. Add missing FK indexes
--   3. Consolidate redundant migrations (skip authors fix, already in 20260518020000)
--   4. Replace hardcoded UUIDs with DO-block subquery
--   5. Add admin write policies on content tables
-- ===========================================================

-- STEP 1: Enable RLS on genres, books_genres, authors
ALTER TABLE genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE books_genres ENABLE ROW LEVEL SECURITY;
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;

-- STEP 1b: SELECT policies for the newly-enabled tables
DROP POLICY IF EXISTS "Enable read for all users" ON genres;
CREATE POLICY "Enable read for all users" ON genres FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable read for all users" ON books_genres;
CREATE POLICY "Enable read for all users" ON books_genres FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable read for all users" ON authors;
CREATE POLICY "Enable read for all users" ON authors FOR SELECT USING (true);

-- STEP 2: FK indexes for performance
CREATE INDEX IF NOT EXISTS idx_tooks_book_id ON tooks(book_id);
CREATE INDEX IF NOT EXISTS idx_chapters_took_id ON chapters(took_id);
CREATE INDEX IF NOT EXISTS idx_books_genres_book_id ON books_genres(book_id);
CREATE INDEX IF NOT EXISTS idx_books_genres_genre_id ON books_genres(genre_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_book_id ON books_labels(book_id);
CREATE INDEX IF NOT EXISTS idx_books_labels_label_id ON books_labels(label_id);
CREATE INDEX IF NOT EXISTS idx_books_created_by ON books(created_by);

-- STEP 3: Consolidate — drop redundant policies from 20260518010000
-- (20260518010000_admin_ownership.sql and 20260518020000_fix_authors_rls.sql overlap)
DROP POLICY IF EXISTS "Enable read for all users" ON authors;  -- re-created above

-- STEP 4: Replace hardcoded UUID '4723bbc3-...' with subquery
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  SELECT id INTO admin_uid FROM auth.users
  WHERE email = 'rafaelvillahinojosa@gmail.com'
  LIMIT 1;

  IF admin_uid IS NULL THEN
    RAISE WARNING 'Admin user not found — skipping created_by assignment';
    RETURN;
  END IF;

  UPDATE books SET created_by = admin_uid WHERE created_by IS NULL;
  UPDATE tooks SET created_by = admin_uid WHERE created_by IS NULL;
  UPDATE chapters SET created_by = admin_uid WHERE created_by IS NULL;
END;
$$;

-- STEP 5: Admin write policies on content tables
-- Admin role needs explicit INSERT/UPDATE/DELETE on all content tables
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY['books', 'genres', 'tooks', 'chapters', 'books_genres', 'authors'])
  LOOP
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable insert for admin only" ON %I', tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable insert for admin only" ON %I FOR INSERT WITH CHECK (public.is_admin())', tbl
    );
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable update for admin only" ON %I', tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable update for admin only" ON %I FOR UPDATE USING (public.is_admin())', tbl
    );
    EXECUTE format(
      'DROP POLICY IF EXISTS "Enable delete for admin only" ON %I', tbl
    );
    EXECUTE format(
      'CREATE POLICY "Enable delete for admin only" ON %I FOR DELETE USING (public.is_admin())', tbl
    );
  END LOOP;
END;
$$;
```

### Config Changes
**File:** `supabase/config.toml` — change these values:

```toml
# Line 175: password minimum 8
minimum_password_length = 8

# Line 178: require mixed-case + digits
password_requirements = "lower_upper_letters_digits"

# Line 219: enable email confirmations
enable_confirmations = true

# Line 223: rate limit to 60s between emails
max_frequency = "60s"
```

### .env Removal

```bash
# 1. Remove .env from git tracking (already in .gitignore but tracked)
git rm --cached .env

# 2. Scrub from git history (run on a CLONE, not the working repo)
#    Requires git-filter-repo installed:
#    pip install git-filter-repo
git clone <repo-url> noveles-clean
cd noveles-clean
git filter-repo --path .env --invert-paths

# 3. Verify no remnants
git log --all --full-history -- .env  # should return nothing

# 4. Push cleaned history
git remote add origin <clean-url>
git push origin --force --all
```

**File:** `.gitignore` — `.env` entry already present at line 35. No change needed.

---

## Phase 2 — Architecture

### 2.1 New DTO Models

Create directory: `lib/features/data/models/`

**Pattern** — each model extends the domain Entity, adds `fromJson`/`toJson`:

#### `lib/features/data/models/book_model.dart`

```dart
import 'package:noveles/features/data/models/genre_model.dart';
import 'package:noveles/features/data/models/label_model.dart';
import 'package:noveles/features/data/models/took_model.dart';
import 'package:noveles/features/domain/entities/entities.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.createdAt,
    required super.cover,
    required super.name,
    required super.short,
    required super.alternative,
    required super.description,
    required super.authorId,
    required super.author,
    required super.country,
    required super.state,
    required super.type,
    required super.release,
    required super.tookCount,
    required super.chapterCount,
    required super.source,
    required super.link,
    required super.isFavorite,
    required super.isVisible,
    required super.listGenre,
    required super.listTook,
    required super.listLabel,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final authorData = Map<String, dynamic>.from(json['authors']);

    final listGenre = (json['books_genres'] as List<dynamic>).map((bg) {
      return GenreModel.fromJson(Map<String, dynamic>.from(bg['genres']));
    }).toList();

    final listLabel = ((json['books_labels'] as List<dynamic>?) ?? []).map((bl) {
      return LabelModel.fromJson(Map<String, dynamic>.from(bl['labels']));
    }).toList();

    final listTook = ((json['tooks'] as List<dynamic>?) ?? []).map((t) {
      return TookModel.fromJson(Map<String, dynamic>.from(t));
    }).toList();

    return BookModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      cover: json['cover'] ?? '',
      name: json['name'] ?? '',
      short: json['short'] ?? '',
      alternative: json['alternative'] ?? '',
      description: json['description'] ?? '',
      authorId: json['author_id'] ?? 0,
      author: authorData['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      type: json['type'] ?? '',
      release: json['release'] ?? '',
      tookCount: json['took_count'] ?? '',
      chapterCount: json['chapter_count'] ?? '',
      source: json['source'] ?? '',
      link: json['link'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      isVisible: json['is_visible'] ?? true,
      listGenre: listGenre,
      listTook: listTook,
      listLabel: listLabel,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'cover': cover,
    'name': name,
    'short': short,
    'alternative': alternative,
    'description': description,
    'author_id': authorId,
    'country': country,
    'state': state,
    'type': type,
    'release': release,
    'took_count': tookCount,
    'chapter_count': chapterCount,
    'source': source,
    'link': link,
    'is_favorite': isFavorite,
    'is_visible': isVisible,
  };
}
```

#### `lib/features/data/models/took_model.dart`

```dart
import 'package:noveles/features/data/models/chapter_model.dart';
import 'package:noveles/features/domain/entities/entities.dart';

class TookModel extends TookEntity {
  const TookModel({
    required super.id,
    required super.createdAt,
    required super.cover,
    required super.number,
    required super.title,
    required super.chapterCount,
    required super.bookId,
    required super.listChapter,
  });

  factory TookModel.fromJson(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? []).map((ch) {
      return ChapterModel.fromJson(Map<String, dynamic>.from(ch));
    }).toList();

    return TookModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      cover: json['cover'] ?? '',
      number: json['number'] ?? '',
      title: json['title'] ?? '',
      chapterCount: json['content'] ?? '',  // BUG: maps to 'content' column — see Phase 3 fix
      bookId: json['book_id'] ?? 0,
      listChapter: chapters,
    );
  }

  Map<String, dynamic> toJson() => {
    'cover': cover,
    'number': number,
    'title': title,
    'content': chapterCount,  // maps chapterCount back to 'content' column
    'book_id': bookId,
  };
}
```

#### `lib/features/data/models/chapter_model.dart`

```dart
import 'package:noveles/features/domain/entities/entities.dart';

class ChapterModel extends ChapterEntity {
  const ChapterModel({
    required super.id,
    required super.createdAt,
    required super.number,
    required super.title,
    required super.content,
    required super.tookId,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    number: json['number'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    tookId: json['took_id'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'content': content,
    'took_id': tookId,
  };
}
```

#### `lib/features/data/models/genre_model.dart`

```dart
import 'package:noveles/features/domain/entities/entities.dart';

class GenreModel extends GenreEntity {
  const GenreModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.description,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    name: json['name'] ?? '',
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}
```

#### `lib/features/data/models/label_model.dart`

```dart
import 'package:noveles/features/domain/entities/entities.dart';

class LabelModel extends LabelEntity {
  const LabelModel({
    required super.id,
    required super.createdAt,
    required super.name,
    required super.color,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
    id: json['id'],
    createdAt: DateTime.parse(json['created_at']),
    name: json['name'] ?? '',
    color: json['color'] ?? '#71A202',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
  };
}
```

#### `lib/features/data/models/models.dart` (barrel)

```dart
export 'package:noveles/features/data/models/book_model.dart';
export 'package:noveles/features/data/models/chapter_model.dart';
export 'package:noveles/features/data/models/genre_model.dart';
export 'package:noveles/features/data/models/label_model.dart';
export 'package:noveles/features/data/models/took_model.dart';
```

### 2.2 Repository Refactors

Each repository impl replaces raw `_mapTo*Entity` with DTO `fromJson`. The domain repository interfaces stay unchanged — DTOs inherit from entities.

**Before (book_repository_impl.dart):**
```dart
BookEntity _mapToBookEntity(Map<String, dynamic> json) {
  final authorData = Map<String, dynamic>.from(json['authors']);
  // ... 70 lines of manual mapping
}
return response.map((json) => _mapToBookEntity(json)).toList();
```

**After:**
```dart
import 'package:noveles/features/data/models/models.dart';
// ...
return response.map((json) => BookModel.fromJson(json)).toList();
```

**Before (took_repository_impl.dart):**
```dart
TookEntity _mapToTookEntity(Map<String, dynamic> json) {
  final chapters = ...;
  return TookEntity(/* 8 fields mapped manually */);
}
```

**After:**
```dart
import 'package:noveles/features/data/models/models.dart';
// ...
return response.map((json) => TookModel.fromJson(Map<String, dynamic>.from(json))).toList();
```

**Remove all `_mapTo*Entity` private methods** from every repository impl — they are replaced by DTO models.

**DI changes:** No changes to `injection.dart` — DTOs are internal to the data layer. Only the imports change in the impl files.

### 2.3 Bloc Supabase Removal

#### AuthBloc — Inject `ListenAuthState` use case

**New file:** `lib/features/domain/use_cases/listen_auth_state.dart`

```dart
import 'dart:async';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class ListenAuthState {
  final AuthRepository repository;

  ListenAuthState(this.repository);

  Stream<AuthChangeEvent> call() => repository.onAuthStateChange();
}
```

**New method in `AuthRepository`/`AuthRepositoryImpl`:**

```dart
// In domain/repositories/auth_repository.dart:
Stream<AuthChangeEvent> onAuthStateChange();

// In data/repositories/auth_repository_impl.dart:
@override
Stream<AuthChangeEvent> onAuthStateChange() =>
    supabase.auth.onAuthStateChange.map((data) => data.event);
```

**AuthBloc changes:**
```dart
// REMOVE:
// import 'package:noveles/core/supabase/supabase_client.dart';
// import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

// ADD:
import 'package:noveles/features/domain/use_cases/listen_auth_state.dart';

// ADD constructor param:
final ListenAuthState listenAuthState;

// REPLACE _listenAuthChanges:
void _listenAuthChanges() {
  _authSubscription = listenAuthState().listen((event) {
    if (event == AuthChangeEvent.signedOut && !_manualLogoutInProgress) {
      add(LogoutRequested());
    }
  });
}

// REPLACE supabase.auth.currentUser check:
// Before: if (supabase.auth.currentUser != null)
// After:  Just remove the check (logout() handles it or add it to the use case)
// Simplest: rely on logout() use case which already wraps the repository
```

**DI update in `injection.dart`:**
```dart
// Add to AuthRepository:
getIt.registerLazySingleton(() => ListenAuthState(getIt()));

// Pass to AuthBloc:
getIt.registerFactory(
  () => AuthBloc(
    login: getIt(),
    register: getIt(),
    logout: getIt(),
    getCurrentUser: getIt(),
    listenAuthState: getIt(),  // NEW
  ),
);
```

#### LabelBloc — Route through `bookRepository.getBookLabels()`

**New method in `BookRepository`:**
```dart
Future<Map<int, Set<int>>> getBookLabels();
```

**New use case:** `lib/features/domain/use_cases/get_book_labels.dart`

```dart
class GetBookLabels {
  final BookRepository repository;
  GetBookLabels(this.repository);
  Future<Map<int, Set<int>>> call() => repository.getBookLabels();
}
```

**Implementation in `BookRepositoryImpl`:**
```dart
@override
Future<Map<int, Set<int>>> getBookLabels() async {
  final rows = await supabase.from('books_labels').select();
  final map = <int, Set<int>>{};
  for (final row in rows) {
    map.putIfAbsent(row['book_id'], () => {}).add(row['label_id']);
  }
  return map;
}
```

**LabelBloc changes:**
```dart
// REMOVE:
// import 'package:noveles/core/supabase/supabase_client.dart';

// ADD constructor param:
final GetBookLabels getBookLabels;

// REPLACE _fetchBookLabels:
Future<Map<int, Set<int>>> _fetchBookLabels() => getBookLabels();
```

**DI update:**
```dart
getIt.registerLazySingleton(() => GetBookLabels(getIt()));

getIt.registerFactory(
  () => LabelBloc(
    getLabels: getIt(),
    createLabel: getIt(),
    deleteLabel: getIt(),
    assignLabel: getIt(),
    removeLabel: getIt(),
    getBookLabels: getIt(),  // NEW
  ),
);
```

### 2.4 Export `LabelRepositoryImpl` from Barrel

**File:** `lib/features/data/repositories/repositories.dart`

```dart
// Add line after profiles_repository_impl:
export 'package:noveles/features/data/repositories/label_repository_impl.dart';
```

### 2.5 Error Handling Pattern

**New file:** `lib/core/errors/repository_exception.dart`

```dart
class RepositoryException implements Exception {
  final String message;
  final Object? originalException;
  final String? repositoryName;

  const RepositoryException({
    required this.message,
    this.originalException,
    this.repositoryName,
  });

  @override
  String toString() {
    final prefix = repositoryName != null ? '[$repositoryName] ' : '';
    final original = originalException != null ? ' (cause: $originalException)' : '';
    return '${prefix}Error: $message$original';
  }
}
```

**Before pattern (in every repo):**
```dart
try {
  // ...
} catch (e) {
  throw Exception('Error al obtener libros: $e');
}
```

**After pattern:**
```dart
try {
  // ...
} catch (e) {
  throw RepositoryException(
    message: 'Error al obtener libros',
    originalException: e,
    repositoryName: 'BookRepository',
  );
}
```

### 2.6 ChapterCache Logging

**File:** `lib/core/supabase/chapter_cache.dart`

**Before:**
```dart
} catch (_) {
  return null;
}
```

**After:**
```dart
} catch (e) {
  // ignore: avoid_print
  debugPrint('ChapterCache error: $e');  // or inject a Logger
  return null;
}
```

Apply same pattern to the `save()` catch block.

---

## Phase 3 — Bug Fixes

### 3.1 GenreScreen

**File:** `lib/features/presentation/screens/genre/genre_screen.dart`

**Fix 1: Use `filteredBooks` instead of `widget.books`**

Change lines 38 and 49:
```dart
// Before (line 38):
widget.books.isEmpty
// After:
filteredBooks.isEmpty

// Before (line 49):
childCount: widget.books.length,
// After:
childCount: filteredBooks.length,

// Before (line 51):
final book = widget.books[index];
// After:
final book = filteredBooks[index];
```

**Fix 2: Wrap in Scaffold with AppBar**

Remove the `CustomScrollView` / `SliverAppBar` as the root and replace with a Scaffold:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Género: ${widget.genre}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: filteredBooks.isEmpty
        ? const Center(child: Text('No hay libros disponibles para este género'))
        : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 0.65,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return Card(/* ... (same card content as before) */);
            },
          ),
  );
}
```

### 3.2 TookEntity / TookRepository — Column Mapping

**Current bug:** `tooks.content` column stores chapter count, not content. The entity field is `chapterCount` but maps to `json['content']`.

**Options considered:**
1. Rename DB column `content` → `chapter_count` (ALTER COLUMN) — breaks existing data
2. Add new `chapter_count` column, migrate data, stop using `content` — safe migration
3. Just rename the field in the entity for clarity — simplest

**Decision:** Option 2 (schema fix + new column mapping). This is the "schema fix" per the out-of-scope note.

**Migration SQL additions (add to `20260519000001_audit_fixes.sql`):**

```sql
-- Fix column semantics: add chapter_count to tooks, deprecate 'content'
ALTER TABLE tooks ADD COLUMN IF NOT EXISTS chapter_count TEXT DEFAULT '';
UPDATE tooks SET chapter_count = content WHERE chapter_count = '' AND content != '';
-- Note: keep 'content' column for now (no data loss), new code maps chapter_count
```

**Entity field rename:** Rename `TookEntity.chapterCount` → `TookEntity.chapterCount` (keep name, just fix mapping inside model).

Actually, re-reading the proposal: "Rename TookEntity.chapterCount to clarify mapping". The field name `chapterCount` is already clear. The real fix is the model mapping: use `json['chapter_count']` instead of `json['content']` after the migration.

**Model change:**
```dart
// Before in TookModel.fromJson:
chapterCount: json['content'] ?? '',
// After:
chapterCount: json['chapter_count'] ?? json['content'] ?? '',  // fallback for old rows
```

**Repository impl change (updateTook/createTook):**
```dart
// Before:
'content': took.chapterCount,
// After:
'chapter_count': took.chapterCount,
```

### 3.3 BookScreen Dead Code

**File:** `lib/features/presentation/screens/book/book_screen.dart`

Remove the `showInfoDialog()` method (lines 50-75) and the `infoIcon` reference in `SliverAppBarBook`:

```dart
// Remove entire method (lines 50-75)

// In build method, change:
infoIcon: IconButton(
  onPressed: () => showInfoDialog(),
  icon: const Icon(Icons.info_outlined),
),
// To: remove the infoIcon parameter entirely
```

### 3.4 Remove Explicit `id` on Create

**File:** `lib/features/data/repositories/took_repository_impl.dart`
```dart
// Before line 67:
'id': took.id,
// After: remove this line — id is SERIAL, auto-generated
```

**File:** `lib/features/data/repositories/chapter_repository_impl.dart`
```dart
// Before line 50:
'id': chapter.id,
// After: remove this line
```

**File:** `lib/features/data/repositories/genre_repository_impl.dart`
```dart
// Before line 42:
'id': genre.id,
// After: remove this line
```

### 3.5 Strip AI Boilerplate Comments

All bloc files contain Spanish AI-generated comments like:
```dart
// AuthBloc es un Bloc que maneja los eventos y estados relacionados con la autenticación de usuarios en la aplicación. Utiliza casos de uso para interactuar con el dominio y actualizar el estado en consecuencia.
```

**Action:** Replace with minimal English comments or remove entirely. Keep only meaningful documentation (e.g., why, not what).

### 3.7 Validate `coverUrl()`

**File:** `lib/core/supabase/storage_helper.dart`

```dart
// Before:
String coverUrl(String cover) =>
    supabase.storage.from('covers').getPublicUrl(cover);

// After:
String coverUrl(String cover) {
  if (cover.isEmpty) return '';  // or a placeholder asset
  return supabase.storage.from('covers').getPublicUrl(cover);
}
```

If a placeholder asset is preferred:
```dart
if (cover.isEmpty) return 'assets/images/placeholder_cover.png';
```

---

## Phase 4 — Testing

### 4.1 Test File Structure

```
test/
  bloc/
    auth_bloc_test.dart          (NEW)
    profile_bloc_test.dart       (NEW)
    label_bloc_test.dart         (NEW)
    admin_bloc_test.dart         (NEW)
    chapter_bloc_test.dart       (NEW)
    book_bloc_test.dart          (existing)
    genre_bloc_test.dart         (existing)
    scan_bloc_test.dart          (existing)
  repositories/
    book_repository_test.dart    (NEW)
    took_repository_test.dart    (NEW)
    chapter_repository_test.dart (NEW)
```

### 4.2 Mock Setup Strategy

Use Mocktail for all mocks. Each test file follows the established pattern:

```dart
// Mock use cases
class MockLogin extends Mock implements Login {}
class MockRegister extends Mock implements Register {}
class MockLogout extends Mock implements Logout {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}
class MockListenAuthState extends Mock implements ListenAuthState {}

// Mock Supabase client (for repo tests)
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQuery extends Mock implements PostgrestQueryBuilder {}
class MockSupabaseFilter extends Mock implements PostgrestFilterBuilder {}
```

For bloc tests: mock use cases, NOT the Supabase client.
For repo tests: mock the global `supabase` variable (use `setUp`/`tearDown` to replace).

### 4.3 Key Test Scenarios

#### AuthBloc (`test/bloc/auth_bloc_test.dart`)
```dart
group('AuthBloc', () {
  test('initial state is AuthInitial', () { /* ... */ });

  blocTest('emits [Loading, Authenticated] when LoginRequested succeeds', /* ... */);
  blocTest('emits [Loading, Error] when LoginRequested fails', /* ... */);
  blocTest('emits [Loading, Authenticated] when RegisterRequested succeeds', /* ... */);
  blocTest('emits [Loading, Error] when RegisterRequested fails', /* ... */);
  blocTest('emits [Loading, Unauthenticated] when LogoutRequested succeeds', /* ... */);
  blocTest('emits [Loading, Unauthenticated] when CheckAuthSession finds user', /* ... */);
  blocTest('emits [Loading, Unauthenticated] when CheckAuthSession finds no user', /* ... */);
});
```

#### ProfileBloc (`test/bloc/profile_bloc_test.dart`)
```dart
group('ProfileBloc', () {
  test('initial state is ProfileInitial', () { /* ... */ });

  blocTest('emits [Loading, Loaded] when LoadProfile succeeds', /* ... */);
  blocTest('emits [Loading, Error] when LoadProfile fails', /* ... */);
  blocTest('emits [Saving, Loaded] when UpdateProfile succeeds', /* ... */);
  blocTest('emits [Saving, Error] when UpdateProfile fails', /* ... */);
  blocTest('emits [Saving, Loaded] when ChangePassword succeeds', /* ... */);
  blocTest('emits [Saving, Error] when ChangePassword fails', /* ... */);
});
```

#### LabelBloc (`test/bloc/label_bloc_test.dart`)
```dart
group('LabelBloc', () {
  test('initial state is LabelInitial', () { /* ... */ });

  blocTest('emits [Loading, Loaded] when LoadLabels succeeds', /* ... */);
  blocTest('emits [Loading, Error] when LoadLabels fails', /* ... */);
  blocTest('emits [Loaded] when CreateLabelEvent succeeds', /* ... */);
  blocTest('emits [Error] when CreateLabelEvent fails', /* ... */);
  blocTest('emits [Loaded] when AssignLabelEvent succeeds', /* ... */);
  blocTest('emits [Loaded] when RemoveLabelEvent succeeds', /* ... */);
  blocTest('emits [Error] when AssignLabelEvent fails', /* ... */);
  blocTest('emits [Error] when RemoveLabelEvent fails', /* ... */);
});
```

#### AdminBloc (`test/bloc/admin_bloc_test.dart`)
```dart
group('AdminBloc', () {
  test('initial state is AdminInitial', () { /* ... */ });

  blocTest('emits [Loading, Loaded] when LoadAdminBooks succeeds', /* ... */);
  blocTest('emits [Loading, Error] when LoadAdminBooks fails', /* ... */);
  blocTest('emits [Loaded] when ToggleBookVisibility succeeds', /* ... */);
});
```

#### ChapterBloc (`test/bloc/chapter_bloc_test.dart`)
```dart
group('ChapterBloc', () {
  test('initial state is ChapterInitial', () { /* ... */ });

  blocTest('emits [Loading, Loaded] when LoadChapterContent succeeds', /* ... */);
  blocTest('emits [Loading, Error] when LoadChapterContent fails', /* ... */);
});
```

---

## Phase 5 — UI/UX

### 5.1 Immersive Mode Relocation

**Remove from** `lib/main.dart` line 17:
```dart
// Before:
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

// After: removed
```

**Add to** `lib/features/presentation/screens/chapter/chapter_screen.dart`:

```dart
import 'package:flutter/services.dart';

@override
void initState() {
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // ... rest of initState
}

@override
void dispose() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);  // restore
  // ... rest of dispose
}
```

### 5.2 Remove Cupertino Icons

**File:** `pubspec.yaml`

```yaml
# Remove line 14:
cupertino_icons: ^1.0.8
```

---

## Migration Ordering & Dependency Graph

```
Phase 1 (DB migration) ──► Phase 3 (bug fixes, depends on schema)
       │
       ▼
Phase 2 (DTOs, refactors) ──► Phase 4 (tests, depends on code)
       │
       ▼
Phase 5 (UI/UX, independent)
```

**Parallel runnable:**
- Phase 1 + Phase 5 can run in parallel (DB vs UI)
- Phase 2 DTO creation can start before Phase 1 finishes (code-only)

**Sequential required:**
- Phase 3.2 (column mapping) requires Phase 1 migration first
- Phase 4 requires Phase 2 + Phase 3 code changes first

**Recommended batch order for apply:**
1. Batch A: Phase 1 (DB migration + config + git)
2. Batch B: Phase 5 (UI/UX — independent)
3. Batch C: Phase 2 (DTOs + refactors) + Phase 3.1, 3.3-3.7 (non-DB bug fixes)
4. Batch D: Phase 3.2 (column mapping — depends on Phase 1 migration)
5. Batch E: Phase 4 (tests — depends on everything above)

### Rollback Steps

**Phase 1 (DB):**
```sql
DROP POLICY IF EXISTS "Enable insert for admin only" ON books;
DROP POLICY IF EXISTS "Enable update for admin only" ON books;
DROP POLICY IF EXISTS "Enable delete for admin only" ON books;
-- ... repeat for all content tables
ALTER TABLE genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE books_genres DISABLE ROW LEVEL SECURITY;
ALTER TABLE authors DISABLE ROW LEVEL SECURITY;
```

**Phase 1 (Config):** Restore original values in config.toml.

**Phase 1 (Git):** `git reflog` + `git reset` (filter-repo is destructive — restore from backup).

**Phase 2 (DTOs):** Remove DTO files, restore `_mapTo*Entity` methods in repos.

**Phase 2 (Bloc):** Revert imports and DI changes.

**Phase 3 (Bug fixes):** `git revert` individual commits.

**Phase 4 (Tests):** Delete test files.

**Phase 5 (UI):** Restore immersive mode to main.dart, add Cupertino icons back.
