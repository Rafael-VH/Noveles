# Plan de Implementación — Corrección de Arquitectura Limpia

> Basado en la auditoría del 18/07/2026. 24 violaciones organizadas en 3 fases.

---

## Índice

- [Pre-requisitos](#pre-requisitos)
- [Fase A — Violaciones Críticas](#fase-a--violaciones-críticas)
- [Fase B — Violaciones Altas](#fase-b--violaciones-altas)
- [Fase C — Violaciones Menores](#fase-c--violaciones-menores)
- [Verificación Final](#verificación-final)
- [Mapa de Commits](#mapa-de-commits)

---

## Pre-requisitos

```bash
# Estado base antes de empezar
dart analyze lib/          # 0 errores
flutter test               # 217 pass, 2 pre-existing failures
git status                 # Working tree limpio
```

Cada fase genera **un commit independiente**. Si algo sale mal, se puede
revertir por fase.

---

## Fase A — Violaciones Críticas

> Estas violaciones rompen las reglas fundamentales de Clean Architecture.

### A1. Scan screens bypassing BLoC (S6, S7)

**Problema:** `scan_took_edit_screen.dart` llama `getIt<UploadCover>()`
directamente. `scan_chapter_edit_screen.dart` llama
`getIt<UploadChapterContent>()` directamente. Ambas se saltan la capa BLoC.

## Archivos a modificar

- `lib/features/scan/presentation/bloc/scan_took_bloc.dart`
- `lib/features/scan/presentation/bloc/scan_chapter_bloc.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/core/di/injection_scan.dart`

## Paso 1 — Agregar eventos y estados de upload a ScanTookBloc

En `scan_took_bloc.dart`, agregar:

```dart
// Nuevo evento
class UploadTookCover extends ScanTookEvent {
  final String filePath;
  const UploadTookCover(this.filePath);
  @override
  List<Object> get props => [filePath];
}

// Nuevo estado
class ScanTookCoverUploaded extends ScanTookState {
  final String url;
  const ScanTookCoverUploaded(this.url);
  @override
  List<Object> get props => [url];
}
```

Registrar `UploadCover` como dependencia del BLoC:

```dart
class ScanTookBloc extends Bloc<ScanTookEvent, ScanTookState> {
  final CreateTook createTook;
  final UpdateTook updateTook;
  final DeleteTook deleteTook;
  final UploadCover uploadCover;  // ← NUEVO

  ScanTookBloc({
    required this.createTook,
    required this.updateTook,
    required this.deleteTook,
    required this.uploadCover,    // ← NUEVO
  }) : super(ScanTookInitial()) {
    on<SaveScanTook>(_onSaveTook);
    on<DeleteScanTook>(_onDeleteTook);
    on<UploadTookCover>(_onUploadCover);  // ← NUEVO
  }

  // Handler nuevo
  Future<void> _onUploadCover(
    UploadTookCover event,
    Emitter<ScanTookState> emit,
  ) async {
    final result = await uploadCover(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanTookCoverUploaded(value));
      case Err(:final error):
        emit(ScanTookError(error.message));
    }
  }
}
```

## Paso 2 — Agregar eventos y estados de upload a ScanChapterBloc

En `scan_chapter_bloc.dart`, agregar:

```dart
// Nuevo evento
class UploadChapterFile extends ScanChapterEvent {
  final String filePath;
  const UploadChapterFile(this.filePath);
  @override
  List<Object> get props => [filePath];
}

// Nuevo estado
class ScanChapterContentUploaded extends ScanChapterState {
  final String url;
  const ScanChapterContentUploaded(this.url);
  @override
  List<Object> get props => [url];
}
```

Registrar `UploadChapterContent` como dependencia:

```dart
class ScanChapterBloc extends Bloc<ScanChapterEvent, ScanChapterState> {
  final CreateChapter createChapter;
  final UpdateChapter updateChapter;
  final DeleteChapter deleteChapter;
  final UploadChapterContent uploadContent;  // ← NUEVO

  ScanChapterBloc({
    required this.createChapter,
    required this.updateChapter,
    required this.deleteChapter,
    required this.uploadContent,             // ← NUEVO
  }) : super(ScanChapterInitial()) {
    on<SaveScanChapter>(_onSaveChapter);
    on<DeleteScanChapter>(_onDeleteChapter);
    on<UploadChapterFile>(_onUploadContent); // ← NUEVO
  }

  // Handler nuevo
  Future<void> _onUploadContent(
    UploadChapterFile event,
    Emitter<ScanChapterState> emit,
  ) async {
    final result = await uploadContent(event.filePath);
    switch (result) {
      case Ok(:final value):
        emit(ScanChapterContentUploaded(value));
      case Err(:final error):
        emit(ScanChapterError(error.message));
    }
  }
}
```

## Paso 3 — Actualizar DI

En `injection_scan.dart`:

```dart
getIt.registerFactory(
  () => ScanTookBloc(
    createTook: getIt(),
    updateTook: getIt(),
    deleteTook: getIt(),
    uploadCover: getIt(),  // ← NUEVO
  ),
);

getIt.registerFactory(
  () => ScanChapterBloc(
    createChapter: getIt(),
    updateChapter: getIt(),
    deleteChapter: getIt(),
    uploadContent: getIt(), // ← NUEVO
  ),
);
```

## Paso 4 — Refactorizar scan_took_edit_screen.dart

Reemplazar `_pickCover()` completo:

```dart
// ANTES (VIOLACIÓN):
Future<void> _pickCover() async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(source: ImageSource.gallery);
  if (xFile == null || !mounted) return;
  final result = await getIt<UploadCover>()(xFile.path);  // ← BYPASS BLOC
  if (!mounted) return;
  switch (result) {
    case Ok<String>(:final value):
      setState(() => _coverCtrl.text = value);
    case Err(:final error):
      // ... snackbar
  }
}

// DESPUÉS (CORRECTO):
Future<void> _pickCover() async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(source: ImageSource.gallery);
  if (xFile == null || !mounted) return;

  final bloc = getIt<ScanTookBloc>();
  final completer = Completer<ScanTookState>();
  late StreamSubscription sub;
  sub = bloc.stream.listen((s) {
    if (s is ScanTookCoverUploaded || s is ScanTookError) {
      sub.cancel();
      if (!completer.isCompleted) completer.complete(s);
    }
  });
  bloc.add(UploadTookCover(xFile.path));
  try {
    final result = await completer.future.timeout(const Duration(seconds: 10));
    if (result is ScanTookCoverUploaded && mounted) {
      setState(() => _coverCtrl.text = result.url);
    } else if (result is ScanTookError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  } on TimeoutException {
    sub.cancel();
  } finally {
    sub.cancel();
  }
}
```

Eliminar el import: `import
'package:noveles/features/books/domain/upload_cover.dart';`

## Paso 5 — Refactorizar scan_chapter_edit_screen.dart

Reemplazar `_pickContentFile()` completo:

```dart
// ANTES (VIOLACIÓN):
final uploadResult = await getIt<UploadChapterContent>()(filePath);  // ← BYPASS BLOC

// DESPUÉS (CORRECTO):
final bloc = getIt<ScanChapterBloc>();
final completer = Completer<ScanChapterState>();
late StreamSubscription sub;
sub = bloc.stream.listen((s) {
  if (s is ScanChapterContentUploaded || s is ScanChapterError) {
    sub.cancel();
    if (!completer.isCompleted) completer.complete(s);
  }
});
bloc.add(UploadChapterFile(filePath));
try {
  final result = await completer.future.timeout(const Duration(seconds: 10));
  if (result is ScanChapterContentUploaded && mounted) {
    setState(() {
      _contentCtrl.text = result.url;
      _uploadedFileName = result.files.single.name;  //保持文件名逻辑
    });
  } else if (result is ScanChapterError && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
} on TimeoutException {
  sub.cancel();
} finally {
  sub.cancel();
}
```

Eliminar el import: `import
'package:noveles/features/chapters/domain/upload_chapter_content.dart';`

## Verificación A1

```bash
dart analyze lib/features/scan/
flutter test test/bloc/scan_*
```

---

### A2. Core depende de features (C1, C2, C3)

**Problema:** `main_screen.dart`, `carousel_appbar_sliver.dart`,
`app_drawer.dart` viven en `core/` pero importan de `features/`.

**Solución:** Crear `features/app/` como feature que orquesta el shell de la
aplicación.

## Archivos a modificar: (Part 2)

- `lib/features/app/presentation/screens/main_screen.dart` (MOVER desde
  core/app/)
- `lib/features/app/presentation/widgets/app_drawer.dart` (MOVER desde
  core/presentation/widgets/)
- `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` (MOVER
  desde core/presentation/widgets/)
- `lib/core/app/app.dart` (actualizar import de MainScreen)
- Todos los archivos que importen estos 3 archivos

## Paso 1 — Crear estructura

```dart
lib/features/app/
├── presentation/
│   ├── screens/
│   │   └── main_screen.dart
│   └── widgets/
│       ├── app_drawer.dart
│       └── carousel_appbar_sliver.dart
```

## Paso 2 — Mover archivos con git mv

```bash
git mv lib/core/app/main_screen.dart lib/features/app/presentation/screens/main_screen.dart
git mv lib/core/presentation/widgets/app_drawer.dart lib/features/app/presentation/widgets/app_drawer.dart
git mv lib/core/presentation/widgets/carousel_appbar_sliver.dart lib/features/app/presentation/widgets/carousel_appbar_sliver.dart
```

## Paso 3 — Actualizar imports en todos los archivos afectados

Busca y reemplaza:

```dart
# main_screen.dart
package:noveles/core/app/main_screen.dart → package:noveles/features/app/presentation/screens/main_screen.dart

# app_drawer.dart
package:noveles/core/presentation/widgets/app_drawer.dart → package:noveles/features/app/presentation/widgets/app_drawer.dart

# carousel_appbar_sliver.dart
package:noveles/core/presentation/widgets/carousel_appbar_sliver.dart → package:noveles/features/app/presentation/widgets/carousel_appbar_sliver.dart
```

Archivos que importan `main_screen.dart`:

- `lib/core/app/app.dart`

Archivos que importan `app_drawer.dart`:

- `lib/features/app/presentation/screens/main_screen.dart` (se auto-importa
  dentro de features/app/)
- `lib/features/admin/presentation/screens/admin_main_screen.dart`
- `lib/features/scan/presentation/screens/scan_main_screen.dart`

Archivos que importan `carousel_appbar_sliver.dart`:

- `lib/features/app/presentation/screens/main_screen.dart` (se auto-importa
  dentro de features/app/)

## Paso 4 — Eliminar directorios vacíos

```bash
# Si core/presentation/widgets/ queda vacío, eliminarlo
# Si core/presentation/ queda vacío (excepto bloc/theme_bloc/), mantenerlo por theme_bloc
```

## Verificación A2

```bash
dart analyze lib/
flutter test test/widgets/admin_main_screen_test.dart
flutter test test/widgets/scan_main_screen_test.dart
```

---

### A3. BookWithRelations acopla 4 features (B1)

**Problema:** `book_with_relations.dart` vive en `books/domain/` pero importa
`genres/domain/`, `labels/domain/`, `tooks/domain/`.

**Solución:** Crear `lib/shared/domain/entities/` para entidades cross-feature.

## Archivos a modificar: (Part 3)

- `lib/shared/domain/entities/book_with_relations.dart` (CREAR — mover desde
  books)
- `lib/shared/domain/entities/` (CREAR directorio)
- Todos los archivos que importen `book_with_relations.dart`
- `lib/features/books/domain/` (eliminar book_with_relations.dart)
- `lib/features/books/data/book_repository_impl.dart` (actualizar import)
- `lib/features/books/data/book_model.dart` (actualizar import si existe)

## Paso 1 — Crear directorio compartido

```bash
mkdir -p lib/shared/domain/entities
```

## Paso 2 — Mover BookWithRelations

```bash
git mv lib/features/books/domain/book_with_relations.dart lib/shared/domain/entities/book_with_relations.dart
```

## Paso 3 — Actualizar todos los imports

Busca y reemplaza globalmente:

```bash
package:noveles/features/books/domain/book_with_relations.dart → package:noveles/shared/domain/entities/book_with_relations.dart
```

Archivos afectados (mínimo):

- `lib/features/books/data/book_repository_impl.dart`
- `lib/features/books/data/book_model.dart`
- `lib/features/admin/presentation/bloc/admin_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_state.dart`
- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/features/scan/presentation/bloc/scan_bloc.dart`
- `lib/features/scan/presentation/bloc/scan_state.dart`
- `lib/features/genres/presentation/screens/genre_screen.dart`
- `lib/features/core/app/presentation/screens/main_screen.dart`

## Paso 4 — Crear barrel

```dart
// lib/shared/domain/entities/entities.dart
export 'book_with_relations.dart';
```

## Verificación A3

```bash
dart analyze lib/
flutter test
```

---

### A4. TookEntity embede ChapterEntity (T1)

**Problema:** `TookEntity` tiene `List<ChapterEntity> listChapter` — dependencia
cross-feature en domain.

**Solución:** Cambiar a `List<int> listChapterIds` en domain, hidratar en
data/model.

## Archivos a modificar: (Part 4)

- `lib/features/tooks/domain/took_entity.dart`
- `lib/features/tooks/data/took_model.dart`
- `lib/features/tooks/data/took_repository_impl.dart`
- `lib/features/scan/presentation/bloc/scan_took_bloc.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- Cualquier archivo que acceda a `took.listChapter`

## Paso 1 — Modificar TookEntity

```dart
// ANTES:
import 'package:noveles/features/chapters/domain/chapter_entity.dart';

class TookEntity extends Equatable {
  // ...
  final List<ChapterEntity> listChapter;
  // ...
}

// DESPUÉS:
class TookEntity extends Equatable {
  // ...
  final List<int> listChapterIds;  // Solo IDs en domain
  // ...
}
```

Actualizar `copyWith` y `props` en consecuencia.

## Paso 2 — Modificar TookModel

```dart
// TookModelfromJson ya parsea chapters de Supabase.
// Ahora hidrata los IDs en domain y mantiene chapters como campo data-only:

class TookModel extends TookEntity {
  final List<ChapterEntity> chapters;  // Campo data-only, no en domain

  factory TookModel.fromJson(Map<String, dynamic> json) {
    final chapters = ((json['chapters'] as List<dynamic>?) ?? [])
        .map((ch) => ChapterModel.fromJson(Map<String, dynamic>.from(ch)))
        .toList();

    return TookModel(
      // ... otros campos
      listChapterIds: chapters.map((c) => c.id).toList(),  // IDs en domain
      chapters: chapters,  // Entidades completas en data
    );
  }
}
```

## Paso 3 — Actualizar scan_took_edit_screen.dart

La screen actualmente muestra `_chapters` como `List<ChapterEntity>`. Necesita
obtener los capítulos completos de alguna manera. Opciones:

- Opción A: El BLoC carga los chapters por ID (agregar evento
  `LoadTookChapters`)
- Opción B: El screen recibe los chapters como parámetro aparte
- Opción C: `TookModel` mantiene `chapters` como campo data-only accesible desde
  la screen

**Recomendación: Opción C** — `TookModel` tiene `chapters` como campo extra que
la screen puede castear:

```dart
// En scan_took_edit_screen.dart
final tookModel = widget.took as TookModel?;
_chapters = tookModel?.chapters.toList() ?? [];
```

O mejor: pasar los chapters como parámetro separado al screen.

## Paso 4 — Actualizar consumers

Busca todos los usos de `took.listChapter` y reemplaza según contexto.

## Verificación A4

```bash
dart analyze lib/features/tooks/
dart analyze lib/features/scan/
flutter test
```

---

## Fase B — Violaciones Altas

### B1. dart:io en profile_event.dart (P1)

**Problema:** `PickAvatar` lleva `File file` — dependencia de plataforma en BLoC
event.

## Archivos a modificar: (Part 5)

- `lib/features/profiles/presentation/bloc/profile_event.dart`
- `lib/features/profiles/presentation/bloc/profile_state.dart`
- `lib/features/profiles/presentation/bloc/profile_bloc.dart`
- `lib/features/profiles/presentation/screens/profile_screen.dart`

## Paso 1 — Cambiar evento

```dart
// ANTES:
import 'dart:io';

class PickAvatar extends ProfileEvent {
  final File file;
  const PickAvatar(this.file);
  @override
  List<Object> get props => [file.path];
}

// DESPUÉS:
class PickAvatar extends ProfileEvent {
  final String filePath;  // String en vez de File
  const PickAvatar(this.filePath);
  @override
  List<Object> get props => [filePath];
}
```

Eliminar `import 'dart:io';` de `profile_event.dart`.

## Paso 2 — Actualizar profile_state.dart

Si `profile_state.dart` también importa `dart:io` para el estado, cambiar el
estado a usar `String` en vez de `File`.

## Paso 3 — Actualizar profile_bloc.dart

```dart
// En _onPickAvatar:
Future<void> _onPickAvatar(events.PickAvatar event, Emitter<ProfileState> emit) async {
  final file = File(event.filePath);  // File se crea aquí, en presentation
  // ... resto de la lógica
}
```

## Paso 4 — Actualizar profile_screen.dart

```dart
// ANTES:
context.read<ProfileBloc>().add(PickAvatar(File(xFile.path)));

// DESPUÉS:
context.read<ProfileBloc>().add(PickAvatar(xFile.path));
```

## Verificación B1

```bash
dart analyze lib/features/profiles/
flutter test test/bloc/profile_*
```

---

### B2. TextStats en books/domain/ (CH1)

**Problema:** `text_stats.dart` es una utilidad pura que vive en `books/domain/`
pero es usada por `chapters/presentation/`.

## Archivos a modificar: (Part 6)

- `lib/core/utils/text_stats.dart` (CREAR — mover desde books)
- `lib/features/chapters/presentation/screens/chapter_screen.dart` (actualizar
  import)
- `lib/features/books/domain/` (eliminar text_stats.dart)
- Barrel de books/domain (actualizar)

## Paso 1 — Mover

```bash
git mv lib/features/books/domain/text_stats.dart lib/core/utils/text_stats.dart
```

## Paso 2 — Actualizar imports

Busca y reemplaza:

```bash
package:noveles/features/books/domain/text_stats.dart → package:noveles/core/utils/text_stats.dart
```

## Verificación B2

```bash
dart analyze lib/
flutter test
```

---

### B3. Label BLoC importa books/domain (L1)

**Problema:**`label_bloc.dart` importa
`books/domain/get_book_labels.dart`.**Solución:** Crear
`get_labels_for_book.dart` en labels domain que haga lo
mismo.

## Archivos a modificar: (Part 7)

- `lib/features/labels/domain/get_labels_for_book.dart` (CREAR)
- `lib/features/labels/presentation/bloc/label_bloc.dart` (actualizar import)
- `lib/core/di/injection_labels.dart` (registrar nuevo use case)
- `lib/features/labels/domain/labels.dart` (actualizar barrel)

## Paso 1 — Leer `get_book_labels.dart` para entender qué hace

```bash
# Leer el archivo original
cat lib/features/books/domain/get_book_labels.dart
```

## Paso 2 — Crear `get_labels_for_book.dart` en labels

```dart
// lib/features/labels/domain/get_labels_for_book.dart
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/labels/domain/label_entity.dart';
import 'package:noveles/features/labels/domain/label_repository.dart';

class GetLabelsForBook {
  final LabelRepository _repo;
  GetLabelsForBook(this._repo);

  Future<Result<List<LabelEntity>>> call(List<int> bookIds) async {
    return _repo.getLabelsForBooks(bookIds);
  }
}
```

**Nota:** Esto requiere que `LabelRepository` tenga un método
`getLabelsForBooks`. Si no lo tiene, hay que agregarlo a la interfaz y a la
implementación.

## Paso 3 — Actualizar LabelBloc

```dart
// ANTES:
import 'package:noveles/features/books/domain/get_book_labels.dart';

// DESPUÉS:
import 'package:noveles/features/labels/domain/get_labels_for_book.dart';
```

Cambiar el nombre de la dependencia: `getBookLabels` → `getLabelsForBook`.

## Paso 4 — Actualizar DI

```dart
getIt.registerLazySingleton(
  () => GetLabelsForBook(getIt()),  // En vez de GetBookLabels
);
```

## Verificación B3

```bash
dart analyze lib/features/labels/
flutter test test/bloc/label_*
```

---

### B4. GenreScreen importa books/domain (G1)

**Problema:** `genre_screen.dart` importa `book_with_relations.dart`. Pero
después del paso A3, esto ya será
`shared/domain/entities/book_with_relations.dart`.

**Verificar:** Después de A3, `genre_screen.dart` importará de `shared/` en vez
de `books/`. Esto es **aceptable**— shared/ es un módulo compartido
permitido.**Acción:** Solo verificar que A3 resolvió esto. Si
`genre_screen.dart` todavía
importa de `books/`, actualizar a `shared/`.

## Verificación B4

```bash
dart analyze lib/features/genres/presentation/screens/genre_screen.dart
```

---

### B5. ChapterScreen importa books/domain (CH1)

**Problema:** `chapter_screen.dart` importa `text_stats.dart` de books. Se
resuelve con B2.

**Acción:** Verificar que B2 resolvió esto.

## Verificación B5

```bash
dart analyze lib/features/chapters/presentation/screens/chapter_screen.dart
```

---

### B6. Admin books_tab importa labels/presentation (ADM2)

**Problema:**`books_tab.dart` importa `LabelManagementScreen`
directamente.**Solución:** Usar navegación por ruta nombrada en vez de import
directo.

## Archivos a modificar: (Part 8)

- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/core/app/app.dart` (definir ruta si no existe)

## Paso 1 — Verificar si hay rutas definidas en app.dart

```dart
// Si app.dart usa MaterialApp en vez de MaterialApp.router,
// hay que agregar una ruta nombrada:

routes: {
  '/admin/labels': (_) => const LabelManagementScreen(),
},
```

## Paso 2 — Actualizar books_tab.dart

```dart
// ANTES:
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';
// ...
Navigator.push(context, MaterialPageRoute(builder: (_) => const LabelManagementScreen()));

// DESPUÉS (sin import de labels):
Navigator.pushNamed(context, '/admin/labels');
```

## Verificación B6

```bash
dart analyze lib/features/admin/
flutter test test/widgets/admin_*
```

---

### B7. Scan screens usan getIt en vez de context.read (S4, S5)

**Problema:** `scan_took_edit_screen.dart` y `scan_chapter_edit_screen.dart`
crean BLoCs con `getIt<>()` en vez de `context.read<>()`.

**Solución:** Envolver las screens con `BlocProvider` en la navegación.

## Archivos a modificar: (Part 9)

- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart` (quien
  navega a estas)
- Cualquier archivo que navegue a estas screens

## Paso 1 — Envolver scan_took_edit_screen con BlocProvider

En el archivo que navega a `ScanTookEditScreen`:

```dart
// ANTES:
Navigator.push(context, MaterialPageRoute(
  builder: (_) => ScanTookEditScreen(took: took, bookId: bookId),
));

// DESPUÉS:
Navigator.push(context, MaterialPageRoute(
  builder: (_) => BlocProvider(
    create: (_) => getIt<ScanTookBloc>(),
    child: ScanTookEditScreen(took: took, bookId: bookId),
  ),
));
```

## Paso 2 — Dentro de scan_took_edit_screen.dart

```dart
// ANTES:
final bloc = getIt<ScanTookBloc>();

// DESPUÉS:
final bloc = context.read<ScanTookBloc>();
```

Repetir para `ScanChapterEditScreen` y `ScanChapterBloc`.

**Paso 3 — Eliminar imports de `getIt` de las screens** (si ya no se usan para
otra cosa).

## Verificación B7

```bash
dart analyze lib/features/scan/
flutter test test/widgets/scan_*
```

---

## Fase C — Violaciones Menores

### C1. Auth domain estructura plana (A1)

**Problema:** `auth/domain/` tiene archivos sueltos sin subdirectorios.

## Archivos a reorganizar

```
# ANTES:
lib/features/auth/domain/
├── auth_event.dart
├── auth_repository.dart
├── auth.dart
├── get_current_user.dart
├── listen_auth_state.dart
├── login.dart
├── logout.dart
└── register.dart

# DESPUÉS:
lib/features/auth/domain/
├── entities/
│   └── auth_event.dart
├── repositories/
│   └── auth_repository.dart
├── use_cases/
│   ├── get_current_user.dart
│   ├── listen_auth_state.dart
│   ├── login.dart
│   ├── logout.dart
│   └── register.dart
└── auth.dart (barrel)
```

## Paso 1 — Crear subdirectorios

```bash
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/use_cases
```

## Paso 2 — Mover archivos

```bash
git mv lib/features/auth/domain/auth_event.dart lib/features/auth/domain/entities/auth_event.dart
git mv lib/features/auth/domain/auth_repository.dart lib/features/auth/domain/repositories/auth_repository.dart
git mv lib/features/auth/domain/get_current_user.dart lib/features/auth/domain/use_cases/get_current_user.dart
git mv lib/features/auth/domain/listen_auth_state.dart lib/features/auth/domain/use_cases/listen_auth_state.dart
git mv lib/features/auth/domain/login.dart lib/features/auth/domain/use_cases/login.dart
git mv lib/features/auth/domain/logout.dart lib/features/auth/domain/use_cases/logout.dart
git mv lib/features/auth/domain/register.dart lib/features/auth/domain/use_cases/register.dart
```

## Paso 3 — Actualizar barrel `auth.dart`

```dart
export 'entities/auth_event.dart';
export 'repositories/auth_repository.dart';
export 'use_cases/get_current_user.dart';
export 'use_cases/listen_auth_state.dart';
export 'use_cases/login.dart';
export 'use_cases/logout.dart';
export 'use_cases/register.dart';
```

## Paso 4 — Actualizar imports en consumers

Busca todos los imports de `auth/domain/` y actualiza si usan paths directos en
vez del barrel.

## Verificación C1

```bash
dart analyze lib/features/auth/
flutter test test/bloc/auth_*
flutter test test/repositories/auth_*
```

---

### C2. Separar scan_took_bloc.dart (S1)

**Problema:** Events, States y BLoC en un solo archivo.

## Archivos a crear

- `lib/features/scan/presentation/bloc/scan_took_event.dart`
- `lib/features/scan/presentation/bloc/scan_took_state.dart`

## Paso 1 — Extraer events

```dart
// scan_took_event.dart
import 'package:equatable/equatable.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

abstract class ScanTookEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SaveScanTook extends ScanTookEvent {
  final TookEntity took;
  final bool isUpdate;
  SaveScanTook(this.took, {required this.isUpdate});
  @override
  List<Object> get props => [took, isUpdate];
}

class DeleteScanTook extends ScanTookEvent {
  final int tookId;
  DeleteScanTook(this.tookId);
  @override
  List<Object> get props => [tookId];
}

// Agregar eventos nuevos de A1 aquí:
class UploadTookCover extends ScanTookEvent {
  final String filePath;
  const UploadTookCover(this.filePath);
  @override
  List<Object> get props => [filePath];
}
```

## Paso 2 — Extraer states

```dart
// scan_took_state.dart
import 'package:equatable/equatable.dart';

abstract class ScanTookState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanTookInitial extends ScanTookState {}
class ScanTookLoading extends ScanTookState {}

class ScanTookLoaded extends ScanTookState {
  final String? message;
  ScanTookLoaded({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class ScanTookError extends ScanTookState {
  final String message;
  ScanTookError(this.message);
  @override
  List<Object> get props => [message];
}

// Agregar estados nuevos de A1 aquí:
class ScanTookCoverUploaded extends ScanTookState {
  final String url;
  const ScanTookCoverUploaded(this.url);
  @override
  List<Object> get props => [url];
}
```

## Paso 3 — Actualizar scan_took_bloc.dart

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_event.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_state.dart';
// ... (eliminar definiciones de events/states del archivo)
```

## Verificación C2

```bash
dart analyze lib/features/scan/
flutter test test/bloc/scan_*
```

---

### C3. Separar scan_chapter_bloc.dart (S2)

Mismo patrón que C2 pero para `scan_chapter_bloc.dart`.

## Archivos a crear: (Part 2)

- `lib/features/scan/presentation/bloc/scan_chapter_event.dart`
- `lib/features/scan/presentation/bloc/scan_chapter_state.dart`

## Verificación C3

```bash
dart analyze lib/features/scan/
```

---

### C4. Eliminar duplicación export+import en BLoCs (CH2, L2, S3)

**Problema:** Varios BLoCs tienen `export` + `import` del mismo archivo —
redundante.

## Archivos afectados

- `lib/features/chapters/presentation/bloc/chapter_bloc.dart` (líneas 3-4
  export, 8-9 import)
- `lib/features/labels/presentation/bloc/label_bloc.dart` (líneas 3-4 export,
  13-14 import)
- `lib/features/scan/presentation/bloc/scan_bloc.dart` (líneas 3-4 export, 14-15
  import)

**Fix:** Eliminar las líneas de `export` (mantener solo `import`), ya que los
BLoCs internamente necesitan los types. Los exports son para consumers externos
— si consumers usan paths directos, los exports son innecesarios.

**Alternativa:** Eliminar los `import` duplicados y mantener solo los `export`.
Los exports sirven para que consumidores hagan `import 'bloc.dart'` y obtengan
events/states automáticamente.

**Decisión:** Mantener SOLO `export` (que son los que dan la API pública). Los
consumers que usan paths directos ya están actualizados.

## Verificación C4

```bash
dart analyze lib/
flutter test
```

---

### C5. Agregar use case get_tooks_by_book (T2)

**Problema:** Falta un use case para obtener tooks por bookId.

## Archivos a crear: (Part 3)

- `lib/features/tooks/domain/get_tooks_by_book.dart`

## Paso 1 — Verificar que el repositorio tiene el método

```dart
// lib/features/tooks/domain/took_repository.dart
abstract class TookRepository {
  Future<Result<List<TookEntity>>> getTooks();
  Future<Result<TookEntity>> getTookById(int id);
  Future<Result<void>> createTook(TookEntity took);
  Future<Result<void>> updateTook(TookEntity took);
  Future<Result<void>> deleteTook(int id);
  // Si no existe:
  Future<Result<List<TookEntity>>> getTooksByBook(int bookId);  // AGREGAR
}
```

## Paso 2 — Implementar en TookRepositoryImpl

```dart
@override
Future<Result<List<TookEntity>>> getTooksByBook(int bookId) async {
  try {
    final response = await _client
        .from('tooks')
        .select('*, chapters(*)')
        .eq('book_id', bookId);
    return Right(response.map((json) => TookModel.fromJson(json)).toList());
  } on PostgrestException catch (e) {
    return Left(DatabaseFailure(e.message));
  }
}
```

## Paso 3 — Crear use case

```dart
// lib/features/tooks/domain/get_tooks_by_book.dart
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/domain/took_repository.dart';

class GetTooksByBook {
  final TookRepository _repo;
  GetTooksByBook(this._repo);

  Future<Result<List<TookEntity>>> call(int bookId) async {
    return _repo.getTooksByBook(bookId);
  }
}
```

## Paso 4 — Registrar en DI

```dart
// lib/core/di/injection_tooks.dart
getIt.registerLazySingleton(
  () => GetTooksByBook(getIt()),
);
```

## Paso 5 — Actualizar barrel

```dart
// lib/features/tooks/domain/tooks.dart
export 'get_tooks_by_book.dart';
```

## Verificación C5

```bash
dart analyze lib/features/tooks/
flutter test test/bloc/took_*
```

---

## Verificación Final

Después de completar las 3 fases:

```bash
# 1. Análisis completo
dart analyze lib/

# 2. Tests completos
flutter test

# 3. Verificar que no quedan imports prohibidos en domain/
grep -r "package:flutter" lib/features/*/domain/
grep -r "supabase_flutter" lib/features/*/domain/
grep -r "import.*data/" lib/features/*/domain/
grep -r "import.*presentation/" lib/features/*/domain/

# 4. Verificar que core/ no importa features/
grep -r "import.*features/" lib/core/

# 5. Verificar que entities no tienen fromJson/toJson
grep -r "fromJson\|toJson" lib/features/*/domain/entities/

# 6. Verificar que BLoCs no importan repositories
grep -r "import.*repository" lib/features/*/presentation/bloc/
```

## Esperado

- `dart analyze`: 0 errores
- `flutter test`: 217+ pass, mismos 2 pre-existing failures
- Grep 1-6: 0 resultados (o solo barrel exports permitidos)

---

## Mapa de Commits

| # | Fase | Commit Message |
| --- | ------ | ---------------- |
| 1 | A1 | `refactor(scan): move upload logic from screens to BLoC layer` |
| 2 | A2 | `refactor(app): move main_screen, app_drawer, carousel to features/app/` |
| 3 | A3 | `refactor(shared): move BookWithRelations to shared/domain/entities/` |
| 4 | A4 | `refactor(tooks): use chapter IDs in domain, hydrate in data` |
| 5 | B1 | `refactor(profiles): replace File with filePath in PickAvatar event` |
| 6 | B2 | `refactor(utils): move TextStats to core/utils/` |
| 7 | B3 | `refactor(labels): create GetLabelsForBook to remove books dependency` |
| 8 | B6 | `refactor(admin): use named routes instead of direct screen import` |
| 9 | B7 | `refactor(scan): use BlocProvider instead of getIt in edit screens` |
| 10 | C1 | `refactor(auth): restructure domain with subdirectories` |
| 11 | C2-C3 | `refactor(scan): split monolithic BLoC files into event/state/bloc` |
| 12 | C4 | `refactor(blocs): remove duplicate export+import patterns` |
| 13 | C5 | `refactor(tooks): add GetTooksByBook use case` |

---

## Orden de Ejecución Recomendado

```
A1 → A2 → A3 → A4 → B1 → B2 → B3 → B4/B5 (verify) → B6 → B7 → C1 → C2-C3 → C4 → C5
```

## Dependencias

- A3 debe ejecutarse ANTES de B4/B5 (verify after A3)
- B2 debe ejecutarse ANTES de B5 (verify after B2)
- C2-C3 debe ejecutarse DESPUÉS de A1 (ya que A1 agrega eventos nuevos)

**Tiempo estimado total:** 3-4 horas de implementación.

---

*Generado por ArquiC — 18/07/2026*
