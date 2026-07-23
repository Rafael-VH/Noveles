# Domain Entities

> Complete catalog of all 10 domain entities with field definitions and
relationships.

← [Back to index](../README.md)

## Entity Summary

| Entity | File | Fields | Feature |
| -------- | ------ | -------- | --------- |
| `BookEntity` | `lib/features/books/domain/book_entity.dart` | 22 | books |
| `BookWithRelations` | `book_with_relations.dart` | 25 (+3 lists) | shared |
| `ChapterEntity` | `chapter_entity.dart` | 7 | chapters |
| `ChapterRef` | `chapter_ref.dart` | 5 | chapters |
| `TookEntity` | `lib/features/tooks/domain/took_entity.dart` | 9 | tooks |
| `GenreEntity` | `lib/features/genres/domain/genre_entity.dart` | 4 | genres |
| `LabelEntity` | `lib/features/labels/domain/label_entity.dart` | 4 | labels |
| `LabelRuleEntity` | `label_rule_entity.dart` | 6 (+1 enum) | label_rules |
| `UserEntity` | `user_entity.dart` | 6 (+4 getters) | profiles |
| `FavoriteEntity` | `favorite_entity.dart` | 3 | favorites |

## BookEntity

**File**: `lib/features/books/domain/book_entity.dart`
**Extends**: `Equatable`

The core book entity — contains only scalar fields and relation IDs. No imports
from other features.

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `cover` | `String` | No | Cover image URL |
| `name` | `String` | No | Book title |
| `short` | `String` | No | Short description / tagline |
| `alternative` | `String` | No | Alternative title |
| `description` | `String` | No | Full description |
| `authorId` | `int` | No | Foreign key to author |
| `author` | `String` | No | Author name (denormalized) |
| `country` | `String` | No | Country of origin |
| `state` | `String` | No | Publishing state |
| `type` | `String` | No | Book type/genre category |
| `release` | `String` | No | Release date string |
| `tookCount` | `int` | No | Number of tooks (volumes) |
| `chapterCount` | `int` | No | Total chapter count |
| `source` | `String` | No | Content source |
| `link` | `String` | No | External link |
| `isFavorite` | `bool` | No | Current user's favorite status |
| `isVisible` | `bool` | No | Visibility toggle (admin/scan) |
| `listGenreIds` | `List<int>` | No | Genre IDs (default: `[]`) |
| `listTookIds` | `List<int>` | No | Took IDs (default: `[]`) |
| `listLabelIds` | `List<int>` | No | Label IDs (default: `[]`) |
| `createdBy` | `String?` | **Yes** | User ID of creator |

## BookWithRelations

**File**: `lib/shared/domain/entities/book_with_relations.dart`
**Extends**: `BookEntity`

Book entity with fully hydrated relation objects. Used when Supabase returns
joined data (genres, labels, tooks). This is the type the UI works with for
rendering.

Inherits all 22 fields from `BookEntity` plus:

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `listGenre` | `List<GenreEntity>` | No | Full genre objects (default: `[]`) |
| `listTook` | `List<TookEntity>` | No | Full took objects (default: `[]`) |
| `listLabel` | `List<LabelEntity>` | No | Full label objects (default: `[]`) |

## ChapterEntity

**File**: `lib/features/chapters/domain/chapter_entity.dart`
**Extends**: `Equatable`

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `number` | `String` | No | Chapter number (string, e.g. "1", "1.5") |
| `title` | `String` | No | Chapter title |
| `content` | `String` | No | Content URL (points to Supabase Storage) |
| `tookId` | `int` | No | Foreign key to parent Took |
| `createdBy` | `String?` | **Yes** | User ID of creator |

## ChapterRef

**File**: `lib/features/chapters/domain/chapter_ref.dart`
**Extends**: `Equatable`

Lightweight reference for chapter events. Carries only the fields needed to
initiate content loading, avoiding the cost of passing full `ChapterEntity`
objects through the event bus.

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Chapter ID |
| `content` | `String` | No | Content URL |
| `number` | `String` | No | Chapter number |
| `title` | `String` | No | Chapter title |
| `tookId` | `int` | No | Foreign key to parent Took |

**Factory**: `ChapterRef.fromEntity(ChapterEntity entity)` — creates a ref from
a full entity.

## TookEntity

**File**: `lib/features/tooks/domain/took_entity.dart`
**Extends**: `Equatable`

