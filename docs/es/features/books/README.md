# Books

> Entidad central del dominio — operaciones CRUD, toggle de visibilidad,
> paginación y seguimiento de vistas.

## Resumen

El feature Books es la entidad central de la aplicación. Gestiona los metadatos
de las novelas (título, autor, portada, descripción, asociaciones de
género/etiqueta) y provee listado paginado, detalle de un libro, toggle de
visibilidad y subida de imágenes. Los libros se cargan como `BookWithRelations`
— una entidad compartida que aplana los datos de género, took y etiqueta para su
presentación.

## Modelo de datos

**`BookEntity`** (`lib/features/books/domain/book_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `cover` | `String` | URL/ruta de la imagen de portada |
| `name` | `String` | Título del libro |
| `short` | `String` | Descripción corta |
| `alternative` | `String` | Título alternativo |
| `description` | `String` | Descripción completa |
| `authorId` | `int` | Referencia al autor |
| `author` | `String` | Nombre del autor |
| `country` | `String` | País de origen |
| `state` | `String` | Estado de publicación |
| `type` | `String` | Tipo/formato del libro |
| `release` | `String` | Información de lanzamiento |
| `tookCount` | `int` | Cantidad de tomos (tooks) |
| `chapterCount` | `int` | Total de capítulos |
| `source` | `String` | URL de origen |
| `link` | `String` | Enlace externo |
| `isFavorite` | `bool` | Estado de favorito del usuario actual |
| `isVisible` | `bool` | Visibilidad para usuarios regulares |
| `listGenreIds` | `List<int>` | IDs de géneros asociados |
| `listTookIds` | `List<int>` | IDs de tooks asociados |
| `listLabelIds` | `List<int>` | IDs de etiquetas asociadas |
| `createdBy` | `String?` | ID del usuario creador |

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetBooks | `FR<L<BWR>>` call({bool o}) | Listado paginado de libros |
| GetBookById | `FR<BWR?>` call(int id) | Libro individual con relaciones |
| ToggleBookVisibility | `FR<void>` call(int id) | Visibilidad libro |
| CreateBook | `FR<int>` call(BE book) | Crear un nuevo libro |
| UpdateBook | `FR<void>` call(BE book) | Actualizar metadatos del libro |
| `DeleteBook` | `FR<void>` call(int id) | Eliminar un libro |
| UploadImage | `FR<String>` call(String f) | Subir portada a Storage |
| GetBookLabels | `FR<M<int,SE<int>>>` call(ids) | Búsqueda masiva etiquetas |
| TrackBookView | `FR<void>` call(int id) | Incrementar contador de vistas |
| GetRecentViews | `FR<L<BWR>>` call(String userId) | Últimos libros vistos |
| GetMostViewedBooks | `FR<L<BWR>>` call() | Libros más vistos globalmente |

**Repositorio**: `BookRepository` → `BookRepositoryImpl` usa consultas a
Supabase con políticas RLS.

## BLoC

**`BookBloc`** (`lib/features/books/presentation/bloc/book_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `LoadBooks` | Cargar primera página de libros |
| `LoadMoreBooks` | Cargar página siguiente (paginación) |
| `LoadBookById` | Cargar un libro para la vista de detalle |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `BookInitial` | — | Estado inicial |
| `BookLoading` | — | Obteniendo datos |
| `BookLoaded` | `List<BookWithRelations> books, bool hasMore` | Cargados |
| `BookDetailLoaded` | `BookWithRelations book` | Libro individual cargado |
| `BookError` | `String message` | Ocurrió un error |

**Tamaño de página**: 50 libros por solicitud.

## Pantallas

### BookScreen

**Archivo**: `lib/features/books/presentation/screens/book_screen.dart`

- Vista de detalle del libro con portada, metadatos, lista de tooks y chips de
  género
- Navegación al detalle del took y a la lectura de capítulos

### Detail Views

**Archivo**: `lib/features/books/presentation/views/detail/`

- Subcomponentes de detalle del libro (metadatos, lista de tooks, etc.)

## Favorites

El feature Books incluye una subsección de Favorites en
`lib/features/books/favorites/` para gestionar favoritos de libros por usuario.

### FavoriteEntity

**Archivo**: `lib/features/books/favorites/domain/favorite_entity.dart`

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `userId` | `String` | UUID del usuario autenticado |
| `bookId` | `int` | ID del libro marcado como favorito |
| `createdAt` | `DateTime` | Cuándo se agregó el favorito |

### Métodos del Repositorio

| Método | Firma | Propósito |
| ------ | ----- | --------- |
| toggleFavorite | `FR<bool>` call(uid,bid) | Agregar o quitar favorito |
| getFavorites | `FR<L<FavoriteEntity>>` call(uid) | Obtener todos los favoritos |
| isFavorite | `FR<bool>` call(uid,bid) | Verificar si es favorito |

### FavoriteBloc

**Archivo**: `lib/features/books/favorites/presentation/bloc/favorite_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `ToggleFavorite` | Alternar estado de favorito para un libro |
| `LoadFavorites` | Cargar todos los favoritos del usuario actual |
| `CheckFavoriteStatus` | Verificar si un libro específico es favorito |

### Componentes UI

- **FavoritesScreen** (`lib/features/books/favorites/presentation/screens/favorites_screen.dart`)
  — Lista de pantalla completa de libros favoritos
- **FavoriteButton** (`lib/features/books/favorites/presentation/widgets/favorite_button.dart`)
  — IconButton que alterna el estado de favorito

## Registro en DI

**Archivo**: `lib/features/books/di/injection_books.dart`

- `BookRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `BookBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `BookEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Books
- [Tipos de usuario](../../es/user-types/regular-user.md) — Quién ve libros
  visibles
- [Tipos de usuario](../../es/user-types/scan-user.md) — Quién gestiona el
  contenido
- [Tipos de usuario](../../es/user-types/admin-user.md) — Quién controla la
  visibilidad
- [Manejo de errores](../../es/architecture/error-handling.md) — `BookFailure`
- [Base de datos](../../es/database/tables.md) — esquema de la tabla `books`

← Volver al [índice](../../es/README.md)
