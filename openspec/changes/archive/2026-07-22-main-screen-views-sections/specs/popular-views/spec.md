# PopularViews Specification

## Purpose

The PopularViews ("Más vistos") feature shows the most viewed books globally, aggregated from `book_views`, as a horizontal scroll section on MainScreen.

## Requirements

### Requirement: RPC — get_most_viewed_books

The system SHALL create a SECURITY DEFINER function `get_most_viewed_books(max_results int)` returning books joined from `book_views`, grouped by book, ordered by count DESC.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Books with views | books have rows in `book_views` | `get_most_viewed_books(6)` called | returns books sorted by view count DESC |
| Empty | `book_views` has no rows | function called | returns empty set |

### Requirement: Auth independence

This feature MUST work without authentication. The section SHALL render for any user, including unauthenticated ones.

#### Scenario: Unauthenticated user sees section

- GIVEN no authenticated user
- WHEN MainScreen builds PopularViews
- THEN the section queries the database and renders normally

### Requirement: Repository method

`BookRepository` MUST expose `Future<Result<List<BookWithRelations>>> getMostViewedBooks()`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Happy path | books have view counts | `getMostViewedBooks()` called | returns books ordered by view count DESC |
| RPC failure | network error | `getMostViewedBooks()` called | returns `Err` with message |

### Requirement: Use case — GetMostViewedBooks

The `GetMostViewedBooks` use case MUST call `BookRepository.getMostViewedBooks()` and return the result.

#### Scenario: Normal execution

- GIVEN repository returns books
- WHEN `GetMostViewedBooks()` is called
- THEN it returns `Ok(List<BookWithRelations>)`

### Requirement: Bloc — PopularViewsBloc

The system SHALL provide `PopularViewsBloc` emitting `PopularViewsInitial`, `PopularViewsLoading`, `PopularViewsLoaded`, `PopularViewsEmpty`, or `PopularViewsError`.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Load with data | use case returns books | `LoadPopularViews` dispatched | emits Loading → Loaded(books) |
| Load empty | use case returns empty | `LoadPopularViews` dispatched | emits Loading → Empty |
| Load error | use case returns Err | `LoadPopularViews` dispatched | emits Loading → Error(msg) |

### Requirement: Widget — SectionMasVistos

`SectionMasVistos` MUST render a horizontal scroll row of `BookCardVertical` cards. It MUST render `SizedBox.shrink()` when empty.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Books available | `PopularViewsLoaded` with 5 books | widget builds | shows header "Más vistos" + 5 cards |
| Empty state | `PopularViewsEmpty` | widget builds | renders `SizedBox.shrink()` |

### Requirement: Navigation

A card tap MUST navigate to `BookScreen(book)`.

#### Scenario: Card tapped

- GIVEN `PopularViewsLoaded` with books
- WHEN user taps a card
- THEN the system navigates to `BookScreen(book)` for the tapped book
