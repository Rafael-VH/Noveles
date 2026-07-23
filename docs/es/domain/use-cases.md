# Casos de Uso

Cada caso de uso es una clase de responsabilidad única que orquesta una
operación de negocio específica. Reciben un repositorio mediante inyección por
constructor y exponen un método `call()` que devuelve `Future<Result<T>>`.

**Patrón**:

```dart
class MyUseCase {
  final MyRepository _repo;
  MyUseCase(this._repo);
  Future<Result<T>> call(...) async {
    return _repo.doSomething(...);
  }
}
```

## Auth (5 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| Login(email,pwd) | `FR<UserEntity>` | |
| Register(email,pwd) | `FR<UserEntity>` | |
| Logout() | `FR<void>` | |
| GetCurrentUser() | `FR<UserEntity?>` | |
| ListenAuthState() | `Stream<AuthEvent>` | |

## Books (10 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetBooks(onlyVisible,page,pageSize) | `FR<L<BWR>>` | BWR = BookWithRelations |
| GetBookById(id) | `FR<BWR?>` | |
| CreateBook(book) | `FR<int>` | |
| UpdateBook(book) | `FR<void>` | |
| DeleteBook(id) | `FR<void>` | |
| UploadImage(filePath) | `FR<String>` | |
| GetBooksByGenre(books,genre) | `L<BWR>` | Filtro en memoria, sin repo |
| ToggleBookVisibility(bookId,bool) | `FR<void>` | |
| GetBookLabels(books) | `FR<M<int,SE<int>>>` | |
| TrackBookView(bookId) | `FR<void>` | |

## Chapters (7 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetChapter() | `FR<L<ChapterEntity>>` | |
| GetChapterById(id) | `FR<ChapterEntity?>` | |
| CreateChapter(ch) | `FR<int>` | |
| UpdateChapter(ch) | `FR<void>` | |
| DeleteChapter(id) | `FR<void>` | |
| GetChapterContent(path) | `FR<String>` | |
| UploadChapterContent(path) | `FR<String>` | |

## Tooks (6 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetTook() | `FR<L<TookEntity>>` | |
| GetTookById(id) | `FR<TookEntity?>` | |
| GetTooksByBook(bookId) | `FR<L<TookEntity>>` | |
| CreateTook(took) | `FR<int>` | |
| UpdateTook(took) | `FR<void>` | |
| DeleteTook(id) | `FR<void>` | |

## Genres (5 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetGenre() | `FR<L<GenreEntity>>` | |
| GetGenreById(id) | `FR<GenreEntity?>` | |
| CreateGenre(genre) | `FR<void>` | |
| UpdateGenre(genre) | `FR<void>` | |
| DeleteGenre(id) | `FR<void>` | |

## Labels (7 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetLabels() | `FR<L<LabelEntity>>` | |
| CreateLabel(label) | `FR<void>` | |
| UpdateLabel(id,name,color) | `FR<void>` | |
| DeleteLabel(id) | `FR<void>` | |
| AssignLabelToBook(bookId,lblId) | `FR<void>` | |
| RemoveLabelFromBook(bookId,lblId) | `FR<void>` | |
| GetLabelsForBooks(bookIds) | `FR<M<int,SE<int>>>` | |

## Label Rules (4 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetRules() | `FR<L<LabelRuleEntity>>` | |
| CreateRule(labelId,ruleType,params) | `FR<void>` | |
| UpdateRule(ruleId,params) | `FR<void>` | |
| DeleteRule(ruleId) | `FR<void>` | |

## Profiles (6 casos de uso)

| Caso de Uso | Retorna | Notas |
| ----------- | ------- | ----- |
| GetProfile() | `FR<UserEntity>` | |
| UpdateProfile(name,bio,avatar) | `FR<UserEntity>` | Parámetros opcionales |
| UploadAvatar(filePath) | `FR<String>` | |
| GetAllProfiles() | `FR<L<UserEntity>>` | |
| ChangePassword(newPwd) | `FR<void>` | |
| UpdateUserRole(userId,role) | `FR<UserEntity>` | |

## Favorites — Métodos del Repositorio (3)

Favorites usa métodos del repositorio directamente en lugar de clases de caso de
uso:

| Método | Retorna | Notas |
| ------ | ------- | ----- |
| toggleFavorite(userId,bookId) | `FR<bool>` | |
| getFavorites(userId) | `FR<L<FavoriteEntity>>` | |
| isFavorite(userId,bookId) | `FR<bool>` | |

**Fuente**: `lib/features/favorites/domain/favorite_repository.dart`

## Admin — Métodos del Repositorio (3)

Admin analytics usa métodos del repositorio directamente:

| Método | Retorna | Notas |
| ------ | ------- | ----- |
| getViewsTrend(daysBack) | `FR<`L<M<String,dyn>`>>` | |
| getTopBooks(limitCount) | `FR<`L<M<String,dyn>`>>` | |
| getOverview() | `FR<M<String,dyn>>` | |

**Fuente**: `lib/features/admin/domain/analytics_repository.dart`

## Resumen

| Funcionalidad | Clases | Métodos | Total |
| ------------- | ------ | ------- | ----- |
| Auth | 5 | — | 5 |
| Books | 10 | — | 10 |
| Chapters | 7 | — | 7 |
| Tooks | 6 | — | 6 |
| Genres | 5 | — | 5 |
| Labels | 7 | — | 7 |
| Label Rules | 4 | — | 4 |
| Profiles | 6 | — | 6 |
| Favorites | — | 3 | 3 |
| Admin | — | 3 | 3 |
| **Total** | **50** | **6** | **56** |

← Volver al [índice](../README.md)
