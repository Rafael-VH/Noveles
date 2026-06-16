# Proposal: Architecture & Testing — Audit Fixes

## Intent

The `audit-fixes-complete` change fixed 7 critical issues and ~20 warnings across DB/security/architecture/testing phases. This second wave addresses the **remaining 24 issues** identified by a deeper multi-agent review, focused on:

- **Domain purity**: Remove the last Supabase type leak (`AuthChangeEvent`) from the domain layer
- **Presentation defects**: Fix BLoC lifecycle mismanagement, direct DI calls in widgets, and Supabase coupling in 7 UI files
- **Test coverage gap**: Add missing success-path tests for repositories, entity tests, and critical use cases
- **Infra hardening**: Fix fragile global `supabase` variable, missing FK indexes, dangling RLS policies, and seed data issues

## Scope

### In Scope

- **Batch 0** — Restructure data/ and domain/ from flat layers to feature-grouped directories (mirroring presentation/ structure). Move files, update imports, split DI registration. Zero behavior change.
- **Batch 1** — Fix `AuthRepository` domain leak (`AuthChangeEvent` → domain `AuthEvent` enum) + add Failure class hierarchy
- **Batch 2** — Abstract `coverUrl()` behind injectable service, route `GenreScreen` through BLoC, fix `ScanMainScreen`/`TookScreen` BLoC lifecycle
- **Batch 3** — Fix UI defects: LoginScreen listener, app_drawer sync read, ChapterScreen initState order, LabelManagementScreen entity leak, ProfileState dart:io, BookModel.toJson omission
- **Batch 4** — Harden infra: injectable Supabase client, remove dead DI registrations, add missing FK indexes, fix book_views RLS, fix seed data paths/dormant policies
- **Batch 5** — Tests: success-path tests for all 7 repository implementations + missing entity tests (Genre, User) + fix weak props assertions
- **Batch 6** — Tests: critical use case tests (core CRUD: create/update/delete book, chapter, took) + ThemeBloc tests + replace placeholder smoke test

### Out of Scope

- `ScanBloc` decomposition (God BLoC — requires separate architecture change)
- `AdminMainScreen` 705-line decomposition (separate refactor)
- Feature development, new screens, or new use cases
- ThemeBloc → Cubit migration (pure refactor, no behavior change)
- String role → enum `UserRole` (requires migration, deferred)
- ColorsTheme rename / doc comments (cosmetic)
- `book_id` BIGINT type mismatch (requires data migration)
- Utils directory population (no clear requirements)

## Capabilities

### New Capabilities

- `domain-auth-event`: Domain-pure `enum AuthEvent` replacing Supabase `AuthChangeEvent` leak
- `cover-url-service`: Injectable cover URL builder abstracted from `supabase.storage`

### Modified Capabilities

- None — all changes are refactoring and testing, no spec-level behavior changes

## Approach

**Dependency order**: Restructure → Domain → Data → Presentation → Infra → Tests.

Each batch is a chained PR targeting `main` (ask-on-risk strategy, 400-line budget per slice):

0. **Batch 0** (restructure): Move all flat files in data/ and domain/ into feature subdirectories. Split `injection.dart` into per-feature DI files. Update all imports. `dart analyze` must pass, all tests green.
1. **Batch 1** (domain): Define `enum AuthEvent` in domain, change `AuthRepository.onAuthStateChange()` return type, update impl mapping, create `Failure` base class hierarchy, update Bloc error handling
2. **Batch 2** (presentation layer): Create `CoverUrlService` in core/domain, swap 7 `storage_helper` imports to injection, add `GenreBloc` for genre screen, fix `ScanMainScreen`/`TookScreen` BLoC lifecycle
3. **Batch 3** (presentation defects): Fix 7 individual UI bugs, extract shared patterns
4. **Batch 4** (infra): Wrap global `supabase` in injectable singleton, add migration SQL, fix RLS/seed
5. **Batch 5** (tests — repos + entities): Add success-path tests for all 7 repo impls, add GenreEntity/UserEntity tests, fix props assertions
6. **Batch 6** (tests — use cases + blocs + smoke): Test top-5 use cases (create book/chapter/took, update, delete), ThemeBloc tests, replace widget_test.dart placeholder

