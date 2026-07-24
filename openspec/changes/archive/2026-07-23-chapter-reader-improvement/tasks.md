# Tasks: Chapter Reader Improvement

## Layer 1 — Bloc & Data (Pure Dart + Bloc)

### T1 — Add `ChapterContentType` enum and `contentType` field to domain entities

- **ID**: T1
- **Title**: Add `ChapterContentType` enum and `contentType` field to domain entities
- **Layer**: 1
- **Files**:
  - `lib/features/chapters/domain/chapter_entity.dart` (modify)
  - `lib/features/chapters/domain/chapter_ref.dart` (modify)
  - `lib/features/chapters/data/chapter_model.dart` (modify)
  - `test/entities/chapter_entity_test.dart` (modify — add contentType roundtrip)
- **Dependencies**: None
- **Acceptance**:
  - `ChapterContentType` enum exists with `inline` and `storagePath` values
  - `ChapterEntity` has `contentType` field defaulting to `ChapterContentType.storagePath`
  - `ChapterRef` has `contentType` field
  - `ChapterModel.fromJson`/`toJson` roundtrip includes `contentType`
  - Existing entity tests pass with new field
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T2 — Replace `_isStoragePath` heuristic with `ChapterContentType` in repository

- **ID**: T2
- **Title**: Replace `_isStoragePath` heuristic with `ChapterContentType` in repository
- **Layer**: 1
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/data/chapter_repository_impl.dart` (modify)
  - `test/repositories/chapter_repository_test.dart` (modify — add contentType-based dispatch tests)
- **Dependencies**: T1
- **Acceptance**:
  - `_isStoragePath` method removed from `ChapterRepositoryImpl`
  - `downloadContent` uses `ChapterContentType` enum to decide storage vs inline
  - Existing `downloadContent` behavior preserved for both paths
  - Repository tests verify correct dispatch for `inline` and `storagePath` content types
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T3 — Add `clear()` method to `ChapterCache` for stale entry cleanup

- **ID**: T3
- **Title**: Add `clear()` method to `ChapterCache` for stale entry cleanup
- **Layer**: 1
- **Files**:
  - `lib/core/supabase/chapter_cache.dart` (modify)
  - `test/repositories/chapter_cache_test.dart` (create — test clear method)
- **Dependencies**: None
- **Acceptance**:
  - `ChapterCache.clear()` removes all cached files from the cache directory
  - `ChapterCache.clear()` does not throw if directory doesn't exist
  - Existing `read`/`save`/`has` methods unchanged
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T4 — Add new bloc events (`LoadChapter`, `PreloadAdjacent`) and states (`ChapterLoadedSingle`, `ChapterLoadError`)

- **ID**: T4
- **Title**: Add new bloc events and states for lazy loading
- **Layer**: 1
- **Files**:
  - `lib/features/chapters/presentation/bloc/chapter_event.dart` (modify — add `LoadChapter`, `PreloadAdjacent`)
  - `lib/features/chapters/presentation/bloc/chapter_state.dart` (modify — add `ChapterLoadedSingle`, `ChapterLoadError`, keep `ChapterInitial`)
  - `test/bloc/chapter_bloc_test.dart` (modify — update imports, add new event/state tests)
- **Dependencies**: T1 (contentType on ChapterRef)
- **Acceptance**:
  - `LoadChapter` event exists with `index`, `refs` fields
  - `PreloadAdjacent` event exists with `currentIndex`, `refs` fields
  - `ChapterLoadedSingle` state exists with `cache`, `currentIndex`, `totalCount`, `chapterOrder`
  - `ChapterLoadError` state exists with `chapterId`, `message`
  - Old `LoadChapterContent` event and `ChapterLoaded`/`ChapterLoading`/`ChapterError` states remain (removed in T5)
  - New event/state classes compile and are Equatable
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T5 — Rewrite `ChapterBloc` with lazy `Map<int, ChapterEntity>` cache and preload logic

- **ID**: T5
- **Title**: Rewrite `ChapterBloc` with lazy `Map<int, ChapterEntity>` cache and preload adjacent logic
- **Layer**: 1
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/bloc/chapter_bloc.dart` (rewrite)
  - `test/bloc/chapter_bloc_test.dart` (rewrite — remove old `LoadChapterContent` tests, add new tests for `LoadChapter`, `PreloadAdjacent`, error isolation, order preservation)
