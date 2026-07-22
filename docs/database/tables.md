# Tables & Schema

> All 11 tables have RLS enabled.
> Last audit: 2026-07-20

## Entity Relationship

```text
auth.users ──1:1──> profiles
    │
    ├──1:N──> books (created_by)
    │           ├──1:N──> books_genres ──> genres
    │           ├──1:N──> books_labels ──> labels
    │           ├──1:N──> tooks (book_id)
    │           │           └──1:N──> chapters (took_id)
    │           │                           └──1:N──> chapter_reads (chapter_id)
    │           ├──1:N──> book_views (book_id)
    │           └──1:N──> user_favorites (book_id)
    │
    ├──1:N──> tooks (created_by)
    ├──1:N──> chapters (created_by)
    │           └──1:N──> chapter_reads (chapter_id)
    ├──1:N──> user_favorites (user_id)
    └──1:N──> chapter_reads (user_id)

authors ──1:N──> books (author_id)
genres ──M:N──> books (via books_genres)
labels ──M:N──> books (via books_labels)
```text

---

## Table: `profiles`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | UUID | NO | — | FK → auth.users(id), PK |
| `role` | TEXT | NO | `'user'` | CHECK: user/scan/admin/suspended |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `display_name` | TEXT | YES | — | |
| `bio` | TEXT | YES | — | |
| `avatar_url` | TEXT | YES | — | |

### Code Mapping

| Layer | File | Purpose |
| ------- | ------ | --------- |
| E | user_entity.dart | isUser,isScan,isAdmin,isSuspended |
| Model | `user_model.dart` | JSON mapping, `_validateRole()` |
| Repo | profiles_repository.dart | Abstract: getProfile,getAllProfiles,... |
| Repo Impl | profiles_repository_impl.dart | Supabase calls + avatars storage |
| Use Cases | `update_user_role.dart` | Admin changes user role |
| BLoC | `profile_bloc.dart` | Profile state management |
| BLoC | admin_users_bloc.dart | Admin user management (role changes,suspend) |
| Screen | `profile_screen.dart` | User profile view/edit |
| Screen | `users_tab.dart` | Admin user list with search,role dialog,suspend |
| Screen | `register_screen.dart` | Auto-creates profile via trigger |
| Auth | `auth_repository_impl.dart` | `_getProfile()` reads/creates profile |
| DI | ``profiles`` | Registers ProfilesRepository, UpdateUserRole |
| Migration | `20260515161849_profiles_and_auth.sql` | Creates profiles table |
| Migration | add_suspended_role.sql | Adds 'suspended' to CHECK constraint |
| SQL Function | `handle_new_user()` | Trigger: auto-create profile on signup |

### Required Policies

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | User (own) | User reads own profile |
| SELECT | Admin (all) | Admin manages users |
| SELECT | Scan (all) | Scan needs to see author names |
| INSERT | User (own) | Trigger creates profile, user can update |
| UPDATE | User (own) | User edits display_name, bio, avatar |
| UPDATE | Admin (all) | Admin changes roles, suspends users |

---

## Table: `books`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `cover` | TEXT | NO | — | Storage URL |
| `name` | TEXT | NO | — | Book title |
| `short` | TEXT | YES | `''` | Short description |
| `alternative` | TEXT | YES | `''` | Alternative title |
| `description` | TEXT | YES | `''` | Full description |
| `country` | TEXT | YES | `''` | Country of origin |
| `state` | TEXT | YES | `''` | State/region |
| `type` | TEXT | YES | `''` | Book type |
| `release` | TEXT | YES | `''` | Release info |
| `source` | TEXT | YES | `''` | Source URL |
| `link` | TEXT | YES | `''` | External link |
| `is_favorite` | BOOL | YES | `false` | Legacy — use user_favorites |
| `author_id` | INT | NO | — | FK → authors(id) |
| `created_by` | UUID | YES | — | FK → auth.users(id) |
| `is_visible` | BOOL | NO | `true` | Visibility flag |
| `took_count` | INT | YES | `0` | Denormalized count |
| `chapter_count` | INT | YES | `0` | Denormalized count |

