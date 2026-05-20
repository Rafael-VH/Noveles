# Technical Design: Admin Panel Improvements

## 1. Technical Approach

Transform `AdminMainScreen` into a **tabbed hub** with 4 tabs (Books, Genres, Users, Analytics skeleton). Each feature uses its own BLoC, following existing Clean Architecture. Genre management extends the existing `GenreBloc` with CRUD events. User management introduces a new `AdminUsersBloc` + `GetAllProfiles` use case. Book delete wires the existing `DeleteBook` use case into `AdminBloc`. Analytics ships migration + skeleton card only.

## 2. Architecture Decisions

| # | Decision | Choice | Alternatives | Rationale |
|---|----------|--------|--------------|-----------|
| 1 | Admin navigation | BottomNavigationBar (4 tabs) | Nested ListView → push screens | Tabs are faster for switching; single screen context; matches mobile patterns |
| 2 | Genre CRUD approach | Extend `GenreBloc` with create/update/delete events | New `AdminGenreBloc` | GenreBloc is barely used outside admin; avoids parallel blocs; LabelBloc already follows this pattern |
| 3 | User list approach | New `AdminUsersBloc` + `GetAllProfiles` use case | Merge into AdminBloc / inline RPC call | AdminBloc is already book-focused; god bloc anti-pattern; clear separation |
| 4 | Book delete | Wire existing `DeleteBook` use case into `AdminBloc` | New AdminBookBloc | Single new event + handler; no structural complexity; `DeleteBook` already exists |

## 3. Data Flow

**Genre CRUD**: User → GenreTab → GenreBloc(LoadGenres/CreateGenre/UpdateGenre/DeleteGenre) → GenreRepository → Supabase `genres` table → re-emit GenreLoaded

**User list**: Admin → UsersTab → AdminUsersBloc(LoadUsers) → GetAllProfiles → ProfilesRepository.getAllProfiles() → Supabase `profiles` table (RLS: admin only)

**Book delete**: Admin → BooksTab → AdminBloc(DeleteAdminBook) → DeleteBook → BookRepository.deleteBook() → Supabase cascading delete → re-emit AdminLoaded

**Analytics**: Skeleton card in AnalyticsTab — no data flow until future UI

## 4. File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/features/presentation/screens/admin/admin_main_screen.dart` | MODIFY | Convert to tabbed hub with BottomNavigationBar (Books/Genres/Users/Analytics). Add delete button + confirm dialog per book |
| `lib/features/presentation/bloc/admin/admin_event.dart` | MODIFY | Add `DeleteAdminBook(int bookId)` event |
| `lib/features/presentation/bloc/admin/admin_bloc.dart` | MODIFY | Inject `DeleteBook` use case; handle `DeleteAdminBook` — delete, reload, emit success msg |
| `lib/features/presentation/bloc/admin/admin_state.dart` | — | No changes needed (AdminLoaded.message covers success) |
| `lib/features/presentation/bloc/genre/genre_event.dart` | MODIFY | Add `CreateGenreEvent(GenreEntity)`, `UpdateGenreEvent(GenreEntity)`, `DeleteGenreEvent(int id)` |
| `lib/features/presentation/bloc/genre/genre_bloc.dart` | MODIFY | Inject `CreateGenre`, `UpdateGenre`, `DeleteGenre`; add 3 event handlers; re-emit `GenreLoaded` after each mutation |
| `lib/features/presentation/bloc/genre/genre_state.dart` | — | No changes needed |
| `lib/features/presentation/bloc/bloc.dart` | MODIFY | Export `admin_users_bloc.dart`, `admin_users_event.dart`, `admin_users_state.dart` |
| `lib/features/presentation/bloc/admin_users/admin_users_bloc.dart` | CREATE | New BLoC: inject `GetAllProfiles`, handle `LoadAdminUsers`, emit `AdminUsersLoading/Loaded/Error` |
| `lib/features/presentation/bloc/admin_users/admin_users_event.dart` | CREATE | `LoadAdminUsers` event |
| `lib/features/presentation/bloc/admin_users/admin_users_state.dart` | CREATE | `AdminUsersInitial`, `AdminUsersLoading`, `AdminUsersLoaded(List<UserEntity>)`, `AdminUsersError(message)` |
| `lib/features/domain/repositories/profiles_repository.dart` | MODIFY | Add `Future<List<UserEntity>> getAllProfiles()` |
| `lib/features/data/repositories/profiles_repository_impl.dart` | MODIFY | Implement `getAllProfiles` — `supabase.from('profiles').select('*').order('email')` |
| `lib/features/domain/use_cases/get_all_profiles.dart` | CREATE | Single-call use case wrapping `repository.getAllProfiles()` |
| `lib/features/domain/use_cases/use_cases.dart` | MODIFY | Export `get_all_profiles.dart` |
| `lib/core/di/injection.dart` | MODIFY | Register `GetAllProfiles` + `AdminUsersBloc`; add `DeleteGenre`, `CreateGenre`, `UpdateGenre` to `GenreBloc` factory |
| `lib/features/presentation/widgets/app_drawer.dart` | MODIFY | Ensure single "Panel Admin" drawer item navigates to admin hub |
| `lib/features/presentation/screens/screens.dart` | — | Admin screen already exported; no new screen files need export because tabs are inline widgets |
| `supabase/migrations/20260523000000_admin_analytics.sql` | CREATE | `book_views` table, RLS, indexes |

