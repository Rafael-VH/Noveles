# Proposal: Audit Fixes — Complete

## Intent

Fix all 7 critical security/bug/architecture issues, 17 high-impact warnings, and critical UI defects identified in the comprehensive audit. The goal is to make the project production-ready by securing the database, restoring admin write access, fixing broken features, and adding missing architectural layers — without expanding scope into full refactoring.

## Scope

### In Scope

- All 7 critical findings: RLS enablement, admin write policies, GenreScreen filter bug, .env git tracking, LabelRepositoryImpl export, BLoC Supabase bypass, missing DTO layer
- 17 of 24 warnings: password policy, email confirmation, rate limits, UUIDs, indexes, column semantics, redundant migrations, chapterCount→content mapping, error handling, ChapterCache, explicit id on create, BookScreen dead code, AI boilerplate, immersive mode, GenreScreen scaffold, Cupertino icons, coverUrl validation
- Critical test coverage for untested blocs (Auth, Profile, Admin, Label, Chapter)

### Out of Scope

- ScanBloc decomposition into multiple domain-specific blocs (larger refactor — create separate change)
- Full test coverage across all features (scope to critical paths and untested blocs)
- New feature development
- Data migration for existing column semantics (schema fix + new column mapping only)

## Phases

### Phase 1: Security & Database (Foundation)

| Task | Area | Effort |
|------|------|--------|
| RLS enable on genres, books_genres, authors | Supabase migration | S |
| Restore admin write policies (create `admin` policies, keep `scan`) | Supabase migration | M |
| Remove .env from git tracking + scrub history | Git | S |
| Password: min 8 chars + lower_upper_letters_digits | config.toml | S |
| Enable email confirmations | config.toml | S |
| Rate limit: max_frequency 60s | config.toml | S |
| Add FK indexes (tooks.book_id, chapters.took_id, etc.) | Supabase migration | S |
| Replace hardcoded UUIDs with subquery | Supabase migration | S |
| Consolidate 20260518010000 + 20260518020000 | Supabase migration | S |

### Phase 2: Architecture Fixes

| Task | Area | Effort |
|------|------|--------|
| Add DTOs: `lib/features/data/models/` with fromJson/toJson | Dart models | L |
| Refactor repositories to use DTOs, map to domain entities | Data layer | L |
| Remove `supabase` import from AuthBloc → inject via use case | Auth | S |
| Remove `supabase` import from LabelBloc → inject via use case | Label | S |
| Export `LabelRepositoryImpl` from `repositories.dart` barrel | Data layer | S |
| Preserve original exception types in all repo implementations | Data layer | M |
| Add logging to `ChapterCache` catch blocks | Core | S |

### Phase 3: Bug Fixes

| Task | Area | Effort |
|------|------|--------|
| GenreScreen: use `filteredBooks` instead of `widget.books` | UI | S |
| GenreScreen: wrap in Scaffold + AppBar with back nav | UI | S |
| Rename `TookEntity.chapterCount` to clarify mapping; fix `content`→`chapter_count` in schema | Data | M |
| Remove `showInfoDialog()` dead code from BookScreen | UI | S |
| Remove explicit `id` on create in `createTook` | Data | S |
| Strip AI boilerplate comments from blocs/use cases | All | S |
| Validate `coverUrl()` — return placeholder if cover empty | Core | S |

### Phase 4: Testing

| Task | Area | Effort |
|------|------|--------|
| AuthBloc tests (login, register, logout, session check) | Tests | M |
| ProfileBloc tests (load, update profile) | Tests | M |
| LabelBloc tests (CRUD + assign/remove) | Tests | M |
| AdminBloc, ChapterBloc tests | Tests | M |
| Repository impl tests (book, took, chapter) | Tests | M |

### Phase 5: UI/UX

| Task | Area | Effort |
|------|------|--------|
| Move `SystemUiMode.immersive` from main.dart to ChapterScreen only | UI | S |
| Remove unused Cupertino icons dependency | Config | S |

## Approach

**Phase 1** targets the database via Supabase migrations — order matters: enable RLS before adding policies, add indexes after schema consolidation. **Phase 2** adds the missing DTO layer (`data/models/`), refactors repositories to use them, and removes direct Supabase coupling from BLoCs by routing through the domain layer. **Phase 3** fixes UI and data mapping bugs in isolation. **Phase 4** uses `flutter test` with mock Supabase client for bloc tests. **Phase 5** scopes immersive mode and removes dead assets.

Reverse dependencies: Phase 1 (DB) → Phase 2 (DTOs) → Phase 3 (mapping fixes) → Phase 4 (tests) → Phase 5 (UI). Phases 3 and 5 can partially overlap.

## Affected Areas

- **Supabase**: `supabase/migrations/` (new migration), `supabase/config.toml`
- **Git**: `.env` removal from history, `.gitignore`
- **Data layer**: `lib/features/data/models/` (new), `*_repository_impl.dart`, `repositories.dart`
- **Domain**: `took_entity.dart` (rename field), `repositories.dart`
- **BLoCs**: `auth_bloc.dart`, `label_bloc.dart`
- **UI**: `genre_screen.dart`, `book_screen.dart`, `main.dart`, `chapter_screen.dart`
- **Core**: `supabase_client.dart`, `chapter_cache.dart`, `storage_helper.dart`
- **Tests**: `test/` (5 new bloc test files, 3 new repo test files)

## Risks

- **Migration order on remote**: RLS enable + policy create in correct sequence; wrong order causes silent SELECT failures. Mitigation: test via `supabase db push` on staging first.
- **UUID replacement**: Subquery may fail if admin user doesn't exist. Mitigation: wrap in DO block with fallback.
- **DTO layer churn**: All repository impls change signature. Keep old mapping methods until DTOs are verified.
- **.env git scrub**: Destructive to git history. Use `git filter-repo` on a clone, coordinate with team.
- **Immersive mode move**: Chapter reading flow must be verified end-to-end after moving the call.

## Success Criteria

- [ ] RLS enabled on all tables — non-authenticated queries return empty for write operations
- [ ] Admin (`scan` role) can INSERT/UPDATE/DELETE on all content tables
- [ ] `filteredBooks` used in GenreScreen — genre filtering works correctly
- [ ] `.env` removed from git history — no secrets in version control
- [ ] `LabelRepositoryImpl` importable from barrel file
- [ ] AuthBloc and LabelBloc no longer import `supabase` directly
- [ ] DTOs exist for all 5 main entities — no raw JSON mapping in repos
- [ ] All untested blocs have minimum smoke tests (login, load, error states)
- [ ] `coverUrl("")` returns placeholder, not broken URL
- [ ] Immersive mode only active on chapter reading screen
