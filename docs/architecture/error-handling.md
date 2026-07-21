# Error Handling

> Sealed Result type and Failure hierarchy for type-safe error management.

## Result Pattern

The app uses a `Result<T>` sealed class to represent success or failure without exceptions:

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure error;
  const Err(this.error);
}
```

**Source**: `lib/core/errors/result.dart`

## Usage

Use Dart 3 pattern matching with `switch` to handle results:

```dart
final result = await repository.login(email, password);
switch (result) {
  case Ok(:final value):
    emit(AuthAuthenticated(value));
  case Err(:final error):
    emit(AuthError(error.message));
}
```

**Pattern**: `case Ok(:final value):` destructures the value, `case Err(:final error):` destructures the failure.

## Failure Hierarchy

All failures extend a sealed `Failure` class with `message` and optional `cause`:

```dart
sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, {this.cause});
}
```

**Source**: `lib/core/errors/failure.dart`

## Failure Types

| Failure | Purpose | When Thrown |
|---------|---------|-------------|
| `AuthFailure` | Authentication errors | Login, logout, session failures |
| `BookFailure` | Book CRUD errors | Book create/update/delete failures |
| `ChapterFailure` | Chapter CRUD errors | Chapter create/update/delete failures |
| `TookFailure` | Took CRUD errors | Took create/update/delete failures |
| `GenreFailure` | Genre CRUD errors | Genre create/update/delete failures |
| `LabelFailure` | Label CRUD errors | Label create/update/delete failures |
| `ProfileFailure` | Profile errors | Profile update, avatar upload failures |
| `StorageFailure` | Storage/upload errors | File upload failures to Supabase Storage |
| `FavoriteFailure` | Favorite toggle errors | Favorite add/remove failures |
| `AnalyticsFailure` | Analytics query errors | Admin analytics fetch failures |

## Key Principles

1. **Never throw exceptions** — all errors are wrapped in `Result<T>`
2. **Each feature has its own Failure type** — enables pattern matching at the UI layer
3. **Optional cause** — preserves original exception for debugging
4. **String messages** — user-facing error messages (often in Spanish)

← Back to [index](../README.md)