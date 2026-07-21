# Chapters

> Individual chapter entities — CRUD, content upload/download, and reading
screen.

## Overview

The Chapters feature manages individual chapters within a took (volume).
Chapters have text content that can be either inline or uploaded as a file to
Supabase Storage. The reading screen provides a scrollable text view with
chapter navigation.

## Data Model

**`ChapterEntity`** (`lib/features/chapters/domain/chapter_entity.dart`):

| Field | Type | Description |
| ------- | ------ | ------------- |
| `id` | `int` | Primary key |
| `createdAt` | `DateTime` | Creation timestamp |
| `number` | `String` | Chapter number (display string) |
| `title` | `String` | Chapter title |
| `content` | `String` | Chapter text content (inline or storage URL) |
| `tookId` | `int` | Parent took ID |
| `createdBy` | `String?` | Creator user ID |

**`ChapterRef`** (`lib/features/chapters/domain/chapter_ref.dart`):

Lightweight reference used in BLoC events — carries `id`, `content`, `number`,
`title`, `tookId` to avoid passing full entities through the event bus.

## Use Cases

| Use Case | Signature | Purpose |
| ---------- | ----------- | --------- |
| GetChapters | `FR<L<CE>>` call({int off}) | Paginated chapter listing |
| GetChapterById | `FR<CE?>` call(int id) | Single chapter |
| GetChapterContent | `FR<String>` call(String p) | Download or return inline |
| CreateChapter | `FR<int>` call(CE ch) | Create a new chapter |
| UpdateChapter | `FR<void>` call(CE ch) | Update chapter metadata |
| `DeleteChapter` | `FR<void>` call(int id) | Delete a chapter |
| UploadContent | `FR<String>` call(String f) | Upload .md/.txt to Storage |

**Repository**: `ChapterRepository` → `ChapterRepositoryImpl`. `downloadContent`
determines if a path is a storage reference or inline text.

## BLoC

**`ChapterBloc`** (`lib/features/chapters/presentation/bloc/chapter_bloc.dart`):

| Event | Description |
| ------- | ------------- |
| `LoadChapters` | Load chapter list |
| `LoadChapterContent` | Load and display chapter text |
| `NavigateChapter` | Move to next/previous chapter |

| State | Data | When |
| ------- | ------ | ------ |
| `ChapterInitial` | — | Initial state |
| `ChapterLoading` | — | Fetching data |
| `ChaptersLoaded` | `List<ChapterEntity> chapters` | Chapter list loaded |
| ChapterContentLoaded | ChapterEntity chapter,String ... | Reading view ready |
| `ChapterError` | `String message` | Error occurred |

## Screens

### ChapterScreen

**File**: `lib/features/chapters/presentation/screens/chapter_screen.dart`

- Scrollable text reading view
- Chapter navigation (previous/next)
- Title and number display

## DI Registration

**File**: `lib/core/di/injection_chapters.dart`

- `ChapterRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `ChapterBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `ChapterEntity`, `ChapterRef` field
details
- [Use Cases](../../domain/use-cases.md) — Chapter use case signatures
- [User Types](../../user-types/regular-user.md) — Chapter reading
- [User Types](../../user-types/scan-user.md) — Chapter creation
- [Database](../../database/tables.md) — `chapters` table schema
- [Database](../../database/storage.md) — Chapter content storage

← Back to [index](../../README.md)
