# Favorites

> Favoritos personales por usuario — toggle, listado y verificación de estado.

## Resumen

El feature Favorites permite a los usuarios autenticados gestionar sus
favoritos personales de libros. Los usuarios pueden agregar o quitar libros de
su lista de favoritos y ver todos los libros favoritados. El feature usa la
tabla `user_favorites` de Supabase con políticas RLS acotadas al usuario.

## Modelo de datos

**FavoriteEntity** (`lib/features/favorites/domain/favorite_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `userId` | `String` | UUID del usuario autenticado |
| `bookId` | `int` | ID del libro marcado como favorito |
| `createdAt` | `DateTime` | Cuándo se agregó el favorito |

## Repositorio

**FavoriteRepository**
(`lib/features/favorites/domain/favorite_repository.dart`):

| Método | Firma | Propósito |
| ------ | ----- | --------- |
| toggleFavorite | `FR<bool>` call(uid,bid) | Agregar o quitar favorito |
| getFavorites | `FR<L<FE>>` call(String uid) | Obtener todos los favoritos |
| isFavorite | `FR<bool>` call(uid,bid) | Verificar si un libro es favorito |

**Implementación**: `lib/features/favorites/data/favorite_repository_impl.dart`
— usa el cliente de Supabase para consultar la tabla `user_favorites`.

## BLoC

**FavoriteBloc**
(`lib/features/favorites/presentation/bloc/favorite_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `ToggleFavorite` | Alternar estado de favorito para un libro |
| `LoadFavorites` | Cargar todos los favoritos del usuario actual |
| `CheckFavoriteStatus` | Verificar si un libro específico es favorito |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `FavoriteInitial` | — | Estado inicial |
| `FavoriteLoading` | — | Mientras obtiene datos |
| `FavoriteToggled` | `bool isFavorite` | Después de completar el toggle |
| FavoriteLoaded | `List<FavoriteEntity> favorites` | Favoritos cargados |
| `FavoriteStatusChecked` | `bool isFavorite` | Después de verificar estado |
| `FavoriteError` | `String message` | En caso de error |

## UI

### FavoritesScreen

**Archivo**: `lib/features/favorites/presentation/screens/favorites_screen.dart`

- Lista de pantalla completa de libros favoritos
- Muestra portada, título y autor del libro
- Estados de carga y error con botón de reintentar
- Mensaje de estado vacío cuando no hay favoritos

### FavoriteButton

**Archivo**: `lib/features/favorites/presentation/widgets/favorite_button.dart`

- `IconButton` que alterna el estado de favorito
- Muestra corazón relleno cuando es favorito, contorno cuando no
- Se usa en pantallas de detalle de libro y en elementos de lista

## Registro en DI

**Archivo**: `lib/core/di/injection_favorites.dart`

- `FavoriteRepository` → `LazySingleton`
- `FavoriteBloc` → `Factory` (nueva instancia por árbol de widgets)

No hay clases de caso de uso — el BLoC llama a los métodos del repositorio
directamente.

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de
  `FavoriteEntity`
- [Casos de uso](../../es/domain/use-cases.md) — métodos del repositorio de
  Favorites
- [Tipos de usuario](../../es/user-types/regular-user.md) — Quién puede usar
  favoritos
- [Manejo de errores](../../es/architecture/error-handling.md) — tipo
  `FavoriteFailure`

← Volver al [índice](../../es/README.md)
