# Favorites

> Personal favorites per user — toggle, list, and check favorite status.

## Overview

The Favorites feature allows authenticated users to manage their personal book favorites. Users can add/remove books from their favorites list and view all favorited books. The feature uses the `user_favorites` Supabase table with user-scoped RLS policies.

## Data Model

**FavoriteEntity** (`lib/features/favorites/domain/favorite_entity.dart`):

| Field | Type | Description |
|-------|------|-------------|
| `userId` | `String` | Authenticated user's UUID |
| `bookId` | `int` | Book ID being favorited |
| `createdAt` | `DateTime` | When the favorite was added |

## Repository

**FavoriteRepository** (`lib/features/favorites/domain/favorite_repository.dart`):

| Method | Signature | Purpose |
|--------|-----------|---------|
| `toggleFavorite` | `Future<Result<bool>> toggleFavorite(String userId, int bookId)` | Add or remove a favorite (returns new state) |
| `getFavorites` | `Future<Result<List<FavoriteEntity>>> getFavorites(String userId)` | Get all favorites for a user |
| `isFavorite` | `Future<Result<bool>> isFavorite(String userId, int bookId)` | Check if a book is favorited |

**Implementation**: `lib/features/favorites/data/favorite_repository_impl.dart` — uses Supabase client to query `user_favorites` table.

## BLoC

**FavoriteBloc** (`lib/features/favorites/presentation/bloc/favorite_bloc.dart`):

| Event | Description |
|-------|-------------|
| `ToggleFavorite` | Toggle favorite status for a book |
| `LoadFavorites` | Load all favorites for the current user |
| `CheckFavoriteStatus` | Check if a specific book is favorited |

| State | Data | When |
|-------|------|------|
| `FavoriteInitial` | — | Initial state |
| `FavoriteLoading` | — | While fetching data |
| `FavoriteToggled` | `bool isFavorite` | After toggle completes |
| `FavoriteLoaded` | `List<FavoriteEntity> favorites` | After loading favorites |
| `FavoriteStatusChecked` | `bool isFavorite` | After status check |
| `FavoriteError` | `String message` | On error |

## UI

### FavoritesScreen

**File**: `lib/features/favorites/presentation/screens/favorites_screen.dart`

- Full-screen list of favorited books
- Shows book cover, title, and author
- Loading and error states with retry button
- Empty state message when no favorites exist

### FavoriteButton

**File**: `lib/features/favorites/presentation/widgets/favorite_button.dart`

- `IconButton` that toggles favorite status
- Shows filled heart when favorited, outlined when not
- Used in book detail screens and list items

## DI Registration

**File**: `lib/core/di/injection_favorites.dart`

- `FavoriteRepository` → `LazySingleton`
- `FavoriteBloc` → `Factory` (new instance per widget tree)

No use case classes — BLoC calls repository methods directly.

## Related

- [Entities](../../domain/entities.md) — `FavoriteEntity` field details
- [Use Cases](../../domain/use-cases.md) — Favorites repository methods
- [User Types](../../user-types/regular-user.md) — Who can use favorites
- [Error Handling](../../architecture/error-handling.md) — `FavoriteFailure` type

← Back to [index](../../README.md)