# Tasks: Admin Panel Improvements

## Change
`admin-panel-improvements`

## Breakdown

| Phase | Tasks | Focus |
|-------|-------|-------|
| 1 — Database | 1 ✅ | Migration: `book_views` table + RLS + indexes |
| 2 — Data / Domain | 3 ✅ | ProfilesRepository.getAllProfiles() + impl + GetAllProfiles use case |
| 3 — BLoC Layer | 8 ✅ | Genre CRUD events + handlers; AdminBloc DeleteAdminBook; AdminUsersBloc triplet |
| 4 — UI Layer | 3 ✅ | AdminMainScreen tab hub; AppDrawer nav; genre inline CRUD UI |
| 5 — DI / Wiring | 3 ✅ | injection.dart refactors; barrel exports for bloc + use_cases |
| 6 — Testing | 4 ✅ | GenreBloc CRUD, AdminBloc DeleteBook, AdminUsersBloc, ProfilesRepository.getAllProfiles |
| **Total** | **22** ✅ | **All tasks complete** |

---

## Phase 1 — Database

### T1: ✅ Create migration `20260523000000_admin_analytics.sql`
- **File**: `supabase/migrations/20260523000000_admin_analytics.sql` (CREATE)
- **Action**: Write SQL migration creating `book_views` table with columns: `id BIGINT GENERATED ALWAYS AS IDENTITY PK`, `book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE`, `user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL`, `viewed_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- **Action**: Enable RLS on `book_views`
- **Action**: Create RLS policy "Admin write book_views" — `FOR INSERT WITH CHECK (public.is_admin())`
- **Action**: Create RLS policy "Authenticated read book_views" — `FOR SELECT USING (auth.role() = 'authenticated')`
- **Action**: Create indexes: `idx_book_views_viewed_at`, `idx_book_views_book_id`, `idx_book_views_user_id`
- **Verification**: SQL file exists at path, contains all CREATE TABLE, ALTER, and CREATE INDEX statements; no syntax errors in SQL
- **Dependencies**: None

---

## Phase 2 — Data / Domain Layer

### T2: ✅ Add `getAllProfiles()` to `ProfilesRepository` interface
- **File**: `lib/features/domain/repositories/profiles_repository.dart` (MODIFY)
- **Action**: Add method signature: `Future<List<UserEntity>> getAllProfiles();`
- **Verification**: Interface compiles, no existing tests break
- **Dependencies**: None

### T3: ✅ Implement `getAllProfiles()` in `ProfilesRepositoryImpl`
- **File**: `lib/features/data/repositories/profiles_repository_impl.dart` (MODIFY)
- **Action**: Implement: `supabase.from('profiles').select('*').order('email')` mapped through `UserModel.fromJson` for each row
- **Action**: Wrap in try-catch, throw `RepositoryException` on failure
- **Verification**: Method exists, follows existing pattern (see `getProfile`), compiles
- **Dependencies**: T2

### T4: ✅ Create `GetAllProfiles` use case
- **File**: `lib/features/domain/use_cases/get_all_profiles.dart` (CREATE)
- **Action**: Single-call use case: `class GetAllProfiles { final ProfilesRepository repository; Future<List<UserEntity>> call() async => repository.getAllProfiles(); }`
- **Action**: Follow pattern of `GetProfile` (existing use case)
- **Verification**: File exists, implements the call pattern, compiles
- **Dependencies**: T2

---

## Phase 3 — BLoC Layer

### T5: ✅ Add CRUD events to `GenreEvent`
- **File**: `lib/features/presentation/bloc/genre/genre_event.dart` (MODIFY)
- **Action**: Add `CreateGenreEvent(GenreEntity genre)` — props: `[genre]`
- **Action**: Add `UpdateGenreEvent(GenreEntity genre)` — props: `[genre]`
- **Action**: Add `DeleteGenreEvent(int id)` — props: `[id]`
- **Verification**: File compiles, all 3 event classes extend `GenreEvent`
- **Dependencies**: None

### T6: ✅ Update `GenreBloc` constructor signature + add CRUD handlers
- **File**: `lib/features/presentation/bloc/genre/genre_bloc.dart` (MODIFY)
- **Action**: Change constructor to named params: `GenreBloc({required GetGenre getGenre, required CreateGenre createGenre, required UpdateGenre updateGenre, required DeleteGenre deleteGenre})`
- **Action**: Store all 4 use cases as private fields
- **Action**: Wire 3 new event handlers: `on<CreateGenreEvent>(_onCreateGenre)`, `on<UpdateGenreEvent>(_onUpdateGenre)`, `on<DeleteGenreEvent>(_onDeleteGenre)`
- **Action**: Implement `_onCreateGenre`: call `createGenre(event.genre)` → reload genres via `getGenre()` → emit `GenreLoaded(genres, message: 'Género creado')` on success, `GenreError` on failure
- **Action**: `_onUpdateGenre`: same pattern with message 'Género actualizado'
- **Action**: `_onDeleteGenre`: same pattern with message 'Género eliminado'
- **Verification**: Follow LabelBloc pattern (load after mutate, emit with message). All handlers handle success and error paths
- **Dependencies**: T5

### T7: ✅ Add `DeleteAdminBook` event to `AdminEvent`
- **File**: `lib/features/presentation/bloc/admin/admin_event.dart` (MODIFY)
- **Action**: Add `class DeleteAdminBook extends AdminEvent { final int bookId; const DeleteAdminBook(this.bookId); @override List<Object> get props => [bookId]; }`
- **Verification**: File compiles, event fits existing pattern
- **Dependencies**: None

### T8: ✅ Wire `DeleteBook` use case into `AdminBloc`
- **File**: `lib/features/presentation/bloc/admin/admin_bloc.dart` (MODIFY)
- **Action**: Add `DeleteBook deleteBook` to constructor (named param)
- **Action**: Wire `on<DeleteAdminBook>(_onDeleteBook)` in constructor
- **Action**: Implement `_onDeleteBook`: call `deleteBook(event.bookId)` → reload books → emit `AdminLoaded(books, message: 'Libro eliminado')` on success, `AdminError` on failure
- **Action**: Follow existing `_onToggleVisibility` pattern
- **Verification**: Handler compiles, success/error paths covered
- **Dependencies**: T7

### T9: ✅ Create `AdminUsersEvent`
- **File**: `lib/features/presentation/bloc/admin_users/admin_users_event.dart` (CREATE)
- **Action**: Abstract `AdminUsersEvent extends Equatable` with `List<Object> get props => []`
- **Action**: Single event: `class LoadAdminUsers extends AdminUsersEvent { const LoadAdminUsers(); }`
- **Verification**: File exists, pattern matches `AdminEvent`/`GenreEvent`
- **Dependencies**: None

### T10: ✅ Create `AdminUsersState`
- **File**: `lib/features/presentation/bloc/admin_users/admin_users_state.dart` (CREATE)
- **Action**: Abstract `AdminUsersState extends Equatable`
- **Action**: 4 states: `AdminUsersInitial()`, `AdminUsersLoading()`, `AdminUsersLoaded(List<UserEntity> users, {String? message})`, `AdminUsersError(String message)`
- **Action**: Match `AdminLoaded` pattern — `AdminUsersLoaded` has optional `message` field for success notifications
- **Verification**: File exists, states follow AdminState/GenreState patterns
- **Dependencies**: None

### T11: ✅ Create `AdminUsersBloc`
- **File**: `lib/features/presentation/bloc/admin_users/admin_users_bloc.dart` (CREATE)
- **Action**: `class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState>` with `GetAllProfiles` as constructor dep
- **Action**: Wire `on<LoadAdminUsers>(_onLoadUsers)` in constructor
- **Action**: Implement `_onLoadUsers`: emit `AdminUsersLoading()` → call `getAllProfiles()` → emit `AdminUsersLoaded(profiles)` on success, `AdminUsersError(e.toString())` on failure
- **Verification**: File exists, follows AdminBloc/GenreBloc patterns, compiles
- **Dependencies**: T4, T9, T10

---

## Phase 4 — UI Layer

### T12: Refactor `AdminMainScreen` into BottomNavigationBar hub
- **File**: `lib/features/presentation/screens/admin/admin_main_screen.dart` (MODIFY)
- **Action**: Convert from `StatelessWidget` to `StatefulWidget` with `_currentIndex` state (default 0)
- **Action**: Wrap body in `BottomNavigationBar` with 4 items: Books (Icons.library_books), Genres (Icons.category), Users (Icons.people), Analytics (Icons.analytics)
- **Action**: Create `_BooksTab()` — extract existing book list + stats card into this widget; add delete IconButton per book row (calls `DeleteAdminBook`)
- **Action**: Create `_GenresTab()` — uses `BlocProvider<GenreBloc>` tapped with all 4 use cases; shows genre list with add/edit/delete inline UI (dialog-based CRUD). Follow LabelManagementScreen approach for inline dialogs
- **Action**: Create `_UsersTab()` — uses `BlocProvider<AdminUsersBloc>`; shows user list in `ListView.builder` with email, displayName, role
- **Action**: Create `_AnalyticsTab()` — skeleton card with placeholder text
- **Action**: Each tab provides its own `BlocProvider` scoped to that tab's widget subtree
- **Action**: Ensure Books tab still shows AdminBloc snackbar messages (listener stays at parent level)
- **Verification**: Screen builds with 4 tabs, each tab renders its content correctly, navigation works
- **Dependencies**: T8, T11

### T13: Update `AppDrawer` navigation for admin hub
- **File**: `lib/features/presentation/widgets/app_drawer.dart` (MODIFY)
- **Action**: Ensure "Panel Admin" ListTile navigates to AdminMainScreen (when tapped from non-admin screens). Currently it just pops the drawer — verify navigation context works correctly or add explicit `Navigator.push`
- **Verification**: Tapping "Panel Admin" from any screen navigates to the tabbed admin hub
- **Dependencies**: T12 (AdminMainScreen exists and is the hub)

### T14: ✅ Update barrel exports — `bloc.dart`
- **File**: `lib/features/presentation/bloc/bloc.dart` (MODIFY)
- **Action**: Add 3 export lines for admin_users bloc: `export 'package:noveles/features/presentation/bloc/admin_users/admin_users_bloc.dart';`, `admin_users_event.dart`, `admin_users_state.dart`
- **Verification**: New exports reference existing files, barrel compiles
- **Dependencies**: T9, T10, T11

### T15: ✅ Update barrel exports — `use_cases.dart`
- **File**: `lib/features/domain/use_cases/use_cases.dart` (MODIFY)
- **Action**: Add `export 'package:noveles/features/domain/use_cases/get_all_profiles.dart';`
- **Verification**: New export references existing file, barrel compiles
- **Dependencies**: T4

---

## Phase 5 — DI Wiring

### T16: ✅ Update `GenreBloc` registration in `injection.dart`
- **File**: `lib/core/di/injection.dart` (MODIFY)
- **Action**: Change `getIt.registerFactory(() => GenreBloc(getIt()));` to named params pattern: `getIt.registerFactory(() => GenreBloc(getGenre: getIt(), createGenre: getIt(), updateGenre: getIt(), deleteGenre: getIt()));`
- **Verification**: GenreBloc receives all 4 use cases, injection.dart compiles
- **Dependencies**: T6

### T17: ✅ Update `AdminBloc` registration in `injection.dart`
- **File**: `lib/core/di/injection.dart` (MODIFY)
- **Action**: Add `deleteBook: getIt()` to AdminBloc factory: `AdminBloc(getBooks: getIt(), toggleBookVisibility: getIt(), deleteBook: getIt())`
- **Verification**: AdminBloc receives DeleteBook use case, injection.dart compiles
- **Dependencies**: T8

### T18: ✅ Register `GetAllProfiles` + `AdminUsersBloc` in `injection.dart`
- **File**: `lib/core/di/injection.dart` (MODIFY)
- **Action**: Add import for `GetAllProfiles` and `AdminUsersBloc`
- **Action**: Register `getIt.registerLazySingleton(() => GetAllProfiles(getIt()));` in use cases section
- **Action**: Register `getIt.registerFactory(() => AdminUsersBloc(getAllProfiles: getIt()));` in blocs section
- **Verification**: New registrations follow existing patterns, injection.dart compiles
- **Dependencies**: T4, T11

---

## Phase 6 — Testing

### T19: Update `GenreBloc` tests for CRUD
- **File**: `test/bloc/genre_bloc_test.dart` (MODIFY)
- **Action**: Add mocks: `MockCreateGenre`, `MockUpdateGenre`, `MockDeleteGenre`
- **Action**: Add `setUp` for new mocks
- **Action**: Update `GenreBloc` construction to use named params with all 4 mocks
- **Action**: Add blocTest for `CreateGenreEvent` → call createGenre, reload, emit `GenreLoaded` with success message
- **Action**: Add blocTest for `CreateGenreEvent` → error path → emit `GenreError`
- **Action**: Add blocTest for `UpdateGenreEvent` → success path
- **Action**: Add blocTest for `UpdateGenreEvent` → error path
- **Action**: Add blocTest for `DeleteGenreEvent` → success path
- **Action**: Add blocTest for `DeleteGenreEvent` → error path
- **Verification**: All existing tests still pass, 6+ new test cases cover CRUD success + error
- **Dependencies**: T6 (GenreBloc wiring exists)

### T20: Update `AdminBloc` tests for `DeleteAdminBook`
- **File**: `test/bloc/admin_bloc_test.dart` (MODIFY)
- **Action**: Add `MockDeleteBook extends Mock implements DeleteBook`
- **Action**: Update AdminBloc construction to include `deleteBook` mock
- **Action**: Add blocTest: `DeleteAdminBook` succeeds → delete called → books reloaded → `AdminLoaded` with message 'Libro eliminado'
- **Action**: Add blocTest: `DeleteAdminBook` fails → `AdminError` with error message
- **Verification**: All existing tests still pass, 2 new blocTests cover delete success + error
- **Dependencies**: T8 (AdminBloc DeleteBook wiring)

### T21: Create `AdminUsersBloc` tests
- **File**: `test/bloc/admin_users_bloc_test.dart` (CREATE)
- **Action**: Mock `MockGetAllProfiles extends Mock implements GetAllProfiles`
- **Action**: Test initial state is `AdminUsersInitial`
- **Action**: blocTest: `LoadAdminUsers` succeeds → emit `AdminUsersLoading` → `AdminUsersLoaded` with profiles
- **Action**: blocTest: `LoadAdminUsers` fails → emit `AdminUsersLoading` → `AdminUsersError` with message
- **Verification**: 3 tests pass, follows existing bloc test patterns
- **Dependencies**: T11 (AdminUsersBloc exists)

### T22: Create `GetAllProfiles` use case test
- **File**: `test/use_cases/get_all_profiles_test.dart` (CREATE)
- **Action**: Mock `MockProfilesRepository extends Mock implements ProfilesRepository`
- **Action**: Test `call()` returns list of users when repository succeeds
- **Action**: Test `call()` throws when repository fails
- **Verification**: 2 tests pass, follows existing use case test patterns (see `test/use_cases/label_use_cases_test.dart`)
- **Dependencies**: T4

---

## Implementation Order

```
Phase 1 (T1)              Database migration
     ↓
Phase 2 (T2 → T3 → T4)    Interface → Impl → Use Case
     ↓
Phase 3 (T5→T6, T7→T8,    BLoC events+handlers + new AdminUsersBloc
         T9→T10→T11)       
     ↓
Phase 4 (T12, T13,        UI refactor + navigation + barrel exports
         T14, T15)         
     ↓
Phase 5 (T16, T17, T18)   DI wiring
     ↓
Phase 6 (T19, T20,        Tests (least likely to cause merge conflicts)
         T21, T22)         
```

**Rationale**: Bottom-up dependency order. Database first (no code deps). Domain layer second (used by everything above). BLoC third (consumes domain). UI fourth (consumes BLoC). DI fifth (wires everything). Tests last (requires all code to exist).

## Next Step
Ready for implementation (`sdd-apply`). 22 tasks across 6 phases, strict dependency chain.
