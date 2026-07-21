# Use Cases

> 46 use case classes across 9 features, plus 6 repository methods for Favorites and Admin.

## Overview

Each use case is a single-responsibility class that orchestrates a specific business operation. They receive a repository via constructor injection and expose a `call()` method returning `Future<Result<T>>`.

**Pattern**:
```dart
class Login {
  final AuthRepository repository;
  Login(this.repository);
  Future<Result<UserEntity>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
```

## Auth (5 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `Login` | `lib/features/auth/domain/use_cases/login.dart` | `call(String email, String password)` | `Future<Result<UserEntity>>` |
| `Register` | `lib/features/auth/domain/use_cases/register.dart` | `call(String email, String password)` | `Future<Result<UserEntity>>` |
| `Logout` | `lib/features/auth/domain/use_cases/logout.dart` | `call()` | `Future<Result<void>>` |
| `GetCurrentUser` | `lib/features/auth/domain/use_cases/get_current_user.dart` | `call()` | `Future<Result<UserEntity?>>` |
| `ListenAuthState` | `lib/features/auth/domain/use_cases/listen_auth_state.dart` | `call()` | `Stream<AuthEvent>` |

## Books (10 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetBooks` | `lib/features/books/domain/get_book.dart` | `call({bool onlyVisible, int page, int pageSize})` | `Future<Result<List<BookWithRelations>>>` |
| `GetBookById` | `lib/features/books/domain/get_book_by_id.dart` | `call(int id)` | `Future<Result<BookWithRelations?>>` |
| `CreateBook` | `lib/features/books/domain/create_book.dart` | `call(BookEntity book)` | `Future<Result<int>>` |
| `UpdateBook` | `lib/features/books/domain/update_book.dart` | `call(BookEntity book)` | `Future<Result<void>>` |
| `DeleteBook` | `lib/features/books/domain/delete_book.dart` | `call(int id)` | `Future<Result<void>>` |
| `UploadImage` | `lib/features/books/domain/upload_image.dart` | `call(String filePath)` | `Future<Result<String>>` |
| `GetBooksByGenre` | `lib/features/books/domain/get_books_by_genre.dart` | `call(List<BookWithRelations> books, String genre)` | `List<BookWithRelations>` |
| `ToggleBookVisibility` | `lib/features/books/domain/toggle_book_visibility.dart` | `call(int bookId, bool isVisible)` | `Future<Result<void>>` |
| `GetBookLabels` | `lib/features/books/domain/get_book_labels.dart` | `call(List<BookEntity> books)` | `Future<Result<Map<int, Set<int>>>>` |
| `TrackBookView` | `lib/features/books/domain/track_book_view.dart` | `call(int bookId)` | `Future<Result<void>>` |

**Note**: `GetBooksByGenre` is a pure in-memory filter (no repository call), returns `List<BookWithRelations>` directly.

## Chapters (7 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetChapter` | `lib/features/chapters/domain/get_chapter.dart` | `call()` | `Future<Result<List<ChapterEntity>>>` |
| `GetChapterById` | `lib/features/chapters/domain/get_chapter_by_id.dart` | `call(int id)` | `Future<Result<ChapterEntity?>>` |
| `CreateChapter` | `lib/features/chapters/domain/create_chapter.dart` | `call(ChapterEntity chapter)` | `Future<Result<int>>` |
| `UpdateChapter` | `lib/features/chapters/domain/update_chapter.dart` | `call(ChapterEntity chapter)` | `Future<Result<void>>` |
| `DeleteChapter` | `lib/features/chapters/domain/delete_chapter.dart` | `call(int id)` | `Future<Result<void>>` |
| `GetChapterContent` | `lib/features/chapters/domain/get_chapter_content.dart` | `call(String contentOrPath)` | `Future<Result<String>>` |
| `UploadChapterContent` | `lib/features/chapters/domain/upload_chapter_content.dart` | `call(String filePath)` | `Future<Result<String>>` |

## Tooks (6 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetTook` | `lib/features/tooks/domain/get_took.dart` | `call()` | `Future<Result<List<TookEntity>>>` |
| `GetTookById` | `lib/features/tooks/domain/get_took_by_id.dart` | `call(int id)` | `Future<Result<TookEntity?>>` |
| `GetTooksByBook` | `lib/features/tooks/domain/get_tooks_by_book.dart` | `call(int bookId)` | `Future<Result<List<TookEntity>>>` |
| `CreateTook` | `lib/features/tooks/domain/create_took.dart` | `call(TookEntity took)` | `Future<Result<int>>` |
| `UpdateTook` | `lib/features/tooks/domain/update_took.dart` | `call(TookEntity took)` | `Future<Result<void>>` |
| `DeleteTook` | `lib/features/tooks/domain/delete_took.dart` | `call(int id)` | `Future<Result<void>>` |