### Code Mapping (Part 2)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `book_entity.dart` | `BookEntity` domain model |
| Model | `book_model.dart` | JSON mapping with `BookWithRelations` |
| Repo | book_repository.dart | Abstract: getBooks,getBookById,... (9 methods) |
| Repo Impl | book_repository_impl.dart | Supabase calls, cleanup, joins |
| Use Cases | `lib/features/books/domain/get_book.dart` | `GetBook` use case |
| Use Cases | track_book_view.dart | TrackBookView use case (fire-and-forget) |
| BLoC | `book_bloc.dart` | `LoadBooks`, `LoadMoreBooks` (infinite scroll) |
| BLoC | `admin_bloc.dart` | Admin CRUD + visibility toggle |
| BLoC | `scan_book_bloc.dart` | Scan create/update/delete |
| BLoC | `admin_analytics_bloc.dart` | Reads book_views via RPC |
| Screen | `main_screen.dart` | Book list (user view) |
| Screen | `book_screen.dart` | Book detail + tracking trigger |
| Screen | `books_tab.dart` | Admin book management |
| Screen | `analytics_tab.dart` | Analytics dashboard |
| Screen | `scan_main_screen.dart` | Scan book list |
| Screen | `scan_book_edit_screen.dart` | Scan create/edit book |
| DI | ``books`` | Registers BookRepository, TrackBookView, BookBloc |
| DI | `injection_admin.dart` | Registers AdminBloc, AnalyticsRepository |
| DI | `lib/core/di/injection_scan.dart` | Registers ScanBookBloc |
| Migration | `20260514220000_initial_schema.sql` | Creates books table |
| Migration | fix_books_rls_scan_visibility.sql | Scan visibility fix |

### Required Policies (Part 2)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | User (visible) | User reads published books |
| SELECT | Admin (all) | Admin manages all books |
| SELECT | Scan (own) | Scan reads own books for editing |
| INSERT | Admin | Admin creates books |
| INSERT | Scan (own) | Scan creates books |
| UPDATE | Admin | Admin edits any book |
| UPDATE | Scan (own) | Scan edits own books |
| DELETE | Admin | Admin deletes any book |
| DELETE | Scan (own) | Scan deletes own books |

---

## Table: `authors`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `name` | TEXT | NO | — | Author name |
| `description` | TEXT | YES | `''` | |

### Code Mapping (Part 3)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | Reads authors with relations |
| Screen | `genres_tab.dart` | Admin genre/author management |
| Migration | authors_and_constraints.sql | Creates authors table |

**Note**: No dedicated `AuthorRepository` — authors are managed through books
and genres tabs.

### Required Policies (Part 3)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Authors are public data |
| INSERT | Admin/Scan | Both can create authors |
| UPDATE | Admin/Scan | Both can edit authors |
| DELETE | Admin/Scan | Both can delete authors |

---

## Table: `genres`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | INT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `name` | TEXT | NO | — | Genre name |
| `description` | TEXT | YES | `''` | |

### Code Mapping (Part 4)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `genre_entity.dart` | `GenreEntity` domain model |
| Repo | genre_repository.dart | Abstract: getGenres,getGenreById,... |
| Repository Impl | `genre_repository_impl.dart` | Supabase calls |
| BLoC | `genre_bloc.dart` | Genre state management |
| Cubit | `genre_cubit.dart` | Shared genre loading (scan) |
| Screen | `genre_screen.dart` | Genre list |
| Screen | `genres_tab.dart` | Admin genre CRUD |
| Screen | `main_screen.dart` | Genre filter chips |
| DI | `injection_genres.dart` | Registers GenreRepository, GenreBloc |
| DI | `lib/core/di/injection_scan.dart` | Registers GenreCubit |
| Migration | `20260514220000_initial_schema.sql` | Creates genres table |

### Required Policies (Part 4)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Genres are public data |
| INSERT | Admin/Scan | Both can create genres |
| UPDATE | Admin/Scan | Both can edit genres |
| DELETE | Admin/Scan | Both can delete genres |

---

## Table: `labels`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | BIGINT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `name` | TEXT | NO | — | Label name |
| `color` | TEXT | NO | `'#71A202'` | Hex color |

### Code Mapping (Part 5)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `label_entity.dart` | `LabelEntity` domain model |
| Repo | label_repository.dart | Abstract: getLabels,getLabelById,... |
| Repo Impl | label_repository_impl.dart | Supabase calls for labels |
| BLoC | `label_bloc.dart` | Label state management |
| Screen | `genres_tab.dart` | Admin label CRUD (shared tab) |
| Screen | `scan_book_edit_screen.dart` | Scan assigns labels to books |
| DI | `injection_labels.dart` | Registers LabelRepository, LabelBloc |
| Migration | `20260520020000_labels.sql` | Creates labels table |

### Required Policies (Part 5)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Labels are public data |
| INSERT | Admin/Scan | Both can create labels |
| UPDATE | Admin/Scan | Both can edit labels |
| DELETE | Admin/Scan | Both can delete labels |

---

## Table: `books_genres` (M:N junction)

| Column | Type | Nullable | Notes |
| -------- | ------ | ---------- | ------- |
| `book_id` | INT | NO | FK → books(id) |
| `genre_id` | INT | NO | FK → genres(id) |

