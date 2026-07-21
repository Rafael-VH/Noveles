# Plan de Mejoras — Usuario Scan (`role = 'scan'`)

> **Generado**: 2026-07-20 | **Basado en**: Auditoría de 1046 líneas
  (`docs/user-types/scan-user.md`)
> **Estado**: Borrador — requiere aprobación antes de implementar

---

## Resumen Ejecutivo

El rol scan está funcionalmente operativo: puede crear, editar y eliminar
libros, tomos y capítulos propios. Sin embargo, la auditoría revela **dos
vulnerabilidades de seguridad activas** (tooks/chapters sin ownership check en
RLS, storage sin ownership check) que permiten a cualquier scan modificar datos
de otros scans. Adicionalmente, el `ScanBloc` es monolítico (7 use cases, 6
eventos en una sola clase — el propio código tiene un `TODO` confirmando esto),
el `UploadCover` está compartido entre books y tooks sin abstracción, y hay un
riesgo de colisión de IDs por el patrón `DateTime.now().millisecondsSinceEpoch`.

La prioridad inmediata es **seguridad** (Fase 1). Las mejoras de arquitectura y
UX son necesarias pero no bloqueantes. El plan cubre 6 categorías en 4 fases,
con un estimado total de 2-3 semanas de desarrollo.

---

## Tabla de Prioridades

| # | Item | Categoría | Prioridad | Esfuerzo | Dependencias | Estado |
| --- | ------ | ----------- | ----------- | ---------- | -------------- | -------- |
| 1 | RLS ownership check en `tooks` | Seguridad | P0 | S | — | 🔲 Pendiente |
| 2 | RLS ownership check en `chapters` | Seguridad | P0 | S | — | 🔲 Pendiente |
| 3 | Storage ownership verification | Seguridad | P0 | M | #1, #2 | 🔲 Pendiente |
| 4 | Storage cleanup de huérfanos | Seguridad | P0 | M | #3 | 🔲 Pendiente |
| 5 | Decomposición ScanBloc → ScanBookBloc + ScanCoverBloc | Tech Debt | P1 | L | — | 🔲 Pendiente |
| 6 | Rename UploadCover → UploadImage (abstracción genérica) | Tech Debt | P1 | S | #5 | 🔲 Pendiente |
| 7 | UI de Label Management para scan | Features | P2 | M | — | 🔲 Pendiente |
| 8 | Reemplazar provisional IDs por UUIDs | Data Integrity | P1 | M | — | 🔲 Pendiente |
| 9 | Loading states y error handling consistente | UX | P2 | M | #5 | 🔲 Pendiente |
| 10 | Upload progress indicators | UX | P2 | S | — | 🔲 Pendiente |
| 11 | Form validation feedback | UX | P3 | S | — | 🔲 Pendiente |
| 12 | Test coverage para scan features | Code Quality | P2 | L | #5 | 🔲 Pendiente |
| 13 | Optimistic locking para concurrent edits | Data Integrity | P3 | L | #8 | 🔲 Pendiente |
| 14 | Genre management desde scan (opcional) | Features | P3 | M | — | 🔲 Pendiente |
| 15 | Documentación del módulo scan | Code Quality | P3 | S | — | 🔲 Pendiente |

---

## Fase 1: Seguridad (P0) — CRÍTICO

**Objetivo**: Eliminar las vulnerabilidades que permiten a un scan modificar
datos de otro scan.
**Estimación**: 1-2 días (S + S + M)

---

### 1.1 — RLS ownership check en `tooks`

**Prioridad**: P0 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: Ninguna

**Problema**: Las políticas INSERT/UPDATE/DELETE de `tooks` verifican solo
`is_scan()` pero NO verifican `created_by = auth.uid()`. Cualquier scan puede
modificar tomos de cualquier otro scan.

**Solución**: Crear migración que reemplace las políticas genéricas por
políticas con ownership check.

**Migración SQL**:

```sql
-- 1. Eliminar políticas antiguas sin ownership
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable update for scan only" ON public.tooks;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.tooks;

-- 2. Crear nuevas políticas con ownership via join a books
CREATE POLICY "Scan can insert own tooks"
  ON public.tooks FOR INSERT
  WITH CHECK (
    is_scan() AND
    EXISTS (SELECT 1 FROM public.books WHERE books.id = tooks.book_id AND books.created_by = auth.uid())
  );

CREATE POLICY "Scan can update own tooks"
  ON public.tooks FOR UPDATE
  USING (
    is_scan() AND
    EXISTS (SELECT 1 FROM public.books WHERE books.id = tooks.book_id AND books.created_by = auth.uid())
  );

CREATE POLICY "Scan can delete own tooks"
  ON public.tooks FOR DELETE
  USING (
    is_scan() AND
    EXISTS (SELECT 1 FROM public.books WHERE books.id = tooks.book_id AND books.created_by = auth.uid())
  );
```

**Nota**: `tooks` tiene FK a `books` via `book_id`, así que podemos verificar
ownership del libro padre sin agregar `created_by` a la tabla `tooks`.

**Archivos afectados**:

- Nueva migración en `supabase/migrations/`
- Archivo afectado: `lib/features/tooks/data/took_repository_impl.dart` (sin
  cambios necesarios, solo RLS)

