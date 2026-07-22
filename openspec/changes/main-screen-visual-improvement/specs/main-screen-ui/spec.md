# Main Screen UI — Phase 1 Specification

## Purpose

Modernize `MainScreen` with visually enriched sections: improved carousel, Novedades, Populares, and styled genre chips. Phase 1 covers purely presentational changes — no new BLoCs, repositories, or backend queries. All data comes from the existing `listBook` (already loaded via `BookBloc`) with client-side sorting.

## Requirements

### S1: Carousel with Page Indicator

The carousel MUST display a page indicator (dots) showing current page / total count beneath the carousel content. The carousel height MUST be responsive: 35% of viewport height with a minimum of 200px and maximum of 300px.

The active dot MUST use `Theme.of(context).colorScheme.primary` and be larger (1.5× the inactive dot size). Inactive dots MUST use `onSurfaceVariant` at 0.5 opacity. All dots MUST be circular.

The carousel MUST continue to display: cover image with gradient overlay, book name, author ("Autor {author}"), and label badges. Gradients MUST use `surface` → transparent (top to bottom).

#### Scenario: Carousel renders with page dots

- GIVEN `listBook` has 5 books
- WHEN the carousel renders
- THEN 5 dots appear below the carousel
- AND the first dot is highlighted with `primary` color at full size
- AND tapping a dot navigates to that page

#### Scenario: Carousel height adapts to screen

- GIVEN a device with 800px viewport height
- WHEN the carousel renders
- THEN its height is 280px (35% = 280px, clamped between 200-300)
- AND on a 400px viewport, height is 200px (clamped min)
- AND on a 1000px viewport, height is 300px (clamped max)

#### Scenario: Empty carousel

- GIVEN `listBook` is empty
- WHEN the carousel renders
- THEN no dots are shown (zero items)
- AND the widget does not throw

### S2: SectionHeader

A reusable header widget with optional icon, required title text, and optional "Ver todo" action button.

The widget MUST accept: `required String title`, `{IconData? icon}`, `{VoidCallback? onViewAll}`.

When `icon` is provided, it MUST display before the title using `colorScheme.primary`. When `onViewAll` is provided, a "Ver todo" text button MUST render at the trailing edge. When `onViewAll` is null, no button renders.

Layout MUST be a full-width row with 16px horizontal padding.

#### Scenario: Header with icon and view-all

- GIVEN `title = "Novedades"`, `icon = Icons.new_releases`, `onViewAll` is set
- WHEN the header renders
- THEN the icon displays in primary color
- THEN "Novedades" text displays next to the icon
- AND "Ver todo" button renders on the right
- AND tapping "Ver todo" calls `onViewAll`

#### Scenario: Header without icon or action

- GIVEN `title = "Populares"`, no icon, no `onViewAll`
- WHEN the header renders
- THEN only the title text displays
- AND no icon or button is visible

### S3: Novedades Section

A horizontal scrollable row of book cards showing the most recently added books.

The system MUST display books sorted by `createdAt` descending. If two books have the same `createdAt`, the system SHOULD sort by `id` descending as a tiebreaker. If `createdAt` is absent or unreliable, the system MUST fall back to sorting by `id` descending.

The section MUST show up to 6 books. If fewer than 6 exist, it MUST show all available without error.

Each card MUST navigate to `BookScreen` on tap, using the same `PageRouteBuilder` pattern as the existing carousel for visual consistency.

#### Scenario: Novedades displays recent books

- GIVEN `listBook` has 8 books with varied `createdAt` values
- WHEN the section renders
- THEN 6 books are shown, ordered by `createdAt` descending
- AND tapping a card navigates to `BookScreen`

#### Scenario: Novedades with fewer than 6 books

- GIVEN `listBook` has 3 books
- WHEN the section renders
- THEN all 3 books display
- AND no layout overflow occurs

#### Scenario: Novedades empty

- GIVEN `listBook` is empty
- WHEN the section renders
- THEN no books display (empty horizontal list, no error)

### S4: Populares Section

A vertical list of book cards sorted by popularity (most tooks first).

The system MUST sort books by `tookCount` descending. Books with `tookCount == 0` MUST appear at the end. When `tookCount` is equal, the system MUST sort by `chapterCount` descending as a secondary sort.

The section MUST show up to 6 books. Each card MUST be full-width with horizontal layout: cover image on the left (80×120px), book info on the right (name, author, "N tomos" badge).

Each card MUST navigate to `BookScreen` on tap.

#### Scenario: Populares displays by tookCount

- GIVEN `listBook` has 4 books: A(tookCount=10), B(tookCount=5), C(tookCount=0), D(tookCount=10, chapterCount=30)
- WHEN the section renders
- THEN order is A, D (secondary: chapterCount), B, C
- AND 4 cards display full-width

#### Scenario: Populares empty

- GIVEN `listBook` is empty
- WHEN the section renders
- THEN no cards display (empty container, no error)

### S5: GenreChipStyled

A styled chip widget for genre display with icon and color.

The widget MUST be a horizontally scrollable list of genre chips. Each chip MUST display: a representative `IconData` (left of the genre name), and the genre name text.

The system MUST use a static map `Map<String, IconData>` for genre-to-icon mapping covering at least: "Aventura" → `Icons.explore`, "Romance" → `Icons.favorite`, "Fantasía" → `Icons.auto_stories`, "Ciencia Ficción" → `Icons.rocket_launch`, "Terror" → `Icons.dangerous`, "Misterio" → `Icons.search`, "Comedia" → `Icons.emoji_emotions`, "Drama" → `Icons.theater_comedy`. Unknown genres MUST fall back to `Icons.book`.

