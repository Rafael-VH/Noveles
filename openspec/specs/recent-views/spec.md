# RecentViews Specification

## Purpose

The RecentViews feature shows the authenticated user's last visited books in a "Continuar leyendo" section on MainScreen. Reading progress is tracked via the `chapter_reads` table, enabling direct navigation to the last chapter read.

## Requirements

### Requirement: RPC — get_user_recent_views

The system SHALL create a SECURITY DEFINER function `get_user_recent_views(uid uuid, max_results int)` returning book IDs from `book_views`, ordered by `book_views.viewed_at DESC`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Has views | user has rows in `book_views` | function called with max_results=6 | returns books with relations, sorted by recent |
| Empty | user has no rows | function called | returns empty set |

### Requirement: Auth-aware query

If no authenticated user exists, the system MUST NOT query the database and MUST treat the section as empty.

#### Scenario: Unauthenticated user

- GIVEN no authenticated user
- WHEN MainScreen builds RecentViews
- THEN the section renders as invisible (no query fired)

#### Scenario: Authenticated user

- GIVEN an authenticated user with id "abc"
- WHEN `getRecentViews("abc")` is called
- THEN the RPC function is invoked with `uid = "abc"`

### Requirement: Repository method

`BookRepository` MUST expose `Future<Result<List<BookWithRelations>>> getRecentViews(String userId)`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Happy path | user has recent views | `getRecentViews(userId)` called | returns books ordered by recent view |
| RPC failure | network error | `getRecentViews(userId)` called | returns `Err` with message |

### Requirement: Use case — GetRecentViews

The `GetRecentViews` use case MUST call `BookRepository.getRecentViews(userId)`. It SHALL do nothing if `userId` is null.

#### Scenario: Delegates to repository

- GIVEN `userId = "abc"`
- WHEN `GetRecentViews("abc")` is called
- THEN repository's `getRecentViews` is invoked with "abc"

### Requirement: Modificación de TrackBookView

`TrackBookView.call` MUST accept optional `tookId` and `chapterId` parameters and pass them to `repository.trackBookView(bookId, tookId: tookId, chapterId: chapterId)`. Existing callers SHALL continue to work by passing null.

#### Scenario: Null params

- GIVEN caller invokes `TrackBookView(bookId)` without tookId/chapterId
- WHEN the use case executes
- THEN `trackBookView(bookId, tookId: null, chapterId: null)` is called

### Requirement: Bloc — RecentViewsBloc

The system SHALL provide `RecentViewsBloc` emitting `RecentViewsInitial`, `RecentViewsLoading`, `RecentViewsLoaded`, `RecentViewsEmpty`, or `RecentViewsError`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Load with data | use case returns books | `LoadRecentViews` dispatched | emits Loading → Loaded(books) |
| Load empty | use case returns empty | `LoadRecentViews` dispatched | emits Loading → Empty |
| Load error | use case returns Err | `LoadRecentViews` dispatched | emits Loading → Error(msg) |

### Requirement: Widget — SectionRecentViews

`SectionRecentViews` MUST render a horizontal scroll row of `BookCardVertical` cards. It MUST render `SizedBox.shrink()` when empty.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Books available | `RecentViewsLoaded` with 4 books | widget builds | shows header "Continuar leyendo" + 4 cards |
| Empty state | `RecentViewsEmpty` | widget builds | renders `SizedBox.shrink()` |

### Requirement: Navigation

A card tap MUST navigate to `ChapterScreen(bookId, tookId, chapterId)` when `last_chapter_id` is not null. It SHALL fall back to `BookScreen(book)`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Chapter tracked | view has `last_chapter_id` | user taps card | navigates to ChapterScreen |
| No chapter | `last_chapter_id` is null | user taps card | navigates to BookScreen |