**Criterio de aceptación**:

- [ ] Un scan A NO puede INSERT/UPDATE/DELETE tooks de un libro creado por scan
  B
- [ ] Un scan A SÍ puede INSERT/UPDATE/DELETE tooks de libros propios
- [ ] Admin sigue pudiendo modificar cualquier took
- [ ] Tests de migración pasan

---

### 1.2 — RLS ownership check en `chapters`

**Prioridad**: P0 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: Ninguna (pero hacerlo junto con #1)

**Problema**: Idéntico al de tooks. Las políticas de `chapters` verifican solo
`is_scan()` sin ownership.

**Solución**: La FK `chapters.took_id → tooks.id → tooks.book_id →
books.created_by` permite verificar ownership via cadena de joins.

**Migración SQL**:

```sql
-- 1. Eliminar políticas antiguas
DROP POLICY IF EXISTS "Enable insert for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable update for scan only" ON public.chapters;
DROP POLICY IF EXISTS "Enable delete for scan only" ON public.chapters;

-- 2. Ownership check via took → book → created_by
CREATE POLICY "Scan can insert own chapters"
  ON public.chapters FOR INSERT
  WITH CHECK (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can update own chapters"
  ON public.chapters FOR UPDATE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );

CREATE POLICY "Scan can delete own chapters"
  ON public.chapters FOR DELETE
  USING (
    is_scan() AND
    EXISTS (
      SELECT 1 FROM public.tooks
      JOIN public.books ON books.id = tooks.book_id
      WHERE tooks.id = chapters.took_id AND books.created_by = auth.uid()
    )
  );
```

**Criterio de aceptación**:

- [ ] Un scan A NO puede INSERT/UPDATE/DELETE chapters de libros de scan B
- [ ] Un scan A SÍ puede INSERT/UPDATE/DELETE chapters de libros propios
- [ ] Admin mantiene acceso total
- [ ] El `chapterCount` se actualiza correctamente tras operaciones

---

### 1.3 — Storage ownership verification

**Prioridad**: P0 | **Esfuerzo**: M (medio día)
**Dependencias**: #1, #2 (las migraciones de RLS deben estar primero)

**Problema**: Los buckets `covers` y `chapters` de Supabase Storage permiten a
cualquier usuario autenticado subir/modificar/eliminar archivos. Un scan
malicioso puede eliminar covers de otros scans.

**Solución**: Crear políticas de Storage con naming convention que permita
verificación de ownership.

**Enfoque recomendado**: Usar la convención de nombres de archivo
`{user_id}/{filename}` en lugar de la configuración actual `{timestamp}.{ext}`.

**Cambios en Storage** (Supabase Dashboard o migración):

```sql
-- Covers bucket: restrict a uploads dentro de carpeta del usuario
-- Eliminar políticas antiguas de covers
DROP POLICY IF EXISTS "Covers authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Covers authenticated delete" ON storage.objects;

-- Nuevas políticas con path-based ownership
CREATE POLICY "Covers: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Covers: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'covers' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Mismas políticas para chapters bucket
DROP POLICY IF EXISTS "Chapters authenticated insert" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated update" ON storage.objects;
DROP POLICY IF EXISTS "Chapters authenticated delete" ON storage.objects;

CREATE POLICY "Chapters: authenticated insert own folder"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated update own folder"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Chapters: authenticated delete own folder"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'chapters' AND
    auth.role() = 'authenticated' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );
```

**Cambios en código** (cambiar filename pattern):

`lib/features/books/data/book_repository_impl.dart` (L222):

```dart
// ANTES:
final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';

// DESPUÉS:
final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
```

`lib/features/chapters/data/chapter_repository_impl.dart` (L97):

```dart
// ANTES:
final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';

// DESPUÉS:
final userId = _supabase.client.auth.currentUser?.id ?? 'unknown';
final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
```

`lib/core/cover/cover_url_service.dart` — sin cambios necesarios (Supabase
maneja paths con `/` internamente).

**Archivos afectados**:

- `lib/features/books/data/book_repository_impl.dart` — L222
- `lib/features/chapters/data/chapter_repository_impl.dart` — L97
- Nueva migración SQL
- Supabase Dashboard: bucket policies

**Criterio de aceptación**:

- [ ] Un scan A NO puede subir/modificar/eliminar archivos en el folder de scan
  B
- [ ] Un scan A SÍ puede subir/modificar/eliminar archivos en su propio folder
- [ ] Los covers existentes siguen siendo visibles (migración de archivos
  existentes)
- [ ] El `CoverUrlService` genera URLs correctas con paths anidados

**Riesgo**: Migrar archivos existentes a la nueva estructura de carpetas
requiere un script de migración en Supabase Storage API o un Edge Function
temporal.

---

### 1.4 — Storage cleanup de archivos huérfanos

**Prioridad**: P0 | **Esfuerzo**: M (medio día)
**Dependencias**: #3

**Problema**: Cuando un scan elimina un libro/tomo, los archivos de cover y
contenido NO se eliminan de Storage. No hay cascading delete configurado.

**Solución**: Crear Edge Function o script SQL que limpie archivos huérfanos
periódicamente, y agregar eliminación en cascada en el repository layer.

**Cambios en código**:

`lib/features/books/data/book_repository_impl.dart` — en `deleteBook()`:

```dart
@override
Future<Result<void>> deleteBook(int id) async {
  try {
    // 1. Obtener el libro para saber el cover y los tomos/capítulos
    final bookData = await _supabase.client
        .from('books')
        .select('cover, tooks(chapters(content), cover)')
        .eq('id', id)
        .maybeSingle();

    // 2. Eliminar archivos de storage de capítulos
    if (bookData != null) {
      for (final took in (bookData['tooks'] as List? ?? [])) {
        // Eliminar cover del tomo
        if (took['cover'] != null && took['cover'].isNotEmpty) {
          await _safeDeleteStorage('covers', took['cover']);
        }
        // Eliminar contenido de capítulos
        for (final chapter in (took['chapters'] as List? ?? [])) {
          if (chapter['content'] != null && chapter['content'].startsWith('http')) {
            await _safeDeleteStorageFromUrl('chapters', chapter['content']);
          }
        }
      }
      // Eliminar cover del libro
      if (bookData['cover'] != null && bookData['cover'].isNotEmpty) {
        await _safeDeleteStorage('covers', bookData['cover']);
      }
    }

    // 3. Eliminar el libro (CASCADE elimina tooks, chapters, books_genres, books_labels)
    await _supabase.client.from('books').delete().eq('id', id);
    return const Ok(null);
  } catch (e) {
    return Err(BookFailure('Error al eliminar libro', cause: e));
  }
}

Future<void> _safeDeleteStorage(String bucket, String path) async {
  try {
    await _supabase.client.storage.from(bucket).remove([path]);
  } catch (_) {
    // Log pero no fallar — el archivo puede no existir
  }
}

Future<void> _safeDeleteStorageFromUrl(String bucket, String url) async {
  try {
    // Extraer path de la URL pública
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf(bucket);
    if (bucketIndex != -1) {
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      await _safeDeleteStorage(bucket, filePath);
    }
  } catch (_) {}
}
```

**Criterio de aceptación**:

- [ ] Eliminar un libro limpia sus covers de Storage
- [ ] Eliminar un libro limpia los archivos de contenido de sus capítulos
- [ ] Eliminar un tomo limpia su cover
- [ ] Un error de Storage no impide la eliminación del registro en DB

---

## Fase 2: Core UX (P1) — Alta Prioridad

**Objetivo**: Decomponer el ScanBloc monolítico y estabilizar la experiencia de
usuario.
**Estimación**: 3-4 días (L + S)

---

### 2.1 — Decomposición ScanBloc

**Prioridad**: P1 | **Esfuerzo**: L (1-2 días)
**Dependencias**: Ninguna

**Problema**: `ScanBloc` (187 líneas) maneja 7 use cases y 6 tipos de evento. El
propio desarrollador dejó un `TODO` en L1-4 pidiendo esta división. Acopla
upload de covers, CRUD de libros, carga de géneros y toggling de visibilidad en
una sola clase.

**Solución**: Dividir en dos BLoCs:

#### A. `ScanBookBloc` — CRUD + Visibilidad

```dart
// lib/features/scan/presentation/bloc/scan_book_bloc.dart

class ScanBookBloc extends Bloc<ScanBookEvent, ScanBookState> {
  final GetBooks getBooks;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final ToggleBookVisibility toggleBookVisibility;

  ScanBookBloc({
    required this.getBooks,
    required this.createBook,
    required this.updateBook,
    required this.deleteBook,
    required this.toggleBookVisibility,
  }) : super(ScanBookInitial()) {
    on<LoadScanBooks>(_onLoadBooks);
    on<SaveScanBook>(_onSaveBook);
    on<DeleteScanBook>(_onDeleteBook);
    on<ToggleScanBookVisibility>(_onToggleVisibility);
  }
  // ... implementación
}
```

**Eventos** (`scan_book_event.dart`):

```dart
abstract class ScanBookEvent extends Equatable {}
class LoadScanBooks extends ScanBookEvent {}
class SaveScanBook extends ScanBookEvent {
  final BookWithRelations book;
  final bool isUpdate;
  // ...
}
class DeleteScanBook extends ScanBookEvent {
  final int bookId;
  // ...
}
class ToggleScanBookVisibility extends ScanBookEvent {
  final int bookId;
  final bool isVisible;
  // ...
}
```

**Estados** (`scan_book_state.dart`):

```dart
abstract class ScanBookState extends Equatable {}
class ScanBookInitial extends ScanBookState {}
class ScanBookLoading extends ScanBookState {}
class ScanBookLoaded extends ScanBookState {
  final List<BookWithRelations> books;
  final String? message;
}
class ScanBookError extends ScanBookState {
  final String message;
}
```

#### B. `ScanCoverBloc` — Upload de covers

```dart
// lib/features/scan/presentation/bloc/scan_cover_bloc.dart

class ScanCoverBloc extends Bloc<ScanCoverEvent, ScanCoverState> {
  final UploadCover uploadCover;

  ScanCoverBloc({required this.uploadCover}) : super(ScanCoverInitial()) {
    on<UploadScanCover>(_onUploadCover);
  }
  // ...
}
```

**Eventos** (`scan_cover_event.dart`):

```dart
class UploadScanCover extends ScanCoverEvent {
  final String filePath;
}
```

**Estados** (`scan_cover_state.dart`):

```dart
class ScanCoverInitial extends ScanCoverState {}
class ScanCoverUploading extends ScanCoverState {}
class ScanCoverUploaded extends ScanCoverState {
  final String filename;
}
class ScanCoverError extends ScanCoverState {
  final String message;
}
```

#### C. Eliminar `LoadScanGenres` de los BLoCs de scan

`LoadScanGenres` carga géneros que son solo lectura. En su lugar, el
`GenreSelector` widget debe obtenerlos directamente del `GenreRepository` (ya
inyectado vía DI) o crear un pequeño `GenreCubit`/`GenreBloc` compartido.

Opción recomendada: Crear un `GenreCubit` en
`lib/features/genres/presentation/`:

```dart
class GenreCubit extends Cubit<GenreState> {
  final GetGenre getGenres;
  GenreCubit({required this.getGenres}) : super(GenreInitial());

  Future<void> loadGenres() async {
    final result = await getGenres();
    switch (result) {
      case Ok(:final value): emit(GenreLoaded(value));
      case Err(:final error): emit(GenreError(error.message));
    }
  }
}
```

**Archivos afectados**:

- **Eliminar**: `lib/features/scan/presentation/bloc/scan_bloc.dart`
  (reemplazar)
- **Eliminar**: `lib/features/scan/presentation/bloc/scan_event.dart`
  (reemplazar)
- **Eliminar**: `lib/features/scan/presentation/bloc/scan_state.dart`
  (reemplazar)
- **Crear**: `lib/features/scan/presentation/bloc/scan_book_bloc.dart`
- **Crear**: `lib/features/scan/presentation/bloc/scan_book_event.dart`
- **Crear**: `lib/features/scan/presentation/bloc/scan_book_state.dart`
- **Crear**: `lib/features/scan/presentation/bloc/scan_cover_bloc.dart`
- **Crear**: `lib/features/scan/presentation/bloc/scan_cover_event.dart`
- **Crear**: `lib/features/scan/presentation/bloc/scan_cover_state.dart`
- **Crear**: `lib/features/genres/presentation/genre_cubit.dart` (o类似)
- **Modificar**: `lib/core/di/injection_scan.dart` — registrar nuevos BLoCs
- **Modificar**: `lib/features/scan/presentation/screens/scan_main_screen.dart`
  — usar `ScanBookBloc`
- **Modificar**:
  `lib/features/scan/presentation/screens/scan_book_edit_screen.dart` — usar
  `ScanBookBloc` + `ScanCoverBloc`
- **Modificar**: `test/bloc/scan_bloc_test.dart` — reemplazar por tests de los
  nuevos BLoCs

**Criterio de aceptación**:

- [ ] `ScanBookBloc` maneja solo CRUD de libros y visibilidad
- [ ] `ScanCoverBloc` maneja solo upload de covers
- [ ] `GenreCubit` carga géneros de forma independiente
- [ ] La pantalla `ScanBookEditScreen` usa `BlocProvider` separados
- [ ] No hay regresiones en el flujo crear → cover → género → guardar
- [ ] Todos los tests pasan (adaptados a los nuevos BLoCs)
- [ ] `injection_scan.dart` registra los nuevos BLoCs correctamente

---

### 2.2 — Rename `UploadCover` → `UploadImage`

**Prioridad**: P1 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: #2.1 (la decomposition debe ocurrir primero)

**Problema**: El caso de uso `UploadCover` del dominio de `books` es reutilizado
por `ScanTookBloc` para subir covers de tomos. El nombre es semánticamente
incorrecto — no es un cover de libro, es una imagen genérica.

**Solución**:

1. Renombrar `lib/features/books/domain/upload_cover.dart` →
   `lib/core/domain/upload_image.dart` (o mover a un shared domain)
2. Renombrar la clase `UploadCover` → `UploadImage`
3. Renombrar el parámetro en `BookRepository` de `uploadCover()` →
   `uploadImage()`
4. Actualizar todas las referencias

**Archivos afectados**:

- `lib/features/books/domain/upload_cover.dart` → mover/renombrar
- `lib/features/books/domain/book_repository.dart` — renombrar método
- `lib/features/books/data/book_repository_impl.dart` — renombrar método
- `lib/features/scan/presentation/bloc/scan_cover_bloc.dart` (el nuevo) — import
  actualizado
- `lib/features/scan/presentation/bloc/scan_took_bloc.dart` — import actualizado
- `lib/core/di/injection.dart` — registro actualizado

**Criterio de aceptación**:

- [ ] El caso de uso se llama `UploadImage` y vive en un dominio compartido
- [ ] Tanto `ScanCoverBloc` como `ScanTookBloc` usan `UploadImage`
- [ ] No hay imports rotos

---

## Fase 3: Features Nuevos (P2) — Media Prioridad

**Objetivo**: Completar funcionalidades que el RLS ya soporta pero que no tienen
UI.
**Estimación**: 3-4 días (M + M + M)

---

### 3.1 — UI de Label Management para scan

**Prioridad**: P2 | **Esfuerzo**: M (medio día)
**Dependencias**: #2.1 (para el patrón de BLoCs nuevos)

**Problema**: El RLS permite a scan CRUD completo en `labels` (tabla `labels` y
relación `books_labels`), pero NO hay pantalla para crear/editar/eliminar
etiquetas. La ruta `/label-management` existe en `app.dart` (L32) pero no es
accesible desde el drawer del scan.

**Solución**:

1. Agregar entrada en `AppDrawer` para scan:

`lib/features/app/presentation/widgets/app_drawer.dart`:

```dart
// Dentro del drawer, después de "Editar Perfil":
if (isScan)
  ListTile(
    leading: const Icon(Icons.label),
    title: const Text('Etiquetas'),
    onTap: () {
      Navigator.pop(context);
      context.push('/label-management');
    },
  ),
```

1. Crear `ScanLabelBloc` (o reutilizar el existente del admin si existe):

`lib/features/scan/presentation/bloc/scan_label_bloc.dart`:

```dart
class ScanLabelBloc extends Bloc<ScanLabelEvent, ScanLabelState> {
  final GetLabels getLabels;
  final CreateLabel createLabel;
  final UpdateLabel updateLabel;
  final DeleteLabel deleteLabel;
  // ...
}
```

1. Asegurar que la pantalla `/label-management` funcione para scan (verificar
   que no tenga guards de admin).

**Archivos afectados**:

- `lib/features/app/presentation/widgets/app_drawer.dart` — agregar ListTile
- Posiblemente: `lib/features/labels/presentation/` — verificar compatibilidad
- Crear: `lib/features/scan/presentation/bloc/scan_label_bloc.dart` (si no
  existe uno compartido)
- `lib/core/di/injection_scan.dart` — registrar nuevo BLoC

**Criterio de aceptación**:

- [ ] El scan puede crear, editar y eliminar etiquetas desde su panel
- [ ] El scan puede asociar/desasociar etiquetas a sus libros desde
  `ScanBookEditScreen`
- [ ] La entrada aparece en el drawer del scan
- [ ] No hay acceso a funcionalidades de admin (gestión de usuarios, analytics)

---

### 3.2 — Reemplazar provisional IDs por UUIDs

**Prioridad**: P1 (subido a P1 por data integrity) | **Esfuerzo**: M (medio día)
**Dependencias**: Ninguna

**Problema**: `BookEntity.id`, `TookEntity.id` y `ChapterEntity.id` usan
`DateTime.now().millisecondsSinceEpoch` como ID provisional antes del insert. Si
dos operaciones ocurren en el mismo milisegundo, hay colisión. Esto se ve en:

- `scan_book_edit_screen.dart` L105
- `scan_took_edit_screen.dart` L59
- `scan_chapter_edit_screen.dart` L144

**Solución**: Usar un UUID o String random como ID provisional, o mejor aún,
refactorizar para que el entity no necesite un ID provisional.

**Enfoque recomendado**: Cambiar el tipo de `id` de `int` a `String` (UUID v4)
para entidades provisionales, o usar un wrapper `PendingId`:

```dart
// Opción A: ID provisional como String (UUID)
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// En scan_book_edit_screen.dart:
final book = BookEntity(
  id: _uuid.v4(), // ID provisional — se reemplaza por el real del DB
  // ... resto de campos
);
```

**Nota**: Esto requiere verificar que `BookWithRelations.id` y `BookEntity.id`
se manejen consistentemente. Si el ID de DB es `int` (serial/bigint), el
provisional puede ser un string que se reemplaza después del insert.

**Alternativa más segura (recomendada)**: No asignar ID provisional. En su
lugar, refactorizar para que la operación de guardado devuelva el ID real:

```dart
// BookRepository: cambiar return type
Future<Result<int>> createBook(BookEntity book);  // retorna el ID real

// En el BLoC/Screen:
final result = await createBook(book);
switch (result) {
  case Ok(:final value):
    final realId = value;  // ID de la DB
    // usar realId para crear tomos, etc.
  case Err(:final error):
    // manejar error
}
```

**Archivos afectados**:

- `lib/features/books/domain/book_entity.dart` — cambiar tipo de `id` o eliminar
  ID provisional
- `lib/features/books/domain/create_book.dart` — cambiar return type
- `lib/features/books/data/book_repository_impl.dart` — `createBook()` retorna
  ID real
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart` L105
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart` L59
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart` L144
- `lib/features/tooks/domain/create_took.dart` — similarly
- `lib/features/chapters/domain/create_chapter.dart` — similarly
- `lib/features/tooks/data/took_repository_impl.dart` — similarly
- `lib/features/chapters/data/chapter_repository_impl.dart` — similarly

**Criterio de aceptación**:

- [ ] No hay más `DateTime.now().millisecondsSinceEpoch` en screens
- [ ] El ID real de la DB se usa para crear entidades hijas (tomos, capítulos)
- [ ] No hay regresiones en el flujo crear libro → agregar tomo → agregar
  capítulo
- [ ] Tests de BLoC actualizados para reflejar el cambio

---

### 3.3 — Genre management para scan (opcional)

**Prioridad**: P3 (bajado — el scan no necesita crear géneros) | **Esfuerzo**: M
(medio día)
**Dependencias**: Ninguna

**Problema**: Los géneros son solo lectura para scan. Si el scan necesita un
género nuevo, debe pedir al admin que lo cree.

**Solución (si se aprueba)**: Agregar un botón "Sugerir género" que envíe una
solicitud al admin, o permitir al scan crear géneros temporalmente marcados como
"pending approval".

**Nota**: Esta funcionalidad NO está en el RLS actual (géneros solo se crean por
admin). Requiere cambio de RLS si se implementa. **Recomendación: NO
implementar** — mantener géneros como admin-only es una decisión de diseño
válida.

---

## Fase 4: Polish (P3) — Baja Prioridad

**Objetivo**: Mejorar la calidad del código y la experiencia de usuario.
**Estimación**: 3-4 días (L + M + S)

---

### 4.1 — Loading states y error handling consistente

**Prioridad**: P2 (subido) | **Esfuerzo**: M (medio día)
**Dependencias**: #2.1 (la decomposition facilita esto)

**Problema**: Las screens no muestran loading indicators consistentes durante
operaciones de escritura. El `SaveScanBook` usa un `Completer` con timeout de 10
segundos que puede fallar silenciosamente.

**Solución**:

1. Agregar `isLoading` flag a cada screen que observe el BLoC state
2. Usar `BlocBuilder` con estados de loading explícitos
3. Eliminar el patrón `Completer` con timeout (propagar el estado correctamente)

**En `scan_book_edit_screen.dart`** (refactorizar `_save()`):

```dart
void _save() {
  if (!_formKey.currentState!.validate()) return;
  // ... construir book entity
  context.read<ScanBookBloc>().add(SaveScanBook(book, isUpdate: widget.book != null));
}

// En el BlocBuilder:
BlocConsumer<ScanBookBloc, ScanBookState>(
  listener: (context, state) {
    if (state is ScanBookLoaded && state.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message!)),
      );
      if (widget.book == null) {
        // Si era creación, navegar a edición con el nuevo ID
        Navigator.pop(context);
      }
    }
    if (state is ScanBookError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  },
  builder: (context, state) {
    return Stack(
      children: [
        // ... form
        if (state is ScanBookLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  },
)
```

**Archivos afectados**:

- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_main_screen.dart`

**Criterio de aceptación**:

- [ ] Cada operación de escritura muestra un `CircularProgressIndicator` durante
  la carga
- [ ] Los errores se muestran como `SnackBar` con color rojo
- [ ] Los mensajes de éxito se muestran como `SnackBar` con color verde
- [ ] No hay `Completer` con timeout en ninguna screen

---

### 4.2 — Upload progress indicators

**Prioridad**: P2 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: Ninguna

**Problema**: La subida de covers y contenido no muestra progreso. El usuario no
sabe si la app está funcionando o colgada.

**Solución**: Supabase Storage soporta `onUploadProgress` callback. Agregar un
`ValueNotifier<double>` que actualice la UI.

```dart
// En ScanCoverBloc o en la screen:
Future<void> _onUploadCover(UploadScanCover event, Emitter<ScanCoverState> emit) async {
  emit(ScanCoverUploading(progress: 0.0));
  // Supabase upload con progress callback
  final file = File(event.filePath);
  await _supabase.client.storage
      .from('covers')
      .upload(event.filePath, file, fileOptions: FileOptions(
        upsert: true,
      ));
  // Nota: Supabase Dart SDK puede no soportar onUploadProgress directamente.
  // Alternativa: usar uploadBinary con listener de stream.
  emit(ScanCoverUploaded(filename));
}
```

**Nota**: Verificar la API de `supabase_flutter` para `onUploadProgress`. Si no
está disponible, usar un `StreamedResponse` o simulación de progreso basada en
tamaño.

**Archivos afectados**:

- `lib/features/scan/presentation/bloc/scan_cover_bloc.dart` (el nuevo)
- `lib/features/scan/presentation/screens/widgets/cover_picker.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

**Criterio de aceptación**:

- [ ] Se muestra una barra de progreso durante la subida de covers
- [ ] Se muestra una barra de progreso durante la subida de contenido de
  capítulos
- [ ] El progreso se resetea al completar

---

### 4.3 — Form validation feedback

**Prioridad**: P3 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: Ninguna

**Problema**: La validación de campos requeridos (nombre del libro, número de
tomo, número de capítulo) no muestra mensajes de error claros.

**Solución**: Agregar `validator` a cada `TextFormField` con mensajes
descriptivos.

**En `scan_book_edit_screen.dart`**:

```dart
TextFormField(
  controller: _nameCtrl,
  decoration: const InputDecoration(labelText: 'Nombre *'),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length > 200) {
      return 'Máximo 200 caracteres';
    }
    return null;
  },
)
```

**Archivos afectados**:

- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`

