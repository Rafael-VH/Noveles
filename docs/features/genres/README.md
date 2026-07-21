# Genres

> Genre classification for books — CRUD operations with both BLoC and Cubit patterns.

## Overview

The Genres feature manages book genre categories. Genres are simple metadata entities (name + description) assigned to books. This feature uses two state management patterns: `GenreBloc` for admin CRUD operations and `GenreCubit` for read-only loading in the scan and main screens.

## Data Model

**`GenreEntity`** (`lib/features/genres/domain/genre_entity.dart`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Primary key |
| `createdAt` | `DateTime` | Creation timestamp |
| `name` | `String` | Genre name (e.g., "Romance", "Fantasy") |
| `description` | `String` | Genre description |

## Use Cases

| Use Case | Signature | Purpose |
|----------|-----------|---------|
| `GetGenre` | `Future<Result<List<GenreEntity>>> call()` | List all genres |
| `GetGenreById` | `Future<Result<GenreEntity?>> call(int id)` | Single genre |
| `CreateGenre` | `Future<Result<void>> call(GenreEntity genre)` | Create genre |
| `UpdateGenre` | `Future<Result<void}} call(GenreEntity genre)` | Update genre |
| `DeleteGenre` | `Future<Result<void>> call(int id)` | Delete genre |

**Repository**: `GenreRepository` → `GenreRepositoryImpl` queries the `genres` table.

## BLoC / Cubit

### GenreBloc (admin CRUD)

**File**: `lib/features/genres/presentation/bloc/genre_bloc.dart`

| Event | Description |
|-------|-------------|
| `LoadGenres` | Load all genres |
| `CreateGenreEvent` | Create a new genre |
| `UpdateGenreEvent` | Update genre |
| `DeleteGenreEvent` | Delete genre |

| State | Data | When |
|-------|------|------|
| `GenreInitial` | — | Initial |
| `GenreLoading` | — | Fetching |
| `GenreLoaded` | `List<GenreEntity> genres` | Loaded |
| `GenreError` | `String message` | Error |

### GenreCubit (read-only)

**File**: `lib/features/genres/presentation/genre_cubit.dart`

- Single method: `loadGenres()` → emits `GenreLoaded` or `GenreError`
- Used in `ScanBookEditScreen` and `MainScreen` for genre selector chips

## Screens

### GenreScreen

**File**: `lib/features/genres/presentation/screens/genre_screen.dart`

- Filtered book list for a specific genre
- Receives genre name and full book list as parameters

## DI Registration

**File**: `lib/core/di/injection_genres.dart`

- `GenreRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `GenreBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `GenreEntity` field details
- [Use Cases](../../domain/use-cases.md) — Genre use case signatures
- [Books](../../features/books/README.md) — Books have genre associations
- [Database](../../database/tables.md) — `genres` table schema

← Back to [index](../../README.md)
