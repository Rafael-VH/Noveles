# Spec: Chapter Reader Improvement

> **Change**: `chapter-reader-improvement`
> **Type**: Multi-domain — new capabilities + delta specs + infrastructure specs
> **Persistent artifacts**: `openspec` + Engram (`sdd/chapter-reader-improvement/spec`)

---

## 1. reading-settings — New Capability

### Intent

Let users control font size and reading mode (normal, sepia, night) inside the chapter reader. Settings apply only to the reader view — they do not affect the global app theme.

### Requirements

#### Requirement: Font size control

The reader MUST provide controls to increase and decrease the text font size. The system SHALL persist the selected size for the session.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Increase font | reader shows chapter text | user taps increase-size button | font size grows by one step (min 14sp, max 32sp, step 2sp) |
| Decrease font | reader shows chapter text | user taps decrease-size button | font size decreases by one step |
| Minimum boundary | current size is 14sp | user taps decrease | size stays at 14sp |
| Maximum boundary | current size is 32sp | user taps increase | size stays at 32sp |

#### Requirement: Reading mode toggle

The reader MUST support three modes: **normal** (white bg / dark text), **sepia** (warm beige bg / brown text), and **night** (dark bg / light text). The reader SHALL apply the mode instantly without reloading content.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Switch to sepia | reader in normal mode | user selects sepia | background changes to warm beige, text to brown tones |
| Switch to night | reader in any mode | user selects night | background changes to dark, text to light |
| Switch back | reader in night mode | user selects normal | returns to white bg / dark text |

### Constraints

- Font size and mode are scoped to chapter reader only — global theme is unaffected.
- Mode MUST NOT change AppBar, bottom nav, or system UI chrome — only the reading surface.
- Settings MAY persist to local storage for cross-session retention.

### Acceptance Criteria

- [ ] Font increase/decrease buttons exist and change text size immediately.
- [ ] Sepia mode applies warm overlay, not just a color swap.
- [ ] Night mode applies dark background with readable contrast.
- [ ] Toggling modes does not lose scroll position.
- [ ] Settings overlay dismisses without affecting reader content.

---

## 2. reading-progress — New Capability

### Intent

Show the user where they are in the book ("Chapter X of Y") and persist scroll position per chapter so they resume exactly where they left off.

### Requirements

#### Requirement: Chapter position indicator

The reader MUST display a "Chapter {N} of {M}" label that updates when the user swipes between pages in the PageView.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| First chapter | book has 12 chapters, user is on page 0 | reader renders | label reads "Chapter 1 of 12" |
| After swipe | user swipes to page 5 | page transition completes | label reads "Chapter 6 of 12" |
| Single chapter | book has 1 chapter | reader renders | label reads "Chapter 1 of 1" |

#### Requirement: Scroll position persistence

The system SHALL save the scroll offset of each chapter when the user navigates away and restore it when returning to that chapter.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Save on navigate | user is at offset 450 in chapter 3 | user swipes to chapter 4 | offset 450 is stored for chapter 3 |
| Restore on return | chapter 3 has saved offset 450 | user swipes back to chapter 3 | chapter 3 content scrolls to offset 450 |
| First visit | chapter has no saved offset | user opens it | content starts at offset 0 (top) |
| No saved offset after scroll | user scrolls less than 50px | user navigates away | system SHOULD NOT save (debounce threshold) |

### Constraints

- Save operations MUST be debounced (at most once every 2s) to avoid jank on dispose.
- Scroll position data SHALL be stored per user + per chapter, in memory for session, persisted to local storage on navigation away.
- "Chapter X of Y" SHALL NOT block or overlap reading content.

### Acceptance Criteria

- [ ] Position label updates on every PageView page change.
- [ ] Scrolling a chapter, leaving, and returning restores the exact offset.
- [ ] Saving does not cause scroll jank or frame drops.

---

## 3. chapter-reads — Modified Capability

### Requirement: Mark chapter as read

When a user scrolls past 80% of a chapter's content in ChapterScreen, the system MUST insert a row into `chapter_reads`. The mark MUST fire at most once per chapter per session.
(Previously: mark was triggered on initState — when the chapter first loaded, regardless of scroll.)

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Scroll past threshold | user scrolls to 80%+ of chapter content | scroll position crosses 80% | `chapter_reads` row inserted (one time) |
| Partial scroll | user scrolls to 50% then leaves | user navigates away | `chapter_reads` row NOT inserted |
| Already read | user already read the chapter (row exists) | user scrolls past 80% again | no duplicate row (PK conflict ignored) |
| Re-read from top | user reopens a read chapter, scrolls to 80% | scroll crosses 80% | no error — already-read is idempotent |

### Acceptance Criteria

- [ ] Opening a chapter does NOT mark it as read — only scrolling past 80% does.
- [ ] Chapter_reads table behavior (PK, RLS, FK) from existing spec is unchanged.
- [ ] Mark fires exactly once per session per chapter.

---

## 4. TookScreen Visual — Infrastructure Spec

### Intent

Polish TookScreen: show cover image in a styled header, display a loading indicator while read statuses load, and render chapter titles with read/unread visual state.

### Requirements

#### Requirement: Styled header with cover

TookScreen MUST display the took cover image, took title, and took number in a styled header section.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Cover present | took has a coverUrl | screen renders | cover image shows in header |
| No cover | took has empty cover | screen renders | header shows placeholder or no image area |

#### Requirement: Loading indicator

TookScreen MUST show a loading state while fetching read chapter IDs.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Loading | read IDs are being fetched | screen initially renders | loading indicator (e.g., CircularProgressIndicator) is visible |
| Loaded | read IDs have been fetched | loading completes | indicator disappears, list renders |

