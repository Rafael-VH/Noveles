# Tasks: Book Screen Visual Redesign

## Review Workload Forecast
Estimated changed lines: ~280
400-line budget risk: Low
Chained PRs recommended: No
Decision needed before apply: No

## Phase 1: Sub-Widgets & Components (Foundation)

- [x] 1.1 Create `lib/features/books/presentation/screens/widgets/book_quick_stats_bar.dart` with rating, tomos/capítulos count, and status pill badges.
- [x] 1.2 Create `lib/features/books/presentation/screens/widgets/book_action_bar.dart` with prominent "Continuar Lectura" button and `FavoriteButton`.
- [x] 1.3 Create `lib/features/books/presentation/screens/widgets/book_metadata_grid.dart` with modular cards (Publicado, Tipo, País, Estado) replacing the monolithic container.

## Phase 2: Screen Integration & Tab Persistent Header

- [x] 2.1 Refactor `lib/features/books/presentation/screens/book_screen.dart` to add `SliverPersistentHeader` tab bar ("Información" vs "Tomos & Capítulos").
- [x] 2.2 Re-wire `book_screen.dart` slivers to host `BookQuickStatsBar`, `BookActionBar`, `BookMetadataGrid`, and `BookTookList` in their respective tabs.
- [x] 2.3 Remove unused `lib/features/books/presentation/screens/widgets/card_info_detail.dart`.

## Phase 3: Verification & Cleanup

- [x] 3.1 Run `flutter analyze` to verify 0 errors/warnings.
- [x] 3.2 Run `flutter test` to verify all existing tests pass without regressions.
