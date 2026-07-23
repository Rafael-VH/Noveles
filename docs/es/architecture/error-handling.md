# Manejo de Errores

> Tipo Result sellado y jerarquía de Failure para un manejo de errores
> type-safe.

## Patrón Result

La app usa una clase sellada `Result<T>` para representar éxito o fallo sin
excepciones:

```dart
sealed class `Result<T>` {
  const Result();
}

final class Ok<T> extends `Result<T>` {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends `Result<T>` {
  final Failure error;
  const Err(this.error);
}
```text

**Fuente**: `lib/core/errors/result.dart`

## Uso

Usá pattern matching de Dart 3 con `switch` para manejar resultados:

```dart
final result = await repository.login(email, password);
switch (result) {
  case Ok(:final value):
    emit(AuthAuthenticated(value));
  case Err(:final error):
    emit(AuthError(error.message));
}
```text

**Patrón**: `case Ok(:final value):` desestructura el valor, `case Err(:final
error):` desestructura el fallo.

## Jerarquía de Failure

Todos los fallos extienden una clase sellada `Failure` con `message` y `cause`
opcional:

```dart
sealed class Failure {
  final String message;
  final Object? cause;
  const Failure(this.message, {this.cause});
}
```text

**Fuente**: `lib/core/errors/failure.dart`

## Tipos de Failure

| Failure | Propósito | Cuándo se Lanza |
| ------- | --------- | --------------- |
| `AuthFailure` | Error de autenticación | F: login, logout, sesión |
| `BookFailure` | Error CRUD libros | Fallos CRUD de libros |
| ChapterFailure | Error CRUD capítulos | Fallos CRUD de capítulos |
| `TookFailure` | Error CRUD tomos | Fallos CRUD de tomos |
| `GenreFailure` | Error CRUD géneros | Fallos CRUD de géneros |
| `LabelFailure` | Error CRUD etiquetas | Fallos CRUD de etiquetas |
| `ProfileFailure` | Error de perfil | F: actualizar perfil, avatar |
| StorageFailure | Error storage/subida | F: subir archivos a Supabase |
| `FavoriteFailure` | Error favoritos | Fallos agregar/eliminar favoritos |
| `AnalyticsFailure` | Error analytics | Fallos obtener analytics admin |

## Principios Clave

1. **Nunca lances excepciones** — todos los errores se envuelven en `Result<T>`
2. **Cada funcionalidad tiene su propio tipo de Failure** — permite pattern
   matching en la capa de UI
3. **Cause opcional** — preserva la excepción original para depuración
4. **Mensajes de texto** — mensajes de error orientados al usuario (a menudo en
   español)

← Volver al [índice](../README.md)
