# Entidades de Dominio

> Catálogo completo de las 13 entidades de dominio con definiciones de campos y
> relaciones.

← [Volver al índice](../README.md)

## Resumen de Entidades

| Entidad | Archivo | Campos | Funcionalidad |
| ------- | ------ | ------ | ------------- |
| `BookEntity` | `lib/features/books/domain/book_entity.dart` | 22 | books |
| `BookWithRelations` | `book_with_relations.dart` | 25 (+3 listas) | shared |
| `ChapterEntity` | `chapter_entity.dart` | 7 | chapters |
| `ChapterRef` | `chapter_ref.dart` | 5 | chapters |
| `TookEntity` | `lib/features/tooks/domain/took_entity.dart` | 10 | tooks |
| `GenreEntity` | `lib/features/genres/domain/genre_entity.dart` | 4 | genres |
| `LabelEntity` | `lib/features/labels/domain/label_entity.dart` | 4 | labels |
| `LabelRuleEntity` | `lib/features/labels/domain/label_rule_entity.dart` | 6 (+1 enum) | labels |
| `UserEntity` | `user_entity.dart` | 6 (+4 getters) | profiles |
| `FavoriteEntity` | `lib/features/books/favorites/domain/favorite_entity.dart` | 3 | books |

## BookEntity

**Archivo**: `lib/features/books/domain/book_entity.dart`
**Extiende**: `Equatable`

La entidad central de libro — contiene solo campos escalares e IDs de relación.
Sin imports de otras funcionalidades.

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `cover` | `String` | No | URL de la imagen de portada |
| `name` | `String` | No | Título del libro |
| `short` | `String` | No | Descripción corta / eslogan |
| `alternative` | `String` | No | Título alternativo |
| `description` | `String` | No | Descripción completa |
| `authorId` | `int` | No | Clave foránea al autor |
| `author` | `String` | No | Nombre del autor (desnormalizado) |
| `country` | `String` | No | País de origen |
| `state` | `String` | No | Estado de publicación |
| `type` | `String` | No | Tipo de libro / categoría de género |
| `release` | `String` | No | Fecha de lanzamiento (texto) |
| `tookCount` | `int` | No | Cantidad de tomos |
| `chapterCount` | `int` | No | Cantidad total de capítulos |
| `source` | `String` | No | Fuente del contenido |
| `link` | `String` | No | Enlace externo |
| `isFavorite` | `bool` | No | Estado de favorito del usuario actual |
| `isVisible` | `bool` | No | Alternar visibilidad (admin/scan) |
| `listGenreIds` | `List<int>` | No | IDs de géneros (por defecto: `[]`) |
| `listTookIds` | `List<int>` | No | IDs de tomos (por defecto: `[]`) |
| `listLabelIds` | `List<int>` | No | IDs de etiquetas (por defecto: `[]`) |
| `createdBy` | `String?` | **Sí** | ID de usuario del creador |

## BookWithRelations

**Archivo**: `lib/shared/domain/entities/book_with_relations.dart`
**Extiende**: `BookEntity`

Entidad de libro con objetos de relación completamente hidratados. Se usa cuando
Supabase devuelve datos con joins (géneros, etiquetas, tomos). Es el tipo con el
que trabaja la UI para renderizar.

Hereda todos los 22 campos de `BookEntity` más:

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `listGenre` | `List<GenreEntity>` | No | Géneros completos (default: `[]`) |
| `listTook` | `List<TookEntity>` | No | Tomos completos (default: `[]`) |
| `listLabel` | `List<LabelEntity>` | No | Etiquetas completas (default: `[]`) |

## ChapterEntity

**Archivo**: `lib/features/chapters/domain/chapter_entity.dart`
**Extiende**: `Equatable`

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `number` | `String` | No | Número de capítulo (texto, ej.: "1", "1.5") |
| `title` | `String` | No | Título del capítulo |
| `content` | `String` | No | URL del contenido (apunta a Supabase Storage) |
| `tookId` | `int` | No | Clave foránea al tomo padre |
| `createdBy` | `String?` | **Sí** | ID de usuario del creador |

## ChapterRef

**Archivo**: `lib/features/chapters/domain/chapter_ref.dart`
**Extiende**: `Equatable`

Referencia liviana para eventos de capítulos. Contiene solo los campos
necesarios para iniciar la carga de contenido, evitando el costo de pasar
objetos `ChapterEntity` completos a través del bus de eventos.

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | ID del capítulo |
| `content` | `String` | No | URL del contenido |
| `number` | `String` | No | Número de capítulo |
| `title` | `String` | No | Título del capítulo |
| `tookId` | `int` | No | Clave foránea al tomo padre |

**Factory**: `ChapterRef.fromEntity(ChapterEntity entity)` — crea una ref desde
una entidad completa.

## TookEntity

**Archivo**: `lib/features/tooks/domain/took_entity.dart`
**Extiende**: `Equatable`

Un "took" representa un volumen o tomo dentro de un libro. Los libros contienen
múltiples tomos, y cada tomo contiene múltiples capítulos.

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `cover` | `String` | No | URL de la imagen de portada |
| `number` | `String` | No | Número de volumen (texto) |
| `title` | `String` | No | Título del volumen |
| `chapterCount` | `int` | No | Cantidad de capítulos en este tomo |
| `bookId` | `int` | No | Clave foránea al libro padre |
| `listChapterIds` | `List<int>` | No | IDs de capítulos (por defecto: `[]`) |
| `chapters` | `List<ChapterEntity>` | No | Entidades de capítulo embebidas (por defecto: `const []`) |
| `createdBy` | `String?` | **Sí** | ID de usuario del creador |

