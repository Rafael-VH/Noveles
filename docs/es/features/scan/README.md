# Scan

> Panel de creación de contenido — gestión de libros, tooks y capítulos para
> usuarios con rol scan.

## Resumen

El feature Scan es la interfaz de creación de contenido para usuarios con el rol
`scan`. Provee CRUD completo para libros, tooks (volúmenes) y capítulos,
incluyendo subida de imágenes y contenido de capítulos basado en archivos. A
diferencia de otros features, scan **no tiene capas de dominio ni datos** —
opera enteramente en la capa de presentación, reutilizando casos de uso de los
features `books`, `tooks`, `chapters` y `genres`.

## Nota de arquitectura

El feature scan es **solo presentación**:

- No existe `lib/features/scan/domain/`
- No existe `lib/features/scan/data/`
- Los BLoCs llaman directamente a casos de uso de otros features (ej.,
  `CreateBook`, `UpdateTook`)
- Esto mantiene a scan como una capa de orquestación delgada sobre la lógica de
  dominio existente

## BLoCs

### ScanBookBloc

**Archivo**: `lib/features/scan/presentation/bloc/scan_book_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadScanBooks` | Cargar todos los libros (incluyendo ocultos) |
| `SaveScanBook` | Crear o actualizar un libro |
| `DeleteScanBook` | Eliminar un libro |
| `ToggleScanBookVisibility` | Alternar visibilidad del libro |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ScanBookInitial` | — | Inicial |
| `ScanBookLoading` | — | Procesando |
| `ScanBookLoaded` | `List<BookWithRelations> books, String? message` | Listo |
| `ScanBookError` | `String message` | Error |

**Dependencias**: `GetBooks`, `CreateBook`, `UpdateBook`, `DeleteBook`,
`ToggleBookVisibility` (del feature books).

### ScanTookBloc

**Archivo**: `lib/features/scan/presentation/bloc/scan_took_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `SaveScanTook` | Crear o actualizar un took |
| `DeleteScanTook` | Eliminar un took |
| `UploadTookCover` | Subir imagen de portada para un took |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ScanTookInitial` | — | Inicial |
| `ScanTookLoading` | — | Procesando |
| `ScanTookLoaded` | `String? message` | Completado |
| `ScanTookCoverUploaded` | `String url` | Portada subida |
| `ScanTookError` | `String message` | Error |

**Dependencias**: `CreateTook`, `UpdateTook`, `DeleteTook` (de tooks),
`UploadImage` (de books).

### ScanChapterBloc

**Archivo**: `lib/features/scan/presentation/bloc/scan_chapter_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `SaveScanChapter` | Crear o actualizar un capítulo |
| `DeleteScanChapter` | Eliminar un capítulo |
| `UploadChapterFile` | Subir archivo .md/.txt de contenido |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ScanChapterInitial` | — | Inicial |
| `ScanChapterLoading` | — | Procesando |
| `ScanChapterLoaded` | `String? message` | Completado |
| `ScanChapterContentUploaded` | `String url` | Contenido subido |
| `ScanChapterError` | `String message` | Error |

**Dependencias**: `CreateChapter`, `UpdateChapter`, `DeleteChapter` (de
chapters), `UploadChapterContent`.

### ScanCoverBloc

**Archivo**: `lib/features/scan/presentation/bloc/scan_cover_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `UploadScanCover` | Subir una imagen de portada |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ScanCoverInitial` | — | Inicial |
| `ScanCoverUploading` | — | Subiendo |
| `ScanCoverUploaded` | `String url` | Subida completa |
| `ScanCoverError` | `String message` | Error |

**Dependencias**: `UploadImage` (de books).

## Pantallas

### ScanMainScreen

**Archivo**: `lib/features/scan/presentation/screens/scan_main_screen.dart`

- Lista de libros con switches de visibilidad
- Acciones de editar/eliminar por libro
- FAB para crear nuevo libro
- Usa `AppDrawer` con navegación específica de scan

### ScanBookEditScreen

**Archivo**: `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`

- Formulario completo del libro: título, autor, portada, géneros, descripción
- Selector de géneros (usa `GenreCubit`)
- Sección de lista de tooks — navega a edición de took
- Selector de portada (usa `ScanCoverBloc`)

### ScanTookEditScreen

**Archivo**: `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`

- Formulario de took: número, título, portada
- Sección de lista de capítulos — navega a edición de capítulo
- Selector de portada (usa `ScanTookBloc`)

### ScanChapterEditScreen

**Archivo**: `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

- Formulario de capítulo: número, título, contenido
- Subida de archivo .md/.txt para contenido (usa `ScanChapterBloc`)
- Edición de contenido inline

## Registro en DI

**Archivo**: `lib/features/scan/di/injection_scan.dart`

- `ScanBookBloc` → `Factory`
- `ScanCoverBloc` → `Factory`
- `GenreCubit` → `Factory`
- `ScanTookBloc` → `Factory`
- `ScanChapterBloc` → `Factory`

Todos los BLoCs reciben casos de uso de otros features vía GetIt — scan no
tiene repositorio propio.

## Relacionados

- [Books](../../es/features/books/README.md) — Casos de uso de Books reutilizados
  por scan
- [Tooks](../../es/features/tooks/README.md) — Casos de uso de Tooks reutilizados
  por scan
- [Chapters](../../es/features/chapters/README.md) — Casos de uso de Chapters
  reutilizados por scan
- [Genres](../../es/features/genres/README.md) — Selector de género (GenreCubit)
- [Tipos de usuario](../../es/user-types/scan-user.md) — Permisos del rol scan
- [Ruteo](../../es/architecture/routing.md) — Selección de pantalla de inicio
  para scan

← Volver al [índice](../../es/README.md)
