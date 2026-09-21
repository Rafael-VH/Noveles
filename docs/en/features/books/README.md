# Books

> Core domain entity — CRUD operations, visibility toggle, pagination, and view
tracking.

## Overview

The Books feature is the central entity of the application. It manages novel
metadata (title, author, cover, description, genre/label associations) and
provides paginated listing, single-book detail, visibility toggling, and image
upload. Books are loaded as `BookWithRelations` — a shared entity that flattens
genre, took, and label data for presentation.

## Data Model

**`BookEntity`** (`lib/features/books/domain/book_entity.dart`):

| Field | Type | Description |
| ------- | ------ | ------------- |
| `id` | `int` | Primary key |
| `createdAt` | `DateTime` | Creation timestamp |
| `cover` | `String` | Cover image URL/path |
| `name` | `String` | Book title |
| `short` | `String` | Short description |
| `alternative` | `String` | Alternative title |
| `description` | `String` | Full description |
| `authorId` | `int` | Author reference |
| `author` | `String` | Author name |
| `country` | `String` | Country of origin |
| `state` | `String` | Publication status |
| `type` | `String` | Book type/format |
| `release` | `String` | Release info |
| `tookCount` | `int` | Number of volumes (tooks) |
| `chapterCount` | `int` | Total chapter count |
| `source` | `String` | Source URL |
| `link` | `String` | External link |
| `isFavorite` | `bool` | Current user favorite status |
| `isVisible` | `bool` | Visibility to regular users |
| `listGenreIds` | `List<int>` | Associated genre IDs |
| `listTookIds` | `List<int>` | Associated took IDs |
| `listLabelIds` | `List<int>` | Associated label IDs |
| `createdBy` | `String?` | Creator user ID |

## Use Cases

| Use Case | Signature | Purpose |
| ---------- | ----------- | --------- |
| GetBooks | `FR<L<BWR>>` call({bool o}) | Paginated book listing |
| GetBookById | `FR<BWR?>` call(int id) | Single book with relations |
| ToggleBookVisibility | `FR<void>` call(int id) | Show/hide book from users |
| CreateBook | `FR<int>` call(BE book) | Create a new book |
| UpdateBook | `FR<void>` call(BE book) | Update book metadata |
| `DeleteBook` | `FR<void>` call(int id) | Delete a book |
| UploadImage | `FR<String>` call(String f) | Upload cover image to Storage |
| GetBookLabels | `FR<M<int,SE<int>>>` call(ids) | Batch label lookup |
| TrackBookView | `FR<void>` call(int id) | Increment view counter |
| GetRecentViews | `FR<L<BWR>>` call(String userId) | Recently viewed books |
| GetMostViewedBooks | `FR<L<BWR>>` call() | Globally most viewed books |

**Repository**: `BookRepository` → `BookRepositoryImpl` reads through the
`DataGateway`, whose six named aggregate reads resolve a book's relation tree
(authors, genres, labels, tooks, chapters) inside the adapter, and writes through
its two `rpc` functions. Authorization is not in the repository: the database's
RLS policies decide what each caller may see.

## BLoC

**`BookBloc`** (`lib/features/books/presentation/bloc/book_bloc.dart`):

| Event | Description |
| ------- | ------------- |
| `LoadBooks` | Load first page of books |
| `LoadMoreBooks` | Load next page (pagination) |
| `LoadBookById` | Load single book for detail view |

| State | Data | When |
| ------- | ------ | ------ |
| `BookInitial` | — | Initial state |
| `BookLoading` | — | Fetching data |
| `BookLoaded` | `List<BookWithRelations> books, bool hasMore` | Books loaded |
| `BookDetailLoaded` | `BookWithRelations book` | Single book loaded |
| `BookError` | `String message` | Error occurred |

**Page size**: 50 books per request.

## Screens

### BookScreen

**File**: `lib/features/books/presentation/screens/book_screen.dart`

- Book detail view with cover, metadata, took list, and genre chips
- Navigate to took detail and chapter reading

### Detail Views

**File**: `lib/features/books/presentation/views/detail/`

- Book detail sub-components (metadata, took list, etc.)

## Favorites

The Books feature includes a Favorites subsection at
`lib/features/books/favorites/` for managing per-user book favorites.

### FavoriteEntity

**File**: `lib/features/books/favorites/domain/favorite_entity.dart`

| Field | Type | Description |
| ------- | ------ | ------------- |
| `userId` | `String` | Authenticated user's UUID |
| `bookId` | `int` | Book ID being favorited |
| `createdAt` | `DateTime` | When the favorite was added |

### Repository Methods

| Method | Signature | Purpose |
| -------- | ----------- | --------- |
| toggleFavorite | `FR<bool>` call(uid,bid) | Add or remove favorite |
| getFavorites | `FR<L<FavoriteEntity>>` call(uid) | Get all favorites for user |
| isFavorite | `FR<bool>` call(uid,bid) | Check if book is favorited |

### FavoriteBloc

**File**: `lib/features/books/favorites/presentation/bloc/favorite_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `ToggleFavorite` | Toggle favorite status for a book |
| `LoadFavorites` | Load all favorites for the current user |
| `CheckFavoriteStatus` | Check if a specific book is favorited |

### UI Components

- **FavoritesScreen** (`lib/features/books/favorites/presentation/screens/favorites_screen.dart`)
  — Full-screen list of favorited books
- **FavoriteButton** (`lib/features/books/favorites/presentation/widgets/favorite_button.dart`)
  — IconButton that toggles favorite status

## DI Registration

**File**: `lib/features/books/di/injection_books.dart`

- `BookRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `BookBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `BookEntity` field details
- [Use Cases](../../domain/use-cases.md) — Books use case signatures
- [User Types](../../user-types/regular-user.md) — Who sees visible books
- [User Types](../../user-types/scan-user.md) — Who manages book content
- [User Types](../../user-types/admin-user.md) — Who controls visibility
- [Error Handling](../../architecture/error-handling.md) — `BookFailure`
- [Database](../../database/tables.md) — `books` table schema

← Back to [index](../../README.md)