**PK**: (book_id, genre_id)

### Code Mapping (Part 6)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | Insert/delete on create/update books |
| Migration | `20260514220000_initial_schema.sql` | Creates junction table |

### Required Policies (Part 6)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Junction data is public |
| INSERT | Admin/Scan | Both assign genres to books |
| DELETE | Admin/Scan | Both remove genres from books |

---

## Table: `books_labels` (M:N junction)

| Column | Type | Nullable | Notes |
| -------- | ------ | ---------- | ------- |
| `book_id` | INT | NO | FK → books(id) |
| `label_id` | BIGINT | NO | FK → labels(id) |

**PK**: (book_id, label_id)

### Code Mapping (Part 7)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | Read labels for books |
| Repo Impl | `label_repository_impl.dart` | Assign/remove labels from books |
| Migration | `20260520020000_labels.sql` | Creates junction table |

### Required Policies (Part 7)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Junction data is public |
| INSERT | Admin/Scan | Both assign labels to books |
| DELETE | Admin/Scan | Both remove labels from books |

---

## Table: `tooks`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `book_id` | INT | NO | — | FK → books(id) |
| `cover` | TEXT | YES | `''` | Storage URL |
| `number` | TEXT | YES | `''` | Took number |
| `title` | TEXT | YES | `''` | Took title |
| `created_by` | UUID | YES | — | FK → auth.users(id) |
| `chapter_count` | INT | YES | `0` | Denormalized count |

### Code Mapping (Part 8)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `took_entity.dart` | `TookEntity` domain model |
| Repo | took_repository.dart | Abstract: getTooks,getTookById,... |
| Repository Impl | `took_repository_impl.dart` | Supabase calls |
| BLoC | `chapter_bloc.dart` | Manages tooks + chapters |
| BLoC | `scan_took_bloc.dart` | Scan CRUD for tooks |
| Screen | `book_screen.dart` | Shows tooks list in "Took" tab |
| Screen | `scan_took_edit_screen.dart` | Scan create/edit took |
| DI | `lib/core/di/injection_tooks.dart` | Registers TookRepository |
| DI | `lib/core/di/injection_scan.dart` | Registers ScanTookBloc |
| Migration | `20260514220000_initial_schema.sql` | Creates tooks table |

### Required Policies (Part 8)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Took metadata is public |
| INSERT | Admin/Scan (own) | Scan creates tooks |
| UPDATE | Admin/Scan (own) | Scan edits own tooks |
| DELETE | Admin/Scan (own) | Scan deletes own tooks |

---

## Table: `chapters`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | YES | `now()` | |
| `took_id` | INT | NO | — | FK → tooks(id) |
| `number` | TEXT | YES | `''` | Chapter number |
| `title` | TEXT | YES | `''` | Chapter title |
| `content` | TEXT | YES | `''` | Chapter content |
| `created_by` | UUID | YES | — | FK → auth.users(id) |

### Code Mapping (Part 9)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `chapter_entity.dart` | `ChapterEntity` domain model |
| Repo | chapter_repository.dart | Abstract: getChapters,getChapterById,... |
| Repository Impl | `chapter_repository_impl.dart` | Supabase calls |
| BLoC | `chapter_bloc.dart` | Chapter state management |
| BLoC | `scan_chapter_bloc.dart` | Scan CRUD for chapters |
| Screen | `chapter_screen.dart` | Chapter reader |
| Screen | `scan_chapter_edit_screen.dart` | Scan create/edit chapter |
| DI | `injection_chapters.dart` | Registers ChapterRepository, ChapterBloc |
| DI | `lib/core/di/injection_scan.dart` | Registers ScanChapterBloc |
| Migration | `20260514220000_initial_schema.sql` | Creates chapters table |

### Required Policies (Part 9)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | All | Chapter content is public |
| INSERT | Admin/Scan (own) | Scan creates chapters |
| UPDATE | Admin/Scan (own) | Scan edits own chapters |
| DELETE | Admin/Scan (own) | Scan deletes own chapters |

---

## Table: `book_views`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `id` | BIGINT | NO | identity | PK |
| `book_id` | BIGINT | NO | — | FK → books(id) CASCADE |
| `viewed_at` | TIMESTAMPTZ | NO | `now()` | |
| `user_id` | UUID | YES | — | FK → auth.users(id) SET NULL |