## 5. Interfaces / Contracts

### ProfilesRepository (new method)
```dart
Future<List<UserEntity>> getAllProfiles();
```

### AdminUsersBloc
```dart
class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  AdminUsersBloc({required GetAllProfiles getAllProfiles}) ...
}
```

### AdminBloc (updated DI)
```dart
// Add: DeleteBook deleteBook to constructor
// Add: on<DeleteAdminBook>(_onDeleteBook) in init
```

### GenreBloc (updated DI)
```dart
// Add: CreateGenre createGenre, UpdateGenre updateGenre, DeleteGenre deleteGenre
// Add: on<CreateGenreEvent>(_onCreateGenre), etc.
```

## 6. Testing Strategy

| Area | What to test | How |
|------|-------------|-----|
| AdminBloc + DeleteBook | DeleteAdminBook event → repository.deleteBook called, books reloaded | Unit test with mock repository |
| GenreBloc CRUD | CreateGenreEvent, UpdateGenreEvent, DeleteGenreEvent → state transitions | Unit test with mock use cases |
| AdminUsersBloc | LoadAdminUsers → success/error states | Unit test with mock GetAllProfiles |
| ProfilesRepository.getAllProfiles | Returns all profiles, throws on error | Integration test with local Supabase or mock client |
| AdminMainScreen | Tabs render, delete confirm dialog appears, genre dialog CRUD | Widget test with BlocProvider + mock states |

## 7. Migration

```sql
-- 20260523000000_admin_analytics.sql
CREATE TABLE IF NOT EXISTS book_views (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  viewed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE book_views ENABLE ROW LEVEL SECURITY;

-- Admin write
CREATE POLICY "Admin write book_views"
  ON book_views FOR INSERT
  WITH CHECK (public.is_admin());

-- Authenticated read (for future analytics UI)
CREATE POLICY "Authenticated read book_views"
  ON book_views FOR SELECT
  USING (auth.role() = 'authenticated');

-- Aggregation indexes
CREATE INDEX idx_book_views_viewed_at ON book_views(viewed_at);
CREATE INDEX idx_book_views_book_id ON book_views(book_id);
CREATE INDEX idx_book_views_user_id ON book_views(user_id);
```

## 8. Open Questions

- Should genre management be inline in the tab or a pushed screen (like LabelManagementScreen)? Inline tab chosen for unified UX, but could switch to push if the tab gets too complex.
- Should we cascade-delete genres or prevent deletion when genre is in use? The current `deleteGenre` in the impl does a raw DELETE — there's no FK from `books_genres.genre_id` → `genres.id` with CASCADE in the schema, so genre deletion may fail if referenced. This needs investigation.
- The analytics card is purely skeleton — what specific metrics should it display when implemented? (Left for future design.)