#### Requirement: Styled chapter list

Chapter list MUST show each chapter's number and title with read status color (grey = read, white = unread), consistent with the existing chapter-reads spec.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Mixed status | chapters 1,3 read; 2,4 unread | list renders | chapters 1,3 show grey text; 2,4 show white |
| All unread | no chapters read | list renders | all titles white |

### Acceptance Criteria

- [ ] Header has cover image, took title, and took number.
- [ ] Loading spinner shows during `_loadingReadIds` phase.
- [ ] Chapter list uses theme text color with grey for read items.

---

## 5. Lazy Chapter Loading — Infrastructure Spec

### Intent

Replace the current "load all chapters upfront" (`Future.wait`) pattern with incremental loading: load the first chapter immediately, then preload adjacent chapters in the background.

### Requirements

#### Requirement: Incremental load

The Bloc MUST emit a loaded state for the first chapter immediately, then load remaining chapters in background tasks. The system MUST NOT block the UI waiting for all chapters.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| First chapter loads fast | book with 200 chapters | user opens ChapterScreen | chapter 1 content is shown without waiting for chapters 2-200 |
| Background load | first chapter is rendering | after initial render | chapters 2..N are loaded asynchronously |
| Buffer full | chapter 1 is rendered, chapters 2-5 are loaded | user swipes to chapter 3 | no loading delay |

#### Requirement: Adjacent preload

The system SHALL preload the next N chapters (N = 3 by default) ahead of the current position and clear chapters beyond N+2 when the user moves to a new page.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Preload next | user is at chapter 5, chapters 6-8 not yet loaded | after page settles | chapters 6, 7, 8 begin loading |
| Clear far chapters | user is at chapter 5, chapters 1-4 and 9+ loaded | user swipes to chapter 6 | chapters 1-3 are cleared from in-memory cache |
| Edge — last chapters | user is at chapter 198 of 200 | page settles | chapters 199-200 preload |

### Constraints

- The Bloc SHALL NOT re-emit the full chapter list on each background load — only new additions.
- Cache SHALL keep at most the current ±2 chapter buffer in memory.
- Failed loads for adjacent chapters MUST NOT block the current chapter.

### Acceptance Criteria

- [ ] Book with 200+ chapters opens ChapterScreen without timeout or OOM.
- [ ] Chapter 1 renders before chapters 2-200 finish loading.
- [ ] Swiping to an already-loaded chapter shows no loading state.

---

## 6. PageController / ScrollController Fix — Infrastructure Spec

### Intent

Fix two controller bugs: (1) PageController is recreated on every build instead of held as an instance variable, and (2) each PageView page needs its own ScrollController instead of sharing one.

### Requirements

#### Requirement: PageController as instance variable

The PageController MUST be created once (in `initState` or as a late final field) and reused across builds. The controller MUST NOT be re-instantiated on every `build()` call.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Single creation | ChapterScreen is constructed | widget builds multiple times | PageController is created once, same instance reused |
| Dispose | screen is popped | widget disposes | PageController is disposed cleanly |

#### Requirement: Per-page ScrollController

Each PageView page MUST have its own ScrollController. Pages SHALL NOT share a single ScrollController instance.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Independent scroll | page A at offset 200, page B at offset 0 | user scrolls page A | page B's offset remains 0 |
| Dispose per page | user swipes away from page 3 | old page is disposed | its ScrollController is disposed |
| Restore per page | user returns to a previously visited page | page rebuilds | ScrollController is created with the saved position from reading-progress |

### Constraints

- Each ScrollController MUST be disposed when its page is removed from the PageView.
- ScrollController creation/deferred init SHALL use the position from reading-progress persistence when available.

### Acceptance Criteria

- [ ] `PageController` is created exactly once per ChapterScreen lifecycle.
- [ ] Each PageView page scrolls independently — scrolling one does not affect others.
- [ ] No "ScrollController attached to multiple scroll views" error.
- [ ] `flutter analyze` passes with no unused controller variables.

---

## 7. Content Type Enum — Infrastructure Spec

### Intent

Replace the `_isStoragePath` string heuristic with an explicit `ContentType` enum on the chapter entity, eliminating fragile pattern matching on URL strings.

### Requirements

#### Requirement: ContentType enum

The system SHALL define a `ContentType` enum with at least two values: `storagePath` (for chapters whose content is a file path to local storage) and `inline` (for chapters whose content is inline text).

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Storage chapter | chapter entity has contentType = storagePath | reader resolves content | content is loaded from local storage path |
| Inline chapter | chapter entity has contentType = inline | reader resolves content | content is used directly as displayed text |
| Serialization roundtrip | chapter has contentType value | entity is serialized to JSON and back | contentType is preserved correctly |

#### Requirement: Remove _isStoragePath heuristic

All code that checks `_isStoragePath(content)` to determine content type MUST be replaced with the explicit enum check. The heuristic function SHALL be removed.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| No heuristic | codebase has _isStoragePath | grep for the function | returns no results |
| Explicit check | chapter entity loaded | code reads contentType | uses enum comparison, not string pattern match |

### Constraints

- The `ContentType` enum SHALL live on or alongside the chapter entity/model.
- Serialization (both JSON and any local cache format) MUST include the `contentType` field.
- Migration: existing chapters without a `contentType` field SHALL default to a value determined by migration logic (prefer `storagePath` for existing storage-based content).

### Acceptance Criteria

- [ ] `ContentType` enum exists and is used in `ChapterEntity`.
- [ ] `_isStoragePath` function is removed with no remaining references.
- [ ] Existing chapters render correctly after migration (no content type regression).