The chip background MUST use `colorScheme.surfaceContainer` (inactive) or `colorScheme.primaryContainer` (if selected state is supported). Text and icon color MUST use `onSurfaceVariant`. Each chip MUST have 8px horizontal and 4px vertical padding with rounded corners (radius 20).

Each chip MUST be tappable, producing a ripple effect. On tap, the system MUST navigate to `GenreScreen` with the tapped genre, passing the same parameters as the existing implementation.

#### Scenario: Genre chips render with icons

- GIVEN genres = ["Aventura", "Romance", "UnknownGenre"]
- WHEN the section renders
- THEN chip 1 shows `Icons.explore` + "Aventura"
- AND chip 2 shows `Icons.favorite` + "Romance"
- AND chip 3 shows `Icons.book` + "UnknownGenre" (fallback icon)

#### Scenario: Genre chip tap navigates

- GIVEN a genre "Aventura"
- WHEN the chip is tapped
- THEN the app navigates to `GenreScreen(genre: "Aventura", books: listBook, coverUrlService: ...)`

#### Scenario: Empty genres list

- GIVEN the genre list is empty
- WHEN the section renders
- THEN no chips display (empty list, no error)

### S6: BookCardHorizontal

A reusable horizontal card for book display in lists.

The widget MUST accept: `required BookWithRelations book`, `required VoidCallback onTap`.

Layout: cover image on the left (80×120px, rounded corners radius 8), info column on the right with 12px padding. The info column MUST display: book name (`titleMedium`, bold), author (`bodySmall`, `onSurfaceVariant`), and optional label badges (up to 2, using `LabelBadge`).

Total card height MUST be 120px with full available width. Card MUST have rounded corners (radius 12), subtle elevation (3px shadow), and background from `colorScheme.surface`.

Tapping anywhere on the card MUST invoke `onTap`.

#### Scenario: BookCardHorizontal renders with labels

- GIVEN a book with name "B", author "A", and 3 labels
- WHEN the card renders
- THEN cover loads at 80×120px
- AND name displays as bold `titleMedium`
- AND author displays as `bodySmall` in `onSurfaceVariant`
- AND up to 2 label badges render
- AND card height is 120px

#### Scenario: BookCardHorizontal tap

- GIVEN a book card renders
- WHEN the user taps the card
- THEN `onTap` is called with the book

### S7: BookCardVertical

A reusable vertical card for horizontal scroll sections.

The widget MUST accept: `required BookWithRelations book`, `required VoidCallback onTap`.

Layout: cover image on top (full width, aspect ratio ~2:3, rounded top corners radius 8), info column below with 8px padding. Info MUST display: book name (2 lines max, ellipsis), author (1 line, `bodySmall`, `onSurfaceVariant`).

Card width MUST be 140px. Height is determined by content + cover aspect ratio. Card MUST have rounded corners (radius 8), subtle shadow.

Tapping the card MUST invoke `onTap`.

#### Scenario: BookCardVertical renders

- GIVEN a book with name and author
- WHEN the card renders
- THEN cover displays at 140px width with 2:3 aspect ratio
- AND name shows max 2 lines with ellipsis
- AND card has rounded corners with shadow

#### Scenario: BookCardVertical with long name

- GIVEN a book with a very long name (> 60 chars)
- WHEN the card renders
- THEN the name truncates with ellipsis after 2 lines

## Modified Requirements (MainScreen Layout)

### M1: MainScreen layout includes new sections

The `MainScreen._buildContent` method MUST render in this order below the `SliverAppBarHome`:
1. `SectionHeader("Novedades", icon: Icons.new_releases)` → `SizedBox(height: 200, child: ListView.builder(... BookCardVertical ...))`
2. `SectionHeader("Populares")` → `ListView.builder(... BookCardHorizontal ...)`
3. `SectionHeader("Géneros", icon: Icons.category)` → `GenreChipStyled`

The existing infinite-scroll loading indicator at the bottom MUST be preserved. The existing empty-state handling (`listBook.isEmpty`) MUST be preserved.

The system MUST sort `listBook` client-side for the Novedades and Populares sections using `sorted()` — no new BLoC or repository calls.

#### Scenario: MainScreen renders all sections

- GIVEN `listBook` with 20 books and genres loaded
- WHEN the screen builds
- THEN carousel renders first
- THEN "Novedades" section renders with 6 BookCardVertical items
- THEN "Populares" section renders with 6 BookCardHorizontal items
- THEN "Géneros" section renders with GenreChipStyled chips
- AND the loading indicator renders at the bottom if `hasMore` is true

#### Scenario: Existing error states preserved

- GIVEN `BookBloc` state is `BookError`
- WHEN the screen builds
- THEN the error view from existing behavior displays
- AND no new sections render (same as current behavior)

## Review Workload Forecast

| File | Change | Estimated Lines |
|------|--------|-----------------|
| `carousel_appbar_sliver.dart` | Modified | +30 / -10 |
| `main_screen.dart` | Modified | +40 / -15 |
| `core/presentation/widgets/section_header.dart` | New | +50 |
| `shared/presentation/widgets/book_card_horizontal.dart` | New | +60 |
| `shared/presentation/widgets/book_card_vertical.dart` | New | +55 |
| `shared/presentation/widgets/genre_chip_styled.dart` | New | +80 |
| **Total** | | **~315 lines** (+265, -25) |

The estimated total of ~315 changed lines is within a 400-line PR review budget. A single PR with 5 focused commits is appropriate:
1. Carousel indicator + responsive height
2. SectionHeader shared widget
3. BookCardVertical + Novedades section
4. BookCardHorizontal + Populares section
5. GenreChipStyled + MainScreen integration
