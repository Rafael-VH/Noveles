# Proposal: Admin Panel Improvements

## Intent

The admin role (`role = 'admin'`) has full RLS write permissions on all tables, but the admin UI only shows books with a visibility toggle. This change adds genre management, user management, and analytics infrastructure so admins can actually use their database-level permissions.

## Scope

### In Scope

- **Genre management panel** — Add, edit, delete genres (admin-only CRUD screen)
- **User management panel** — List all profiles with role display, no role editing (read-only)
- **Book delete** — Add delete button per book in existing admin book list
- **Analytics DB table** — Create `book_views` table + RLS + migration
- **Admin navigation** — Reorganize AdminMainScreen into a hub with sub-sections

### Out of Scope

- Create or edit novels (admin cannot create/upload content — per user request)
- Upload chapters or covers
- Edit user roles (read-only user listing only)
- Full analytics dashboard UI (only DB infrastructure + placeholder; UI is future-ready)
- Scan role UI changes

## Capabilities

| Capability | Type | Description |
|---|---|---|
| `genre-management` | New | Admin-only CRUD screen for genres |
| `user-management` | New | Read-only list of all registered profiles |
| `analytics-dashboard` | New | `book_views` table + RLS + migration (UI skeleton only) |

## Approach

### Phase 1: Database
- Create `supabase/migrations/20260523000000_admin_panel.sql` with:
  - `book_views` table (book_id FK, viewed_at timestamptz, user_id UUID nullable)
  - RLS: SELECT for admin only, INSERT for authenticated users
  - Index on `book_views(book_id, viewed_at)`

### Phase 2: Data Layer
- Add `GetAllProfiles` use case + `getAllProfiles()` on `ProfilesRepository` + impl
- Wire new use cases in DI

### Phase 3: Admin Genre Management UI
- Create `AdminGenreBloc` (load, create, update, delete events) — reuse existing `GenreRepository`
- Create `AdminGenreScreen` — list genres with add/edit/delete actions
- Use existing `CreateGenre`, `UpdateGenre`, `DeleteGenre` use cases already registered in DI

### Phase 4: Admin User Management UI
- Create `AdminUserBloc` — `LoadUsers` event, `AdminUserLoaded` state with user list
- Create `AdminUserScreen` — profile list displaying id, email, display_name, role

### Phase 5: Admin Navigation + Book Delete
- Refactor `AdminMainScreen` to hub layout with navigation cards
- Add "Delete" button per book in existing book list (confirmation dialog)
- Add `DeleteBookUseCase` + wire to `AdminBloc`

### Phase 6: Analytics Skeleton
- Create `AnalyticsBloc` stub
- Create `AnalyticsScreen` placeholder with filtered view selector (day/week/month/6m/year)

## Affected Areas

- `supabase/migrations/20260523000000_admin_panel.sql` (new)
- `lib/features/domain/repositories/profiles_repository.dart`
- `lib/features/data/repositories/profiles_repository_impl.dart`
- `lib/features/domain/use_cases/get_all_profiles.dart` (new)
- `lib/features/domain/use_cases/delete_book_admin.dart` (new)
- `lib/features/domain/entities/entities.dart` (no change needed)
- `lib/features/domain/repositories/book_repository.dart` (add `deleteBook`)
- `lib/features/data/repositories/book_repository_impl.dart`
- `lib/core/di/injection.dart`
- `lib/features/presentation/bloc/admin/admin_bloc.dart`
- `lib/features/presentation/bloc/admin/admin_event.dart`
- `lib/features/presentation/bloc/admin/admin_state.dart`
- `lib/features/presentation/bloc/admin_genre/` (new — bloc, event, state)
- `lib/features/presentation/bloc/admin_user/` (new — bloc, event, state)
- `lib/features/presentation/bloc/analytics/` (new — bloc, event, state, skeleton)
- `lib/features/presentation/screens/admin/admin_main_screen.dart`
- `lib/features/presentation/screens/admin/admin_genre_screen.dart` (new)
- `lib/features/presentation/screens/admin/admin_user_screen.dart` (new)
- `lib/features/presentation/screens/admin/analytics_screen.dart` (new)
- `lib/features/presentation/screens/screens.dart`
- `lib/features/presentation/bloc/bloc.dart`

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| GenreBloc already exists (read-only) — confusion with new admin genre bloc | High | Medium | Name new bloc `AdminGenreBloc` to avoid shadowing; keep existing `GenreBloc` for user-facing screens |
| Profiles table may have no email column (stored in auth.users, not profiles) | Medium | High | Query profiles + join auth.users or use profiles table fields only; verify schema before implementing |
| Book delete cascades to tooks/chapters — accidental data loss | Medium | High | Add confirmation dialog with warning text; use RLS as safety net |
| Analytics query performance on large `book_views` | Low | Medium | Add composite index; paginate queries from day 1 |

## Rollback Plan

1. Revert migration: `supabase migration down 20260523000000` (or manual DROP book_views)
2. Revert all new files: `git rm` each new file under blocs/screens/use_cases
3. Revert modified files: `git checkout HEAD -- <file>` for admin_main_screen, DI, repos
4. Verify: admin panel returns to book-list-only state

## Dependencies

None.

## Success Criteria

- [ ] Admin can add, edit, and delete genres from a dedicated screen
- [ ] Admin can view all registered user profiles (id, email, display_name, role)
- [ ] Admin can delete books from the book list with confirmation dialog
- [ ] `book_views` table exists with RLS and FK index
- [ ] Analytics screen renders with view selector (data is placeholder)
- [ ] Admin navigation shows all 4 sub-sections (Books, Genres, Users, Analytics)
- [ ] Existing user-facing genre screens and blocs continue to work unchanged
