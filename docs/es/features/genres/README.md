# Genres

> Clasificación por género para libros — operaciones CRUD con patrones BLoC y
> Cubit.

## Resumen

El feature Genres gestiona las categorías de género de los libros. Los géneros
son entidades de metadatos simples (nombre + descripción) asignadas a los
libros. Este feature usa dos patrones de gestión de estado: `GenreBloc` para
operaciones CRUD de administración y `GenreCubit` para carga de solo lectura en
las pantallas de scan y principal.

## Modelo de datos

**`GenreEntity`** (`lib/features/genres/domain/genre_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `name` | `String` | Nombre del género (ej., "Romance", "Fantasía") |
| `description` | `String` | Descripción del género |

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetGenre | `FR<L<GenreEntity>>` call() | Listar todos los géneros |
| `GetGenreById` | `Future<Result<GenreEntity?>> call(int id)` | Un género |
| CreateGenre | `Future<Result<void>> call(GenreEntity genre)` | Crear género |
| UpdateGenre | `Future<Result<void>> call(GenreEntity genre)` | Editar género |
| `DeleteGenre` | `Future<Result<void>> call(int id)` | Eliminar género |

**Repositorio**: `GenreRepository` → `GenreRepositoryImpl` consulta la tabla
`genres`.

## BLoC / Cubit

### GenreBloc (CRUD de admin)

**Archivo**: `lib/features/genres/presentation/bloc/genre_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadGenres` | Cargar todos los géneros |
| `CreateGenreEvent` | Crear un nuevo género |
| `UpdateGenreEvent` | Actualizar género |
| `DeleteGenreEvent` | Eliminar género |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `GenreInitial` | — | Inicial |
| `GenreLoading` | — | Obteniendo |
| `GenreLoaded` | `List<GenreEntity> genres` | Cargado |
| `GenreError` | `String message` | Error |

### GenreCubit (solo lectura)

**Archivo**: `lib/features/genres/presentation/genre_cubit.dart`

- Método único: `loadGenres()` → emite `GenreLoaded` o `GenreError`
- Se usa en `ScanBookEditScreen` y `MainScreen` para los chips selectores de
  género

## Pantallas

### GenreScreen

**Archivo**: `lib/features/genres/presentation/screens/genre_screen.dart`

- Lista de libros filtrada por un género específico
- Recibe el nombre del género y la lista completa de libros como parámetros

## Registro en DI

**Archivo**: `lib/features/genres/di/injection_genres.dart`

- `GenreRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `GenreBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `GenreEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de
  Genres
- [Books](../../es/features/books/README.md) — Los libros tienen asociaciones de
  género
- [Base de datos](../../es/database/tables.md) — esquema de la tabla `genres`

← Volver al [índice](../../es/README.md)