> **Nota**: `chapters` es una lista embebida en la capa de dominio para
> conveniencia de presentación, no es una columna de base de datos. Se
> completa por el repositorio al hidratar datos de tooks.

## GenreEntity

**Archivo**: `lib/features/genres/domain/genre_entity.dart`
**Extiende**: `Equatable`

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `name` | `String` | No | Nombre del género |
| `description` | `String` | No | Descripción del género |

## LabelEntity

**Archivo**: `lib/features/labels/domain/label_entity.dart`
**Extiende**: `Equatable`

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `name` | `String` | No | Nombre de la etiqueta |
| `color` | `String` | No | Color de la etiqueta (hex o nombre) |

## LabelRuleEntity

**Archivo**: `lib/features/labels/domain/label_rule_entity.dart`
**Extiende**: `Equatable`

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `int` | No | Clave primaria |
| `labelId` | `int` | No | FK → labels(id) |
| `ruleType` | `LabelRuleType` | No | Enum (4 valores) |
| `params` | `Map<String, dynamic>` | No | Parámetros de configuración JSON |
| `createdAt` | `DateTime` | No | Marca de tiempo de creación |
| `updatedAt` | `DateTime` | No | Marca de tiempo de última actualización |

### Enum LabelRuleType

**Archivo**: `lib/features/labels/domain/label_rule_entity.dart`

| Valor | Nombre Visible | Descripción |
| ----- | -------------- | ----------- |
| `newRelease` | Novedad | Libros más nuevos de N días |
| `mostRead` | Más leídos | Top N por visitas en período |
| `mostPopular` | Más populares | Top N por cantidad de tomos/capítulos |
| `mostFavorited` | Más favoritos | Top N por favoritos de usuarios |

## UserEntity

**Archivo**: `lib/features/profiles/domain/user_entity.dart`
**Extiende**: `Equatable`

### Campos Almacenados

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `id` | `String` | No | UUID de Supabase Auth |
| `email` | `String` | No | Correo electrónico del usuario |
| `role` | `UserRole` | No | Rol enum (`user`, `scan`, `admin`, `suspended`) |
| `displayName` | `String?` | **Sí** | Nombre para mostrar |
| `bio` | `String?` | **Sí** | Biografía del usuario |
| `avatarUrl` | `String?` | **Sí** | URL de la imagen de avatar |

### Getters Calculados

| Getter | Tipo de Retorno | Lógica |
| ------ | --------------- | ------ |
| `isScan` | `bool` | `role == UserRole.scan` |
| `isAdmin` | `bool` | `role == UserRole.admin` |
| `isUser` | `bool` | `role == UserRole.user` |
| `isSuspended` | `bool` | `role == UserRole.suspended` |

### Enum UserRole

**Archivo**: `lib/features/profiles/domain/user_role.dart`

```dart
enum UserRole {
  user,
  scan,
  admin,
  suspended;

  static UserRole fromString(String? role) { ... }
}
```text

`UserRole.fromString()` parsea los valores de texto de la BD. Los valores
desconocidos o nulos por defecto son `UserRole.user`.

## FavoriteEntity

**Archivo**: `lib/features/books/favorites/domain/favorite_entity.dart`
**Extiende**: `Equatable`

| Campo | Tipo Dart | Nulable | Descripción |
| ----- | --------- | ------- | ----------- |
| `userId` | `String` | No | UUID de Supabase Auth del usuario |
| `bookId` | `int` | No | Clave foránea al libro |
| `createdAt` | `DateTime` | No | Cuándo se agregó el favorito |

## Entidades de Analíticas

**Archivo**: `lib/features/admin/domain/analytics_entities.dart`
**Extiende**: `Equatable`

Entidades tipadas para analíticas de admin, reemplazando devoluciones raw de
`Map<String, dynamic>`.

### AnalyticsOverview

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `totalViews` | `int` | Conteo total de vistas en todos los libros |
| `viewsToday` | `int` | Vistas recibidas hoy |
| `totalBooks` | `int` | Cantidad total de libros |
| `visibleBooks` | `int` | Libros visibles para usuarios regulares |

### AnalyticsTrendEntry

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `viewDate` | `String` | Fecha (AAAA-MM-DD) |
| `viewCount` | `int` | Cantidad de vistas en esa fecha |

### AnalyticsTopBook

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `bookName` | `String` | Título del libro |
| `viewCount` | `int` | Cantidad de vistas |

## Relaciones

```text
UserEntity ──(createdBy)──→ BookEntity
                              │
                              ├──(listTookIds)──→ TookEntity ──(bookId)──→ BookEntity
                              │                       │
                              │                       └──(listChapterIds)──→ ChapterEntity
                              │                              ──(tookId)──→ TookEntity
                              │
                              ├──(listGenreIds)──→ GenreEntity
                              │                     (muchos-a-muchos via books_genres)
                              │
                              └──(listLabelIds)──→ LabelEntity
                                                    (muchos-a-muchos via books_labels)

UserEntity ──(userId)──→ FavoriteEntity ──(bookId)──→ BookEntity

LabelRuleEntity ──(labelId)──→ LabelEntity
```text

### Tablas de Unión (Supabase)

| Tabla de Unión | Columnas | Relación |
| -------------- | -------- | -------- |
| `books_genres` | `book_id`, `genre_id` | Libro ↔ Género (muchos-a-muchos) |
| `books_labels` | `book_id`, `label_id` | Libro ↔ Etiqueta (muchos-a-muchos) |
| `favorites` | `user_id`, `book_id` | Usuario ↔ Libro (M:N, único) |

---

> Última verificación: 2026-07-24