- **Dependencies**: T1, T4
- **Acceptance**:
  - `LoadChapter` event loads a single chapter and emits `ChapterLoadedSingle`
  - `PreloadAdjacent` loads next 3 chapters, skips already-cached ones
  - Bloc maintains `Map<int, ChapterEntity>` cache across events
  - Error on single chapter emits `ChapterLoadError` without clearing existing cache
  - Chapter order preserved across loads via `chapterOrder` list
  - Old `LoadChapterContent` event handler removed
  - Old `ChapterLoaded`/`ChapterLoading`/`ChapterError` states removed
  - All existing bloc tests updated to new event/state model
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T6 — Add `content_type` column migration to chapters table

- **ID**: T6
- **Title**: Add `content_type` column migration to chapters table
- **Layer**: 1
- **Files**:
  - `supabase/migrations/20260723050000_add_content_type.sql` (create)
- **Dependencies**: None (can run independently)
- **Acceptance**:
  - Migration adds `content_type` column (nullable text) to `chapters` table
  - Migration is idempotent (uses `IF NOT EXISTS`)
  - Existing rows have `NULL` content_type (code defaults to `storagePath`)
- **Estimated effort**: Small
- **Strict TDD**: No (DB migration, no Dart test)

---

### T7 — Update `ChapterModel` to serialize/deserialize `contentType`

- **ID**: T7
- **Title**: Update `ChapterModel` to serialize/deserialize `contentType`
- **Layer**: 1
- **Files**:
  - `lib/features/chapters/data/chapter_model.dart` (modify)
  - `test/entities/chapter_entity_test.dart` (modify — add roundtrip test with contentType)
- **Dependencies**: T1, T6
- **Acceptance**:
  - `ChapterModel.fromJson` reads `content_type` field and maps to `ChapterContentType`
  - `ChapterModel.toJson` writes `content_type` field
  - `ChapterModel.fromEntity` preserves `contentType`
  - Roundtrip test passes for both `inline` and `storagePath` values
  - Null `content_type` in JSON defaults to `ChapterContentType.storagePath`
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T8 — Update `ChapterRepositoryImpl.downloadContent` to use `ContentType` instead of `_isStoragePath`

- **ID**: T8
- **Title**: Update `ChapterRepositoryImpl.downloadContent` to use `ContentType` instead of `_isStoragePath`
- **Layer**: 1
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/data/chapter_repository_impl.dart` (modify)
  - `test/repositories/chapter_repository_test.dart` (modify — add contentType dispatch tests)
- **Dependencies**: T1, T2, T7
- **Acceptance**:
  - `_isStoragePath` method removed
  - `downloadContent` accepts a `ChapterContentType` parameter (or uses entity's contentType)
  - Storage path branch downloads from Supabase storage + caches
  - Inline branch returns content as-is
  - Repository tests verify both branches
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T9 — Add `shared_preferences` dependency to `pubspec.yaml`

- **ID**: T9
- **Title**: Add `shared_preferences` dependency to `pubspec.yaml`
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `pubspec.yaml` (modify)
- **Dependencies**: None
- **Acceptance**:
  - `shared_preferences` added under dependencies
  - `flutter pub get` succeeds
- **Estimated effort**: Trivial
- **Strict TDD**: No

---

### T10 — Rewrite `ChapterScreen` with instance PageController, per-page ScrollControllers, and reading typography

- **ID**: T10
- **Title**: Rewrite `ChapterScreen` with instance PageController, per-page ScrollControllers, and reading typography
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/chapter_screen.dart` (rewrite)
  - `test/widgets/chapter_screen_read_test.dart` (rewrite — update for new architecture)