## Genres (5 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetGenre` | `lib/features/genres/domain/get_genre.dart` | `call()` | `Future<Result<List<GenreEntity>>>` |
| `GetGenreById` | `lib/features/genres/domain/get_genre_by_id.dart` | `call(int id)` | `Future<Result<GenreEntity?>>` |
| `CreateGenre` | `lib/features/genres/domain/create_genre.dart` | `call(GenreEntity genre)` | `Future<Result<void>>` |
| `UpdateGenre` | `lib/features/genres/domain/update_genre.dart` | `call(GenreEntity genre)` | `Future<Result<void>>` |
| `DeleteGenre` | `lib/features/genres/domain/delete_genre.dart` | `call(int id)` | `Future<Result<void>>` |

## Labels (7 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetLabels` | `lib/features/labels/domain/get_labels.dart` | `call()` | `Future<Result<List<LabelEntity>>>` |
| `CreateLabel` | `lib/features/labels/domain/create_label.dart` | `call(LabelEntity label)` | `Future<Result<void>>` |
| `UpdateLabel` | `lib/features/labels/domain/update_label.dart` | `call(int id, String name, String color)` | `Future<Result<void>>` |
| `DeleteLabel` | `lib/features/labels/domain/delete_label.dart` | `call(int id)` | `Future<Result<void>>` |
| `AssignLabelToBook` | `lib/features/labels/domain/assign_label_to_book.dart` | `call(int bookId, int labelId)` | `Future<Result<void>>` |
| `RemoveLabelFromBook` | `lib/features/labels/domain/remove_label_from_book.dart` | `call(int bookId, int labelId)` | `Future<Result<void>>` |
| `GetLabelsForBooks` | `lib/features/labels/domain/get_labels_for_books.dart` | `call(List<int> bookIds)` | `Future<Result<Map<int, Set<int>>>>` |

## Profiles (6 use cases)

| Class | File | Signature | Return |
|-------|------|-----------|--------|
| `GetProfile` | `lib/features/profiles/domain/get_profile.dart` | `call()` | `Future<Result<UserEntity>>` |
| `UpdateProfile` | `lib/features/profiles/domain/update_profile.dart` | `call({String? displayName, String? bio, String? avatarUrl})` | `Future<Result<UserEntity>>` |
| `UploadAvatar` | `lib/features/profiles/domain/upload_avatar.dart` | `call(String filePath)` | `Future<Result<String>>` |
| `GetAllProfiles` | `lib/features/profiles/domain/get_all_profiles.dart` | `call()` | `Future<Result<List<UserEntity>>>` |
| `ChangePassword` | `lib/features/profiles/domain/change_password.dart` | `call(String newPassword)` | `Future<Result<void>>` |
| `UpdateUserRole` | `lib/features/profiles/domain/update_user_role.dart` | `call(String userId, String role)` | `Future<Result<UserEntity>>` |

## Favorites — Repository Methods (3 methods)

Favorites uses repository methods directly instead of use case classes:

| Method | Signature | Return |
|--------|-----------|--------|
| `toggleFavorite` | `toggleFavorite(String userId, int bookId)` | `Future<Result<bool>>` |
| `getFavorites` | `getFavorites(String userId)` | `Future<Result<List<FavoriteEntity>>>` |
| `isFavorite` | `isFavorite(String userId, int bookId)` | `Future<Result<bool>>` |

**Source**: `lib/features/favorites/domain/favorite_repository.dart`

## Admin — Repository Methods (3 methods)

Admin analytics uses repository methods directly:

| Method | Signature | Return |
|--------|-----------|--------|
| `getViewsTrend` | `getViewsTrend({int daysBack = 30})` | `Future<Result<List<Map<String, dynamic>>>>` |
| `getTopBooks` | `getTopBooks({int limitCount = 10})` | `Future<Result<List<Map<String, dynamic>>>>` |
| `getOverview` | `getOverview()` | `Future<Result<Map<String, dynamic>>>` |

**Source**: `lib/features/admin/domain/analytics_repository.dart`

## Summary

| Feature | Use Case Classes | Repository Methods | Total |
|---------|------------------|--------------------|-------|
| Auth | 5 | — | 5 |
| Books | 10 | — | 10 |
| Chapters | 7 | — | 7 |
| Tooks | 6 | — | 6 |
| Genres | 5 | — | 5 |
| Labels | 7 | — | 7 |
| Profiles | 6 | — | 6 |
| Favorites | — | 3 | 3 |
| Admin | — | 3 | 3 |
| **Total** | **46** | **6** | **52** |

← Back to [index](../README.md)