**Use `arquic review` before each batch** (domain/presentation changes).

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/features/domain/repositories/auth_repository.dart` | Modified | Return type `Stream<AuthEvent>` instead of `Stream<AuthChangeEvent>` |
| `lib/features/domain/helpers/auth_event.dart` | **New** | `enum AuthEvent` |
| `lib/core/errors/failure.dart` | **New** | `Failure` class hierarchy for typed error handling |
| `lib/features/data/repositories/auth_repository_impl.dart` | Modified | Map Supabase events → domain `AuthEvent` |
| `lib/features/domain/use_cases/listen_auth_state.dart` | Modified | Return type change |
| `lib/features/presentation/bloc/auth/auth_bloc.dart` | Modified | Remove `supabase_flutter` import, use domain `AuthEvent` |
| `lib/core/cover/cover_url_service.dart` | **New** | Injectable cover URL builder |
| `lib/core/di/injection.dart` | Modified | Register new services |
| `lib/features/presentation/screens/genre/genre_screen.dart` | Modified | Route through BLoC, inject cover service |
| `lib/features/presentation/bloc/genre/genre_bloc.dart` | **New** | State management for genre filtering |
| `lib/features/presentation/screens/scan/scan_main_screen.dart` | Modified | Fix BLoC lifecycle |
| `lib/features/presentation/screens/took/took_screen.dart` | Modified | Use `BlocProvider` |
| `lib/features/presentation/screens/login/login_screen.dart` | Modified | Add `BlocListener` for errors |
| `lib/features/presentation/widgets/app_drawer.dart` | Modified | Use `BlocBuilder` |
| `lib/features/presentation/screens/chapter/chapter_screen.dart` | Modified | Fix initState order, TextEditingControllers |
| `lib/features/presentation/screens/label/label_management_screen.dart` | Modified | Inject through BLoC |
| `lib/features/presentation/bloc/profile/profile_state.dart` | Modified | Remove `dart:io` |
| `lib/features/data/models/book_model.dart` | Modified | Add `author_name` to `toJson()` |
| `lib/core/supabase/supabase_client.dart` | Modified | Make injectable, not global |
| `supabase/migrations/20260526000000_audit_fixes_v3.sql` | **New** | FK indexes, book_views policy, authors RLS |
| `supabase/seed.sql` | Modified | Fix paths, admin promotion |
| `test/repositories/*_test.dart` | Modified | Add success paths |
| `test/entities/genre_entity_test.dart` | **New** | Entity test |
| `test/entities/user_entity_test.dart` | **New** | Entity test |
| `test/bloc/theme_bloc_test.dart` | **New** | BLoC test (if separate file) |
| `test/use_cases/` | **New** | Critical use case tests |
| `test/widget_test.dart` | Modified | Replace placeholder |
| 7 files importing `storage_helper.dart` | Modified | Use injected `CoverUrlService` |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Batch 2 breaks cover loading in 7 screens | Medium | Test each screen after change; `CoverUrlService` preserves same API contract |
| Batch 3 BLoC lifecycle changes cause double-fire events | Low | Test dispose/recreate flows; existing bloc tests guard regression |
| Batch 4 migration conflicts with existing DB state | Medium | Idempotent SQL (`IF NOT EXISTS`, `DROP IF EXISTS`); test on staging first |
| Batch 1 changes auth stream type — runtime breakage | Low | AuthBloc already uses only `signedOut` event; mapping is 1:1 |
| 400-line budget may be tight for some batches | Medium | Batch 5 (repos) may need splitting into 5a/5b |

## Rollback Plan

Per batch: `git revert` the chained PR commit. Migration rollback SQL included in migration file comments.

Specific rollbacks:
- **Batch 1**: Restore `AuthRepository` + `ListenAuthState` to previous types, delete `auth_event.dart` and `failure.dart`
- **Batch 2**: Revert injection changes, restore `storage_helper` imports, revert screen lifecycle changes
- **Batch 3**: Revert individual UI file changes
- **Batch 4**: `DROP INDEX` statements + restore global `supabase` variable pattern
- **Batch 5/6**: Delete test files

## Dependencies

- `arquic` skill for Clean Architecture review before Batch 1 and Batch 2
- Batch 1 must precede Batch 2 (domain types used by presentation)
- Batch 4 migration must precede integration tests
- All batches can apply independently with clean `main` base

## Success Criteria

- [ ] `AuthRepository` no longer imports any Supabase type — `Stream<AuthEvent>` only
- [ ] `AuthBloc` no longer imports `supabase_flutter` or `storage_helper`
- [ ] Blocs catch typed `Failure`, not raw `e.toString()`
- [ ] 0 UI files import `storage_helper.dart` — all use `CoverUrlService`
- [ ] `GenreScreen` filtered books come from BLoC, not `getIt` directly
- [ ] No screen manually `close()` a BLoC obtained from global `getIt`
- [ ] `flutter analyze` passes with 0 errors
- [ ] All existing tests still pass
- [ ] Migration `audit_fixes_v3.sql` applies idempotently on fresh and existing DB
- [ ] Repository tests cover both success + error paths for every CRUD method
- [ ] GenreEntity + UserEntity have min 1 test each
- [ ] At least 5 core use cases have test coverage
- [ ] `widget_test.dart` is no longer a placeholder