- **Dependencies**: T5, T9
- **Acceptance**:
  - `PageController` is an instance variable (created once in `initState`)
  - `Map<int, ScrollController>` created lazily via `onPageChanged` listener
  - Each page's `ScrollController` is disposed when no longer needed
  - Reading text uses `Theme.of(context).textTheme.bodyLarge` with scaled `fontSize` and `height: 1.6`
  - "Chapter X of Y" indicator in app bar updates on page change
  - Existing mark-as-read test updated: mark fires on 80% scroll threshold, not `initState`
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T11 — Add font size controls and reading mode toggle overlay

- **ID**: T11
- **Title**: Add font size controls (+/- buttons) and reading mode toggle (normal/sepia/night) overlay
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/widgets/reading_settings_bar.dart` (create)
  - `lib/features/chapters/presentation/screens/chapter_screen.dart` (modify — integrate overlay)
  - `test/widgets/chapter_screen_read_test.dart` (modify — add font size and mode tests)
- **Dependencies**: T10
- **Acceptance**:
  - `ReadingMode` enum exists with `normal`, `sepia`, `night` values
  - Font size +/- buttons change `fontSize` state in `_ChapterScreenState`
  - Font size changes reflect in rendered `Text` style
  - Sepia mode changes `Scaffold.backgroundColor` to sepia tone
  - Night mode changes `Scaffold.backgroundColor` to dark tone
  - Toggle cycles through modes
  - Overlay is visible/hidden based on scroll direction (reuse existing `isVisible` logic)
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T12 — Add scroll-based "mark as read" on 80% threshold

- **ID**: T12
- **Title**: Add scroll-based "mark as read" on 80% scroll threshold
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/chapter_screen.dart` (modify)
  - `test/widgets/chapter_screen_read_test.dart` (modify — replace initState mark test with scroll threshold test)
- **Dependencies**: T10
- **Acceptance**:
  - `MarkChapterAsRead` fires when scroll position reaches 80% of content
  - `MarkChapterAsRead` fires only ONCE per chapter (flag prevents re-fire)
  - `MarkChapterAsRead` does NOT fire in `initState` anymore
  - Existing test updated: mock `ScrollController.position`, verify `MarkChapterAsRead` call at 80%+
  - Unauthenticated user does NOT trigger mark
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T13 — Add scroll position persistence via `shared_preferences`

- **ID**: T13
- **Title**: Add scroll position persistence via `shared_preferences`
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/chapter_screen.dart` (modify)
  - `test/widgets/chapter_screen_read_test.dart` (modify — add persistence tests)
- **Dependencies**: T9, T10
- **Acceptance**:
  - Scroll offset saved to `SharedPreferences` on page change with 2s debounce
  - Key format: `chapter_scroll_{chapterId}`
  - On page load, scroll position restored from `SharedPreferences`
  - Test verifies `SharedPreferences.setDouble` called (debounced) on page change
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T14 — Create `ReadingSettingsBar` widget (font size + mode toggle)

- **ID**: T14
- **Title**: Create `ReadingSettingsBar` widget with font size controls and reading mode toggle
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/widgets/reading_settings_bar.dart` (create)
  - `test/widgets/reading_settings_bar_test.dart` (create)
- **Dependencies**: T10
- **Acceptance**:
  - Widget displays font size decrease (-) and increase (+) buttons
  - Widget displays mode toggle button cycling normal → sepia → night
  - Callbacks: `onFontSizeChanged(double)`, `onModeChanged(ReadingMode)`
  - Widget is a standalone `StatelessWidget` (state lives in parent `ChapterScreen`)
  - Test verifies button taps trigger callbacks
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T15 — Integrate `ReadingSettingsBar` and reading mode into `ChapterScreen`

- **ID**: T15
- **Title**: Integrate `ReadingSettingsBar` overlay and reading mode state into `ChapterScreen`
- **Layer**: 2
- **Status**: [x]
- **Files**:
  - `lib/features/chapters/presentation/screens/chapter_screen.dart` (modify)
  - `test/widgets/chapter_screen_read_test.dart` (modify — add font size and mode tests)
