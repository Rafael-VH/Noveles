# Chapters

> Entidades de capítulo individuales — CRUD, subida/descarga de contenido y
> pantalla de lectura.

## Resumen

El feature Chapters gestiona los capítulos individuales dentro de un took
(volumen). Los capítulos tienen contenido textual que puede ser inline o
subido como archivo a Supabase Storage. La pantalla de lectura ofrece una vista
de texto con scroll y navegación entre capítulos.

## Modelo de datos

**`ChapterEntity`** (`lib/features/chapters/domain/chapter_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `number` | `String` | Número de capítulo (string de visualización) |
| `title` | `String` | Título del capítulo |
| `content` | `String` | Contenido (inline o URL de storage) |
| `tookId` | `int` | ID del took padre |
| `createdBy` | `String?` | ID del usuario creador |

**`ChapterRef`** (`lib/features/chapters/domain/chapter_ref.dart`):

Referencia liviana usada en eventos del BLoC — lleva `id`, `content`, `number`,
`title`, `tookId` para evitar pasar entidades completas por el bus de eventos.

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetChapters | `FR<L<CE>>` call({int off}) | Listado paginado de capítulos |
| GetChapterById | `FR<CE?>` call(int id) | Capítulo individual |
| GetChapterContent | `FR<String>` call(String p) | Descargar contenido inline |
| CreateChapter | `FR<int>` call(CE ch) | Crear un nuevo capítulo |
| UpdateChapter | `FR<void>` call(CE ch) | Actualizar metadatos del capítulo |
| `DeleteChapter` | `FR<void>` call(int id) | Eliminar un capítulo |
| UploadContent | `FR<String>` call(String f) | Subir .md/.txt a Storage |
| MarkChapterAsRead | `FR<void>` call(int chId, String uId) | Marcar leído |
| GetReadChapterIds | `FR<Set<int>>` call(tookId, uId) | IDs capítulos leídos |

**Repositorio**: `ChapterRepository` → `ChapterRepositoryImpl`.
`downloadContent` determina si una ruta es una referencia a storage o texto
inline.

## BLoC

**`ChapterBloc`** (`lib/features/chapters/presentation/bloc/chapter_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `LoadChapters` | Cargar lista de capítulos |
| `LoadChapterContent` | Cargar y mostrar el texto del capítulo |
| `NavigateChapter` | Ir al capítulo siguiente/anterior |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ChapterInitial` | — | Estado inicial |
| `ChapterLoading` | — | Obteniendo datos |
| `ChaptersLoaded` | `List<ChapterEntity> chapters` | Capítulos cargados |
| ChapterContentLoaded | ChapterEntity chapter,String ... | Lectura lista |
| `ChapterError` | `String message` | Ocurrió un error |

## Pantallas

### ChapterScreen

**Archivo**: `lib/features/chapters/presentation/screens/chapter_screen.dart`

- Vista de lectura con texto scrolleable
- Navegación entre capítulos (anterior/siguiente)
- Muestra título y número
- Al iniciar, llama a `MarkChapterAsRead` (fire-and-forget) para registrar el
  progreso de lectura

### TookScreen (coloreado de lectura)

**Archivo**: `lib/features/tooks/presentation/screens/took_screen.dart`

- Carga los IDs de capítulos leídos vía `GetReadChapterIds` al iniciar
- Los títulos de capítulos se muestran en gris si ya fueron leídos, blanco/por
  defecto si no

## Registro en DI

**Archivo**: `lib/core/di/injection_chapters.dart`

- `ChapterRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `ChapterBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de
  `ChapterEntity`, `ChapterRef`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de
  Chapters
- [Tipos de usuario](../../es/user-types/regular-user.md) — Lectura de
  capítulos, seguimiento de lectura
- [Tipos de usuario](../../es/user-types/scan-user.md) — Creación de capítulos
- [Base de datos](../../es/database/tables.md) — esquema de tablas `chapters`,
  `chapter_reads`
- [Base de datos](../../es/database/storage.md) — Almacenamiento de contenido de
  capítulos
- [App](../../es/features/app/README.md) — `SectionRecentViews` usa seguimiento
  de lectura

← Volver al [índice](../../es/README.md)