**Criterio de aceptación**:

- [ ] Cada campo requerido muestra un mensaje de error si está vacío
- [ ] Los campos opcionales no muestran error si están vacíos
- [ ] La validación ocurre antes de enviar al BLoC

---

### 4.4 — Test coverage para scan features

**Prioridad**: P2 | **Esfuerzo**: L (1-2 días)
**Dependencias**: #2.1 (los tests deben cubrir los nuevos BLoCs)

**Estado actual**: Hay tests básicos para `ScanBloc`, `ScanTookBloc` y
`ScanChapterBloc` en `test/bloc/`. Sin embargo:

- No hay tests de integración con Supabase (RLS testing)
- No hay tests de las screens (widget tests)
- Los tests cubren happy paths pero no edge cases

**Solución**: Agregar tests en 3 niveles:

#### A. Unit tests para los nuevos BLoCs (post-decomposition)

```dart
// test/bloc/scan_book_bloc_test.dart
// test/bloc/scan_cover_bloc_test.dart
```

Cubrir:

- Happy path para cada evento
- Error handling (cada use case falla)
- Refresh fallback (save OK pero refresh falla)
- State transitions correctas

#### B. Widget tests para screens principales

```dart
// test/presentation/scan_book_edit_screen_test.dart
// test/presentation/scan_main_screen_test.dart
```

