# Scan

> Content creator panel — book, took, and chapter management for scan-role
users.

## Overview

The Scan feature is the content creation interface for users with the `scan`
role. It provides full CRUD for books, tooks (volumes), and chapters, including
image upload and file-based chapter content. Unlike other features, scan has
**no domain or data layers** — it operates entirely at the presentation layer,
reusing use cases from the `books`, `tooks`, `chapters`, and `genres` features.

## Architecture Note

The scan feature is **presentation-only**:

- No `lib/features/scan/domain/` directory
- No `lib/features/scan/data/` directory
- BLoCs directly call use cases from other features (e.g., `CreateBook`,
`UpdateTook`)
- This keeps scan as a thin orchestration layer over existing domain logic

## BLoCs

### ScanBookBloc

**File**: `lib/features/scan/presentation/bloc/scan_book_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `LoadScanBooks` | Load all books (including hidden) |
| `SaveScanBook` | Create or update a book |
| `DeleteScanBook` | Delete a book |
| `ToggleScanBookVisibility` | Toggle book visibility for users |

| State | Data | When |
| ------- | ------ | ------ |
| `ScanBookInitial` | — | Initial |
| `ScanBookLoading` | — | Processing |
| `ScanBookLoaded` | `List<BookWithRelations> books, String? message` | Loaded |
| `ScanBookError` | `String message` | Error |

**Dependencies**: `GetBooks`, `CreateBook`, `UpdateBook`, `DeleteBook`,
`ToggleBookVisibility` (from books feature).

### ScanTookBloc

**File**: `lib/features/scan/presentation/bloc/scan_took_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `SaveScanTook` | Create or update a took |
| `DeleteScanTook` | Delete a took |
| `UploadTookCover` | Upload cover image for a took |

| State | Data | When |
| ------- | ------ | ------ |
| `ScanTookInitial` | — | Initial |
| `ScanTookLoading` | — | Processing |
| `ScanTookLoaded` | `String? message` | Completed |
| `ScanTookCoverUploaded` | `String url` | Cover uploaded |
| `ScanTookError` | `String message` | Error |

**Dependencies**: `CreateTook`, `UpdateTook`, `DeleteTook` (from tooks),
`UploadImage` (from books).

### ScanChapterBloc

**File**: `lib/features/scan/presentation/bloc/scan_chapter_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `SaveScanChapter` | Create or update a chapter |
| `DeleteScanChapter` | Delete a chapter |
| `UploadChapterFile` | Upload .md/.txt content file |

| State | Data | When |
| ------- | ------ | ------ |
| `ScanChapterInitial` | — | Initial |
| `ScanChapterLoading` | — | Processing |
| `ScanChapterLoaded` | `String? message` | Completed |
| `ScanChapterContentUploaded` | `String url` | Content uploaded |
| `ScanChapterError` | `String message` | Error |

**Dependencies**: `CreateChapter`, `UpdateChapter`, `DeleteChapter` (from
chapters), `UploadChapterContent`.

### ScanCoverBloc

**File**: `lib/features/scan/presentation/bloc/scan_cover_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `UploadScanCover` | Upload a cover image |

| State | Data | When |
| ------- | ------ | ------ |
| `ScanCoverInitial` | — | Initial |
| `ScanCoverUploading` | — | Uploading |
| `ScanCoverUploaded` | `String url` | Upload complete |
| `ScanCoverError` | `String message` | Error |

**Dependencies**: `UploadImage` (from books).

## Screens

### ScanMainScreen

**File**: `lib/features/scan/presentation/screens/scan_main_screen.dart`

- Book list with visibility toggle switches
- Edit/delete actions per book
- FAB to create new book
- Uses `AppDrawer` with scan-specific navigation

### ScanBookEditScreen

**File**: `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`

- Full book form: title, author, cover, genres, description
- Genre selector (uses `GenreCubit`)
- Took list section — navigate to took edit
- Cover picker (uses `ScanCoverBloc`)

### ScanTookEditScreen

**File**: `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`

- Took form: number, title, cover
- Chapter list section — navigate to chapter edit
- Cover picker (uses `ScanTookBloc`)

### ScanChapterEditScreen

**File**: `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

- Chapter form: number, title, content
- File upload for .md/.txt content (uses `ScanChapterBloc`)
- Inline content editing

## DI Registration

**File**: `lib/core/di/injection_scan.dart`

- `ScanBookBloc` → `Factory`
- `ScanCoverBloc` → `Factory`
- `GenreCubit` → `Factory`
- `ScanTookBloc` → `Factory`
- `ScanChapterBloc` → `Factory`

All BLoCs receive use cases from other features via GetIt — scan has no
repository of its own.

## Related

- [Books](../../features/books/README.md) — Book use cases reused by scan
- [Tooks](../../features/tooks/README.md) — Took use cases reused by scan
- [Chapters](../../features/chapters/README.md) — Chapter use cases reused by
scan
- [Genres](../../features/genres/README.md) — Genre selector (GenreCubit)
- [User Types](../../user-types/scan-user.md) — Scan role permissions
- [Routing](../../architecture/routing.md) — Scan home screen selection

← Back to [index](../../README.md)