- **Dependencies**: T10, T11, T14
- **Acceptance**:
  - `ReadingSettingsBar` appears as overlay when `isVisible` is true
  - Font size changes via +/- buttons reflect in chapter text style
  - Sepia mode changes `Scaffold.backgroundColor` to sepia color
  - Night mode changes `Scaffold.backgroundColor` to dark color
  - Mode toggle cycles normal → sepia → night → normal
  - Font size has min/max bounds (e.g., 12–28)
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

### T16 — Create `TookSliverHeader` widget (styled header with cover image)

- **ID**: T16
- **Title**: Create `TookSliverHeader` widget with cover image (similar to `SliverAppBarBook`)
- **Layer**: 3
- **Files**:
  - `lib/features/chapters/presentation/screens/widgets/took_sliver_header.dart` (create)
  - `test/widgets/took_sliver_header_test.dart` (create)
- **Dependencies**: None (independent widget)
- **Acceptance**:
  - Widget is a `SliverAppBar` with `FlexibleSpaceBar` containing cover image
  - Cover image uses `CachedNetworkImage` with `CoverUrlService`
  - Blur overlay and gradient fade into scaffold background (matching `SliverAppBarBook` pattern)
  - Displays took title and number
  - Test verifies `CachedNetworkImage` is present when cover is non-empty
  - Test verifies fallback icon when cover is empty
- **Estimated effort**: Small
- **Strict TDD**: Yes

---

### T17 — Update `TookScreen` with styled header, loading indicator, and read-status chapter list

- **ID**: T17
- **Title**: Update `TookScreen` with styled header, loading indicator, and read-status chapter list
- **Layer**: 3
- **Files**:
  - `lib/features/tooks/presentation/screens/took_screen.dart` (modify)
  - `test/widgets/took_screen_test.dart` (modify — update for new header structure)
- **Dependencies**: T16
- **Acceptance**:
  - `TookSliverHeader` replaces the plain `SliverAppBar` at the top of the scroll view
  - Loading indicator (`CircularProgressIndicator`) shows while `_loadingReadIds` is true
  - Read chapters show grey text, unread chapters show theme default color
  - Took title and number displayed in the header
  - Existing read-coloring tests pass with new header structure
- **Estimated effort**: Medium
- **Strict TDD**: Yes

---

## Review Workload Forecast

| Metric | Value |
|--------|-------|
| **Total estimated changed lines** | ~950–1,100 |
| **400-line budget risk** | **High** — exceeds 400 by 2.5–3× |
| **Chained PRs recommended** | **Yes** — 3 chained PRs (one per layer) |
| **Decision needed before apply** | **Yes** — confirm `shared_preferences` key format: `chapter_scroll_{chapterId}` vs `{userId}_chapter_{chapterId}` |

### Chained PR Breakdown

| PR | Layer | Tasks | Est. Lines | Risk |
|----|-------|-------|------------|------|
| PR 1 | Layer 1 (Bloc + Data) | T1, T2, T3, T4, T5, T6, T7, T8 | ~350–400 | Medium |
| PR 2 | Layer 2 (ChapterScreen) | T9, T10, T11, T12, T13, T14, T15 | ~400–500 | High |
| PR 3 | Layer 3 (TookScreen) | T16, T17 | ~150–200 | Low |

### Task Dependency Graph

```
T1 ──► T2 ──► T8
  │
  └──► T4 ──► T5
  │
  └──► T7 ──► T8
       │
T6 ────┘

T3 (independent)

T9 ──► T10 ──► T11 ──► T12 ──► T13
                │
                └──────► T14 ──► T15

T16 ──► T17
```

### Execution Order (by layer)

**Layer 1 (PR 1):** T6 → T1 → T3 → T4 → T7 → T2 → T5 → T8
**Layer 2 (PR 2):** T9 → T10 → T11 → T14 → T12 → T13 → T15
**Layer 3 (PR 3):** T16 → T17