Cubrir:

- Form validation
- Navegación entre screens
- Empty state (sin libros)
- Error state (BLoC emite error)

#### C. Integration tests (RLS verification)

```dart
// test/integration/scan_rls_test.dart
```

Cubrir:

- Scan A no puede modificar datos de scan B
- Scan puede modificar datos propios
- Admin puede modificar cualquier dato
- Storage ownership verification

**Archivos afectados**:

- `test/bloc/scan_bloc_test.dart` → reemplazar por tests de nuevos BLoCs
- Crear: `test/bloc/scan_book_bloc_test.dart`
- Crear: `test/bloc/scan_cover_bloc_test.dart`
- Crear: `test/presentation/scan_book_edit_screen_test.dart`
- Crear: `test/integration/scan_rls_test.dart`

**Criterio de aceptación**:

- [ ] Test coverage > 80% para la feature scan
- [ ] Todos los BLoCs tienen tests de happy path + error
- [ ] Las screens tienen widget tests básicos
- [ ] Los tests de RLS verifican ownership checks

---

### 4.5 — Optimistic locking para concurrent edits

**Prioridad**: P3 | **Esfuerzo**: L (1-2 días)
**Dependencias**: #3.2 (mejor hacerlo después de resolver los IDs)

**Problema**: Dos scans (o un scan y un admin) pueden editar el mismo libro/tomo
simultáneamente sin detección. La última escritura sobreescribe silenciosamente
la anterior.

