# Use Cases

Each use case is a single-responsibility class that orchestrates a specific
business operation. They receive a repository via constructor injection and
expose a `call()` method returning `Future<Result<T>>`.

**Pattern**:

```dart
class MyUseCase {
  final MyRepository _repo;
  MyUseCase(this._repo);
  Future<Result<T>> call(...) async {
    return _repo.doSomething(...);
  }
}
```

## Auth (5 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| Login(email,pwd) | `FR<UserEntity>` | |
| Register(email,pwd) | `FR<UserEntity>` | |
| Logout() | `FR<void>` | |
| GetCurrentUser() | `FR<UserEntity?>` | |
| ListenAuthState() | `Stream<AuthEvent>` | |

## Books (10 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetBooks(onlyVisible,page,pageSize) | `FR<L<BWR>>` | BWR = BookWithRelations |
| GetBookById(id) | `FR<BWR?>` | |
| CreateBook(book) | `FR<int>` | |
| UpdateBook(book) | `FR<void>` | |
| DeleteBook(id) | `FR<void>` | |
| UploadImage(filePath) | `FR<String>` | |
| GetBooksByGenre(books,genre) | `L<BWR>` | In-memory filter, no repo |
| ToggleBookVisibility(bookId,bool) | `FR<void>` | |
| GetBookLabels(books) | `FR<M<int,SE<int>>>` | |
| TrackBookView(bookId) | `FR<void>` | |

## Chapters (7 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetChapter() | `FR<L<ChapterEntity>>` | |
| GetChapterById(id) | `FR<ChapterEntity?>` | |
| CreateChapter(ch) | `FR<int>` | |
| UpdateChapter(ch) | `FR<void>` | |
| DeleteChapter(id) | `FR<void>` | |
| GetChapterContent(path) | `FR<String>` | |
| UploadChapterContent(path) | `FR<String>` | |

## Tooks (6 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetTook() | `FR<L<TookEntity>>` | |
| GetTookById(id) | `FR<TookEntity?>` | |
| GetTooksByBook(bookId) | `FR<L<TookEntity>>` | |
| CreateTook(took) | `FR<int>` | |
| UpdateTook(took) | `FR<void>` | |
| DeleteTook(id) | `FR<void>` | |

## Genres (5 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetGenre() | `FR<L<GenreEntity>>` | |
| GetGenreById(id) | `FR<GenreEntity?>` | |
| CreateGenre(genre) | `FR<void>` | |
| UpdateGenre(genre) | `FR<void>` | |
| DeleteGenre(id) | `FR<void>` | |

## Labels (7 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetLabels() | `FR<L<LabelEntity>>` | |
| CreateLabel(label) | `FR<void>` | |
| UpdateLabel(id,name,color) | `FR<void>` | |
| DeleteLabel(id) | `FR<void>` | |
| AssignLabelToBook(bookId,lblId) | `FR<void>` | |
| RemoveLabelFromBook(bookId,lblId) | `FR<void>` | |
| GetLabelsForBooks(bookIds) | `FR<M<int,SE<int>>>` | |

## Profiles (6 use cases)

| Use Case | Returns | Notes |
| --- | --- | --- |
| GetProfile() | `FR<UserEntity>` | |
| UpdateProfile(name,bio,avatar) | `FR<UserEntity>` | Optional params |
| UploadAvatar(filePath) | `FR<String>` | |
| GetAllProfiles() | `FR<L<UserEntity>>` | |
| ChangePassword(newPwd) | `FR<void>` | |
| UpdateUserRole(userId,role) | `FR<UserEntity>` | |

## Favorites — Repository Methods (3)

Favorites uses repository methods directly instead of use case classes:

| Method | Returns | Notes |
| --- | --- | --- |
| toggleFavorite(userId,bookId) | `FR<bool>` | |
| getFavorites(userId) | `FR<L<FavoriteEntity>>` | |
| isFavorite(userId,bookId) | `FR<bool>` | |

**Source**: `lib/features/favorites/domain/favorite_repository.dart`

## Admin — Repository Methods (3)

Admin analytics uses repository methods directly:

| Method | Returns | Notes |
| --- | --- | --- |
| getViewsTrend(daysBack) | `FR<`L<M<String,dyn>`>>` | |
| getTopBooks(limitCount) | `FR<`L<M<String,dyn>`>>` | |
| getOverview() | `FR<M<String,dyn>>` | |

**Source**: `lib/features/admin/domain/analytics_repository.dart`

## Summary

| Feature | Classes | Methods | Total |
| --- | --- | --- | --- |
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