A "took" represents a volume or tome within a book. Books contain multiple
tooks, and each took contains multiple chapters.

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `cover` | `String` | No | Cover image URL |
| `number` | `String` | No | Volume number (string) |
| `title` | `String` | No | Volume title |
| `chapterCount` | `int` | No | Number of chapters in this took |
| `bookId` | `int` | No | Foreign key to parent Book |
| `listChapterIds` | `List<int>` | No | Chapter IDs (default: `[]`) |
| `createdBy` | `String?` | **Yes** | User ID of creator |

## GenreEntity

**File**: `lib/features/genres/domain/genre_entity.dart`
**Extends**: `Equatable`

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `name` | `String` | No | Genre name |
| `description` | `String` | No | Genre description |

## LabelEntity

**File**: `lib/features/labels/domain/label_entity.dart`
**Extends**: `Equatable`

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `name` | `String` | No | Label name |
| `color` | `String` | No | Label color (hex or name) |

## LabelRuleEntity

**File**: `lib/features/label_rules/domain/label_rule_entity.dart`
**Extends**: `Equatable`

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `int` | No | Primary key |
| `labelId` | `int` | No | FK → labels(id) |
| `ruleType` | `LabelRuleType` | No | Enum (4 values) |
| `params` | `Map<String, dynamic>` | No | JSON config parameters |
| `createdAt` | `DateTime` | No | Creation timestamp |
| `updatedAt` | `DateTime` | No | Last update timestamp |

### LabelRuleType Enum

**File**: `lib/features/label_rules/domain/label_rule_entity.dart`

| Value | Display Name | Description |
| ------- | ------------- | ------------- |
| `newRelease` | Novedad | Books newer than N days |
| `mostRead` | Más leídos | Top N by views in period |
| `mostPopular` | Más populares | Top N by took/chapter count |
| `mostFavorited` | Más favoritos | Top N by user favorites |

## UserEntity

**File**: `lib/features/profiles/domain/user_entity.dart`
**Extends**: `Equatable`

### Stored Fields

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `id` | `String` | No | Supabase Auth UUID |
| `email` | `String` | No | User email |
| `role` | `UserRole` | No | Role enum (`user`, `scan`, `admin`, `suspended`) |
| `displayName` | `String?` | **Yes** | Display name |
| `bio` | `String?` | **Yes** | User biography |
| `avatarUrl` | `String?` | **Yes** | Avatar image URL |

### Computed Getters

| Getter | Return Type | Logic |
| -------- | ------------- | ------- |
| `isScan` | `bool` | `role == UserRole.scan` |
| `isAdmin` | `bool` | `role == UserRole.admin` |
| `isUser` | `bool` | `role == UserRole.user` |
| `isSuspended` | `bool` | `role == UserRole.suspended` |

### UserRole Enum

**File**: `lib/features/profiles/domain/user_role.dart`

```dart
enum UserRole {
  user,
  scan,
  admin,
  suspended;

  static UserRole fromString(String? role) { ... }
}
```text

`UserRole.fromString()` parses DB string values. Unknown or null values default
to `UserRole.user`.

## FavoriteEntity

**File**: `lib/features/favorites/domain/favorite_entity.dart`
**Extends**: `Equatable`

| Field | Dart Type | Nullable | Description |
| ------- | ----------- | ---------- | ------------- |
| `userId` | `String` | No | Supabase Auth UUID of the user |
| `bookId` | `int` | No | Foreign key to the book |
| `createdAt` | `DateTime` | No | When the favorite was added |

## Relationships

```text
UserEntity ──(createdBy)──→ BookEntity
                              │
                              ├──(listTookIds)──→ TookEntity ──(bookId)──→ BookEntity
                              │                       │
                              │                       └──(listChapterIds)──→ ChapterEntity
                              │                              ──(tookId)──→ TookEntity
                              │
                              ├──(listGenreIds)──→ GenreEntity
                              │                     (many-to-many via books_genres)
                              │
                              └──(listLabelIds)──→ LabelEntity
                                                   (many-to-many via books_labels)

UserEntity ──(userId)──→ FavoriteEntity ──(bookId)──→ BookEntity

LabelRuleEntity ──(labelId)──→ LabelEntity
```text

### Join Tables (Supabase)

| Join Table | Columns | Relationship |
| ------------ | --------- | ------------- |
| `books_genres` | `book_id`, `genre_id` | Book ↔ Genre (many-to-many) |
| `books_labels` | `book_id`, `label_id` | Book ↔ Label (many-to-many) |
| `favorites` | `user_id`, `book_id` | User ↔ Book (many-to-many, unique) |

---

> Last verified: 2026-07-21
