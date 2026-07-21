# Tooks

> Volume/archival units — chapters are grouped into tooks within a book.

## Overview

Tooks represent volumes or compiled editions of a book. Each book contains one or more tooks, and each took contains chapters. This three-level hierarchy (Book → Took → Chapter) allows organizing content into logical volumes with their own covers and metadata.

## Data Model

**`TookEntity`** (`lib/features/tooks/domain/took_entity.dart`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Primary key |
| `createdAt` | `DateTime` | Creation timestamp |
| `cover` | `String` | Volume cover image |
| `number` | `String` | Volume number (display string) |
| `title` | `String` | Volume title |
| `chapterCount` | `int` | Number of chapters in this volume |
| `bookId` | `int` | Parent book ID |
| `listChapterIds` | `List<int>` | Chapter IDs belonging to this took |
| `createdBy` | `String?` | Creator user ID |

## Use Cases

| Use Case | Signature | Purpose |
|----------|-----------|---------|
| `GetTooks` | `Future<Result<List<TookEntity>>> call()` | List all tooks |
| `GetTooksByBook` | `Future<Result<List<TookEntity>>> call(int bookId)` | List tooks for a specific book |
| `GetTookById` | `Future<Result<TookEntity?>> call(int id)` | Single took |
| `CreateTook` | `Future<Result<int>> call(TookEntity took)` | Create a new took |
| `UpdateTook` | `Future<Result<void>> call(TookEntity took)` | Update took metadata |
| `DeleteTook` | `Future<Result<void>> call(int id)` | Delete a took |

**Repository**: `TookRepository` → `TookRepositoryImpl` queries the `tooks` table.

## Screens

### TookScreen

**File**: `lib/features/tooks/presentation/screens/took_screen.dart`

- Displays took metadata and chapter list
- Navigate to individual chapters

### TookView

**File**: `lib/features/tooks/presentation/views/took_view.dart`

- Took card/compact view used in book detail screens

No dedicated BLoC — tooks are managed through the `ScanTookBloc` (scan feature) and loaded as part of `BookWithRelations` for reading views.

## DI Registration

**File**: `lib/core/di/injection_tooks.dart`

- `TookRepository` → `LazySingleton`
- All use cases → `LazySingleton`

## Related

- [Entities](../../domain/entities.md) — `TookEntity` field details
- [Use Cases](../../domain/use-cases.md) — Took use case signatures
- [Books](../../features/books/README.md) — Parent entity
- [Chapters](../../features/chapters/README.md) — Child entity
- [User Types](../../user-types/scan-user.md) — Took management
- [Database](../../database/tables.md) — `tooks` table schema

← Back to [index](../../README.md)
