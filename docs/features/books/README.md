# Books

> Core domain entity — CRUD operations, visibility toggle, pagination, and view tracking.

## Overview

The Books feature is the central entity of the application. It manages novel metadata (title, author, cover, description, genre/label associations) and provides paginated listing, single-book detail, visibility toggling, and image upload. Books are loaded as `BookWithRelations` — a shared entity that flattens genre, took, and label data for presentation.

## Data Model

**`BookEntity`** (`lib/features/books/domain/book_entity.dart`):

| Field | Type | Description |
|-------|------|-------------|
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
|----------|-----------|---------|
| `GetBooks` | `Future<Result<List<BookWithRelations>>> call({bool onlyVisible, int page, int pageSize})` | Paginated book listing |
| `GetBookById` | `Future<Result<BookWithRelations?>> call(int id)` | Single book with relations |
| `ToggleBookVisibility` | `Future<Result<void>> call(int bookId, bool isVisible)` | Show/hide book from users |
| `CreateBook` | `Future<Result<int>> call(BookEntity book)` | Create a new book |
| `UpdateBook` | `Future<Result<void>> call(BookEntity book)` | Update book metadata |
| `DeleteBook` | `Future<Result<void>> call(int id)` | Delete a book |
| `UploadImage` | `Future<Result<String>> call(String filePath)` | Upload cover image to Storage |
| `GetBookLabels` | `Future<Result<Map<int, Set<int>>>> call(List<BookEntity> books)` | Batch label lookup for books |
| `TrackBookView` | `Future<Result<void>> call(int bookId)` | Increment view counter |

**Repository**: `BookRepository` → `BookRepositoryImpl` uses Supabase queries with RLS policies.

## BLoC

**`BookBloc`** (`lib/features/books/presentation/bloc/book_bloc.dart`):

| Event | Description |
|-------|-------------|
| `LoadBooks` | Load first page of books |
| `LoadMoreBooks` | Load next page (pagination) |
| `LoadBookById` | Load single book for detail view |

| State | Data | When |
|-------|------|------|
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

## DI Registration

**File**: `lib/core/di/injection_books.dart`

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