### Code Mapping (Part 10)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | INSERT into book_views |
| Use Case | track_book_view.dart | TrackBookView — fire-and-forget |
| Screen | book_screen.dart | Calls TrackBookView in initState() |
| Repo Impl | `analytics_repository_impl.dart` | Reads via RPC functions |
| BLoC | `admin_analytics_bloc.dart` | Loads analytics data |
| Screen | `analytics_tab.dart` | Displays analytics dashboard |
| DI | `lib/core/di/injection_books.dart` | Registers TrackBookView |
| DI | `lib/core/di/injection_admin.dart` | Registers AnalyticsRepository |
| Migration | `20260523000000_admin_panels.sql` | Creates book_views table |
| Migration | audit_fixes_v2.sql | Adds user_id, relaxes INSERT policy |
| Migration | create_analytics_functions.sql | Creates analytics SQL funct... |
| SQL Functions | get_views_trend(),... | Analytics queries |

### Required Policies (Part 10)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | Admin | Only admin views analytics |
| INSERT | Any authenticated | Any user tracking a view |

---

## Table: `chapter_reads`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `user_id` | UUID | NO | — | FK → auth.users(id) |
| `chapter_id` | INTEGER | NO | — | FK → chapters(id) |
| `read_at` | TIMESTAMPTZ | NO | `now()` | When the chapter was read |

**PK**: (user_id, chapter_id)

**RLS**: Enabled — users SELECT/INSERT own rows only.

### Code Mapping

| Layer | File | Purpose |
|-------|------|---------|
| N/A (DB only) | — | No domain entity; tracked via repository methods |
| Repo | `chapter_repository.dart` | `markChapterAsRead`, `getReadChapterIds` |
| Use Cases | `mark_chapter_as_read.dart`, `get_read_chapter_ids.dart` | Delegates to repository |
| Migration | `20260722000000_chapter_reads.sql` | Creates chapter_reads table |

### Required Policies

| Operation | Role | Why |
|-----------|------|-----|
| SELECT | User (own) | User sees own reading progress |
| INSERT | User (own) | User marks chapters as read |

---

## Table: `user_favorites`

| Column | Type | Nullable | Default | Notes |
| -------- | ------ | ---------- | --------- | ------- |
| `user_id` | UUID | NO | — | FK → auth.users(id) CASCADE |
| `book_id` | INT | NO | — | FK → books(id) CASCADE |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**PK**: (user_id, book_id)

### Code Mapping (Part 11)

| Layer | File | Purpose |
| ------- | ------ | --------- |
| Entity | `favorite_entity.dart` | `FavoriteEntity` domain model |
| Repo | favorite_repository.dart | Abstract: getFavorites,isFavorite,... |
| Repository Impl | `favorite_repository_impl.dart` | Supabase calls |
| BLoC | `favorite_bloc.dart` | Favorite state management |
| Screen | `detail_view.dart` | FavoriteButton widget |
| DI | ``favorites`` | Registers FavoriteRepository, FavoriteBloc |
| Migration | create_user_favorites.sql | Creates user_favorites table |

### Required Policies (Part 11)

| Operation | Role | Why |
| ----------- | ------ | ----- |
| SELECT | User (own) | User sees own favorites |
| INSERT | User (own) | User adds favorites |
| DELETE | User (own) | User removes favorites |

---

## Summary: Policy Requirements by Role

### Admin

- **profiles**: SELECT all, UPDATE all (role changes)
- **books**: Full CRUD all
- **authors**: Full CRUD
- **genres**: Full CRUD
- **labels**: Full CRUD
- **books_genres**: Full CRUD
- **books_labels**: Full CRUD
- **tooks**: Full CRUD
- **chapters**: Full CRUD
- **book_views**: SELECT only (analytics)
- **user_favorites**: No access (user-only)
- **chapter_reads**: No access (admin-only is user responsibility)

### Scan

- **profiles**: SELECT all (author names)
- **books**: CRUD own (created_by = auth.uid())
- **authors**: Full CRUD (shared resource)
- **genres**: Full CRUD (shared resource)
- **labels**: Full CRUD (shared resource)
- **books_genres**: Full CRUD
- **books_labels**: Full CRUD
- **tooks**: CRUD own (created_by = auth.uid())
- **chapters**: CRUD own (created_by = auth.uid())
- **book_views**: INSERT only (tracking)
- **user_favorites**: No access (user-only)
- **chapter_reads**: No access (scan-only is user responsibility)

### User

- **profiles**: SELECT/UPDATE own
- **books**: SELECT visible only
- **authors**: SELECT only
- **genres**: SELECT only
- **labels**: SELECT only
- **books_genres**: SELECT only
- **books_labels**: SELECT only
- **tooks**: SELECT only
- **chapters**: SELECT only
- **book_views**: INSERT only (tracking)
- **user_favorites**: Full CRUD own
- **chapter_reads**: Full CRUD own

### Suspended

- **All tables**: No access (blocked at app routing level, not RLS)