**Solución**: Agregar columna `updated_at` con `DEFAULT now()` y verificar en
UPDATE:

```sql
-- Migración
ALTER TABLE public.books ADD COLUMN updated_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.tooks ADD COLUMN updated_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.chapters ADD COLUMN updated_at TIMESTAMPTZ DEFAULT now();

-- Trigger para auto-update
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER books_updated_at
  BEFORE UPDATE ON public.books
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tooks_updated_at
  BEFORE UPDATE ON public.tooks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER chapters_updated_at
  BEFORE UPDATE ON public.chapters
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

En el repository:

```dart
Future<Result<void>> updateBook(BookEntity book) async {
  final result = await _supabase.client
      .from('books')
      .update({...})
      .eq('id', book.id)
      .eq('updated_at', book.updatedAt);  // Optimistic lock

  if (result == null || (result as List).isEmpty) {
    return Err(BookFailure('El libro fue modificado por otro usuario. Recarga e intenta de nuevo.'));
  }
  return const Ok(null);
}
```

**Archivos afectados**:

- Nueva migración SQL
- `lib/features/books/domain/book_entity.dart` — agregar `updatedAt`
- `lib/features/books/data/book_repository_impl.dart` — `updateBook()` con lock
  check
- `lib/features/tooks/data/took_repository_impl.dart` — similar
- `lib/features/chapters/data/chapter_repository_impl.dart` — similar

**Criterio de aceptación**:

- [ ] Si scan A edita un libro mientras scan B lo modifica, scan B recibe error
  de conflicto
- [ ] El usuario recibe un mensaje claro de "conflicto de edición"
- [ ] El `updated_at` se actualiza automáticamente en cada UPDATE

---

### 4.6 — Documentación del módulo scan

**Prioridad**: P3 | **Esfuerzo**: S (1-2 horas)
**Dependencias**: #2.1 (documentar después de la decomposition)

**Problema**: No hay documentación del módulo scan más allá de la auditoría.

**Solución**: Crear `docs/scan-module.md` con:

- Diagrama de arquitectura (BLoCs, screens, relations)
- Flujo de datos: screen → BLoC → use case → repository → Supabase
- RLS policy map (qué puede y qué no puede cada rol)
- Guía de debugging comunes (errores de RLS, storage issues)

**Criterio de aceptación**:

- [ ] Documento existe en `docs/scan-module.md`
- [ ] Cubre arquitectura, flujos y RLS
- [ ] Incluye diagrama de dependencias

---

## Estimación Total

| Fase | Items | Esfuerzo Estimado |
| ------ | ------- | ------------------- |
| **Fase 1: Seguridad (P0)** | #1, #2, #3, #4 | **2-3 días** (L) |
| **Fase 2: Core UX (P1)** | #5, #6, #8 | **3-4 días** (L+) |
| **Fase 3: Features (P2)** | #7 | **1 día** (M) |
| **Fase 4: Polish (P3)** | #9, #10, #11, #12, #13, #15 | **4-5 días** (L+) |
| **Total estimado** | 15 items | **10-13 días**(XL) |**Nota**: Las fases 1 y 2 son independientes y pueden ejecutarse en paralelo si
hay dos desarrolladores. La fase 3 depende de la fase 2 (para el patrón de
BLoCs). La fase 4 es independiente pero cada item tiene sus propias
dependencias.

---

## Riesgos y Consideraciones

### Riesgos Altos

1. **Migración de Storage (#3)**: Cambiar la estructura de carpetas en Supabase
   Storage requiere migrar archivos existentes. Si hay miles de covers/chapters,
   esto puede ser costoso. **Mitigación**: Hacer un script de migración que
   copie archivos de `{timestamp}.{ext}` a `{user_id}/{timestamp}.{ext}` y
   actualice los registros en DB.

2. **RLS ownership via joins (#1, #2)**: Los JOINs en políticas RLS agregan
   overhead a cada query. Con tablas grandes, esto puede afectar performance.
   **Mitigación**: Verificar que las FK estén indexadas (`tooks.book_id`,
   `chapters.took_id`).

3. **Decomposition del ScanBloc (#5)**: Cambiar los BLoCs requiere actualizar
   todas las screens que los consumen. Si hay 3+ screens, hay riesgo de
   regresiones. **Mitigación**: Hacer la decomposition en un branch dedicado con
   tests antes de mergear.

### Riesgos Medios

1. **ID provisional refactor (#8)**: Cambiar el tipo de `id` puede afectar
   serialization/deserialization y la UI que muestra IDs (como `ID: {id}` en
   `scan_main_screen.dart` L147). **Mitigación**: Verificar todas las
   referencias a `BookEntity.id` antes de cambiar.

2. **Tests de RLS (#12)**: Los tests de integración de RLS requieren un entorno
   de Supabase con las migraciones aplicadas. Esto puede ser costoso de
   configurar en CI. **Mitigación**: Usar Supabase local (Docker) para tests de
   integración.

### Consideraciones

1. **Prioridad del usuario**: El usuario (developper) debe decidir si la
   funcionalidad de Label Management (#7) es necesaria. El RLS lo soporta, pero
   si nadie la usa, no vale la pena implementarla.

2. **Orden de implementación**: Fase 1 → Fase 2 → Fase 3 → Fase 4 es el orden
   natural. Cada fase es independiente de la anterior excepto las dependencias
   explícitas.

3. **Rollback plan**: Cada migración SQL debe tener un `DOWN` script. Los BLoCs
   nuevos deben coexistir con los antiguos temporalmente durante la transición.

---

## Archivos Afectados — Resumen

### Archivos a crear (nuevos)

```
lib/features/scan/presentation/bloc/scan_book_bloc.dart
lib/features/scan/presentation/bloc/scan_book_event.dart
lib/features/scan/presentation/bloc/scan_book_state.dart
lib/features/scan/presentation/bloc/scan_cover_bloc.dart
lib/features/scan/presentation/bloc/scan_cover_event.dart
lib/features/scan/presentation/bloc/scan_cover_state.dart
lib/features/genres/presentation/genre_cubit.dart
lib/features/scan/presentation/bloc/scan_label_bloc.dart
test/bloc/scan_book_bloc_test.dart
test/bloc/scan_cover_bloc_test.dart
test/presentation/scan_book_edit_screen_test.dart
test/integration/scan_rls_test.dart
docs/scan-module.md
```

### Archivos a modificar

```dart
lib/core/di/injection_scan.dart
lib/core/di/injection.dart
lib/features/scan/presentation/screens/scan_main_screen.dart
lib/features/scan/presentation/screens/scan_book_edit_screen.dart
lib/features/scan/presentation/screens/scan_took_edit_screen.dart
lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart
lib/features/scan/presentation/screens/widgets/cover_picker.dart
lib/features/app/presentation/widgets/app_drawer.dart
lib/features/books/data/book_repository_impl.dart
lib/features/books/domain/book_repository.dart
lib/features/books/domain/book_entity.dart
lib/features/chapters/data/chapter_repository_impl.dart
lib/features/tooks/data/took_repository_impl.dart
```

### Archivos a eliminar (post-migration)

```
lib/features/scan/presentation/bloc/scan_bloc.dart
lib/features/scan/presentation/bloc/scan_event.dart
lib/features/scan/presentation/bloc/scan_state.dart
test/bloc/scan_bloc_test.dart
```

### Migraciones SQL nuevas

```bash
supabase/migrations/YYYYMMDDHHMMSS_fix_tooks_rls_ownership.sql
supabase/migrations/YYYYMMDDHHMMSS_fix_chapters_rls_ownership.sql
supabase/migrations/YYYYMMDDHHMMSS_fix_storage_rls_ownership.sql
supabase/migrations/YYYYMMDDHHMMSS_add_updated_at_optimistic_lock.sql
```

---

*Plan generado el 2026-07-20. Basado en auditoría de 1046 líneas verificando 60+
archivos Dart y 20+ migraciones SQL.*
