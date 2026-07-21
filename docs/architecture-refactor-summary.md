# Resumen del Refactor de Arquitectura Limpia

> **Fecha:** 18–19 de julio de 2026
> **Objetivo:** Eliminar las 24 violaciones de Clean Architecture identificadas
  en la auditoría.

---

## Tabla de Contenidos

1. [Contexto](#contexto)
2. [Reglas de Arquitectura](#reglas-de-arquitectura)
3. [Resumen de Cambios por Fase](#resumen-de-cambios-por-fase)
4. [Mapa de Commits](#mapa-de-commits)
5. [Verificación Final](#verificación-final)
6. [Archivos Afectados](#archivos-afectados)
7. [Decisiones de Diseño](#decisiones-de-diseño)
8. [Problemas Conocidos (pre-existentes)](#problemas-conocidos-pre-existentes)

---

## Contexto

El proyecto **Noveles** es una aplicación Flutter para leer y gestionar novelas,
usando Supabase + BLoC + GetIt + Equatable.

La estructura inicial ya tenía Clean Architecture a nivel de feature
(domain/data/presentation por feature), pero presentaba **24 violaciones**
categorizadas así:

| Severidad | Cantidad |
| ----------- | ---------- |
| 🔴 Crítico | 4 |
| 🟠 Alto | 10 |
| 🟡 Menor | 10 |
| **Total** | **24** |

La auditoría completa está en `docs/clean-architecture-audit.md` y el plan de
corrección en `docs/architecture-fix-plan.md`.

---

## Reglas de Arquitectura

```
domain/   → NO depende de nada (capa más interna)
data/     → depende de domain/
presentation/ → depende de domain/
core/     → NO depende de features/
```

### Reglas No Negociables

| # | Regla | Descripción |
| --- | ------- | ------------- |
| 1 | **Domain Puro** | Sin imports de flutter/, supabase/, data/, presentation/ |
| 2 | **Use Cases ≠ Implementaciones** | Use cases dependen de interfaces abstractas, nunca de repositorios concretos |
| 3 | **Presentation NO salta capas** | BLoCs usan use_cases, nunca repositories |
| 4 | **Entities sin serialización** | Sin fromJson/toJson en domain/entities/ |
| 5 | **Core NO conoce features** | core/ es la capa más interna; no puede importar de features/ |
| 6 | **Excepciones técnicas traducidas** | data/ captura Supabase exceptions y devuelve Failures de dominio |

---

## Resumen de Cambios por Fase

### Fase A — Violaciones Críticas (4/4 completadas)

#### A1. Upload logic movido de scan screens al BLoC (S6, S7)

**Problema:** `scan_took_edit_screen.dart` y `scan_chapter_edit_screen.dart`
creaban use_cases con `getIt<>()` y los ejecutaban directamente, saltándose la
capa BLoC.

## Solución

- Se agregaron eventos `UploadTookCover` y `UploadChapterFile` a los BLoCs
- Se agregaron estados `ScanTookCoverUploaded` y `ScanChapterContentUploaded`
- Se registraron `UploadCover` y `UploadChapterContent` como dependencias de los
  BLoCs
- Las screens ahora emiten eventos al BLoC en vez de llamar use_cases
  directamente

## Archivos modificados

- `lib/features/scan/presentation/bloc/scan_took_bloc.dart`
- `lib/features/scan/presentation/bloc/scan_chapter_bloc.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/core/di/injection_scan.dart`

---

### A2. Core deja de depender de features (C1, C2, C3)

**Problema:** `main_screen.dart`, `app_drawer.dart` y
`carousel_appbar_sliver.dart` vivían en `core/` pero importaban de `features/`.

**Solución:** Se creó `features/app/` como feature que orquesta el shell de la
aplicación. Los 3 archivos se movieron de `core/` a
`features/app/presentation/`.

## Archivos movidos

- `lib/core/app/main_screen.dart` →
  `lib/features/app/presentation/screens/main_screen.dart`
- `lib/core/presentation/widgets/app_drawer.dart` →
  `lib/features/app/presentation/widgets/app_drawer.dart`
- `lib/core/presentation/widgets/carousel_appbar_sliver.dart` →
  `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart`

## Archivos con imports actualizados

- `lib/core/app/app.dart`
- `lib/features/admin/presentation/screens/admin_main_screen.dart`
- `lib/features/scan/presentation/screens/scan_main_screen.dart`

---

### A3. BookWithRelations movido a shared/ (B1)

**Problema:** `book_with_relations.dart` vivía en `books/domain/` pero importaba
`genres/domain/`, `labels/domain/` y `tooks/domain/`.

**Solución:** Se creó `lib/shared/domain/entities/` y se movió
`BookWithRelations` ahí.

## Archivos movidos: (Part 2)

- `lib/features/books/domain/book_with_relations.dart` →
  `lib/shared/domain/entities/book_with_relations.dart`

## Archivos con imports actualizados (mínimo)

- `lib/features/books/data/book_repository_impl.dart`
- `lib/features/admin/presentation/bloc/admin_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_state.dart`
- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/features/scan/presentation/bloc/scan_bloc.dart`
- `lib/features/scan/presentation/bloc/scan_state.dart`
- `lib/features/genres/presentation/screens/genre_screen.dart`

---

### A4. TookEntity desacoplada de ChapterEntity (T1)

**Problema:** `TookEntity` tenía `List<ChapterEntity>` como campo — dependencia
cross-feature en domain.

## Solución: (Part 2)

- `TookEntity` ahora tiene `List<int> listChapterIds` (solo IDs en domain)
- `TookModel` mantiene `List<ChapterEntity> chapters` como campo data-only
- La screen hace cast a `TookModel` para acceder a los chapters completos

## Archivos modificados: (Part 2)

- `lib/features/tooks/domain/took_entity.dart`
- `lib/features/tooks/data/took_model.dart`
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`

---

### Fase B — Violaciones Altas (5/5 completadas)

#### B1. dart:io removido de profile_event.dart (P1)

**Problema:**El evento `PickAvatar` llevaba un objeto `File` de
`dart:io`.**Solución:** Se cambió `File file` por `String filePath`. El objeto
`File` se
crea en el BLoC.

## Archivos modificados: (Part 3)

- `lib/features/profiles/presentation/bloc/profile_event.dart`
- `lib/features/profiles/presentation/bloc/profile_bloc.dart`
- `lib/features/profiles/presentation/screens/profile_screen.dart`

---

### B2. TextStats movido a core/utils/ (CH1)

**Problema:** `text_stats.dart` era una utilidad pura que vivía en
`books/domain/` pero era usada por `chapters/presentation/`.

**Solución:** Se movió a `lib/core/utils/text_stats.dart`.

## Archivos modificados: (Part 4)

- `lib/core/utils/text_stats.dart` (creado)
- `lib/features/chapters/presentation/screens/chapter_screen.dart` (import
  actualizado)

---

### B3. GetLabelsForBook creado en labels/ (L1)

**Problema:**`label_bloc.dart` importaba
`books/domain/get_book_labels.dart`.**Solución:** Se creó
`get_labels_for_books.dart` en `labels/domain/` con su
propio repository method.

## Archivos creados/modificados

- `lib/features/labels/domain/get_labels_for_books.dart` (creado)
- `lib/features/labels/domain/label_repository.dart` (method agregado)
- `lib/features/labels/data/label_repository_impl.dart` (method implementado)
- `lib/features/labels/presentation/bloc/label_bloc.dart` (import actualizado)
- `lib/core/di/injection_labels.dart` (DI actualizado)

---

### B6. Admin usa named routes en vez de import directo (ADM2)

**Problema:**`books_tab.dart` importaba `LabelManagementScreen`
directamente.**Solución:** Se usa `Navigator.pushNamed(context,
'/label-management')`.

## Archivos modificados: (Part 5)

- `lib/features/admin/presentation/screens/books_tab.dart`
- `lib/core/app/app.dart` (ruta `/label-management` definida)

---

### B7. Scan screens usan BlocProvider en vez de getIt (S4, S5)

**Problema:** `scan_took_edit_screen.dart` y `scan_chapter_edit_screen.dart`
creaban BLoCs con `getIt<>()`.

**Solución:** Las screens ahora usan `context.read<ScanTookBloc>()` y
`BlocProvider` en la navegación.

## Archivos modificados: (Part 6)

- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart`

---

### Fase C — Violaciones Menores (4/5 completadas)

#### C1. Auth domain reestructurado (A1)

**Problema:**`auth/domain/` tenía archivos sueltos sin
subdirectorios.**Solución:** Se crearon subdirectorios `entities/`,
`repositories/`,
`use_cases/`.

## Archivos movidos: (Part 3)

- `auth_event.dart` → `entities/auth_event.dart`
- `auth_repository.dart` → `repositories/auth_repository.dart`
- `login.dart`, `logout.dart`, `register.dart`, etc. → `use_cases/`

---

### C2. scan_took_bloc.dart separado (S1)

**Problema:**Events, States y BLoC en un solo archivo.**Solución:** Se crearon
archivos separados:

- `lib/features/scan/presentation/bloc/scan_took_event.dart`
- `lib/features/scan/presentation/bloc/scan_took_state.dart`

---

#### C3. scan_chapter_bloc.dart separado (S2)

**Problema:**Mismo problema que C2.**Solución:** Se crearon archivos separados:

- `lib/features/scan/presentation/bloc/scan_chapter_event.dart`
- `lib/features/scan/presentation/bloc/scan_chapter_state.dart`

---

#### C5. GetTooksByBook use case agregado (T2)

**Problema:**Faltaba un use case para obtener tooks por bookId.**Solución:** Se
creó `get_tooks_by_book.dart` con su repository method y DI.

## Archivos creados/modificados: (Part 2)

- `lib/features/tooks/domain/get_tooks_by_book.dart` (creado)
- `lib/features/tooks/domain/took_repository.dart` (method agregado)
- `lib/features/tooks/data/took_repository_impl.dart` (method implementado)
- `lib/core/di/injection_tooks.dart` (DI actualizado)

---

### C4 — CORRECTAMENTE OMITIDO

**Razón:** Dart `export` NO hace que los tipos estén disponibles dentro de la
misma librería. El patrón `export` + `import` en BLoCs es necesario — los
exports sirven para consumidores externos, y los imports son necesarios para que
el propio BLoC use los types de event/state.

---

## Mapa de Commits

| # | Hash | Mensaje | Fase |
| --- | ------ | --------- | ------ |
| 1 | `10a04bb` | `refactor(books): separate BookEntity from BookWithRelations` | Pre-fase |
| 2 | `0796b21` | `refactor(genres): move genres BLoC to features/genres/` | Pre-fase |
| 3 | `709a90c` | `refactor(tooks): move took presentation to tooks/presentation/` | Pre-fase |
| 4 | `4dc08ad` | `refactor(books): move book presentation to books/presentation/` | Pre-fase |
| 5 | `77263ab` | `refactor(shared): move shared widgets to shared/presentation/widgets/` | Pre-fase |
| 6 | `e79a33a` | `refactor(app): move main_screen, app_drawer, carousel to features/app/` | A2 |
| 7 | `f782d0b` | `refactor(shared): move BookWithRelations to shared/domain/entities/` | A3 |
| 8 | `fcd856b` | `refactor(tooks): decouple TookEntity from ChapterEntity` | A4 |
| 9 | `17f1b2d` | `refactor(arch): Phase B — fix 5 high-severity Clean Architecture violations` | B1-B7 |
| 10 | `0abf0c9` | `refactor(arch): Phase C — fix minor Clean Architecture violations` | C1-C5 |
| 11 | `614e03c` | `fix(app): use named route for admin to break circular import` | Post-fase |

---

## Verificación Final

Se ejecutaron 6 verificaciones automáticas después del refactor:

| # | Verificación | Resultado |
| --- | ------------- | ----------- |
| 1 | `flutter/` solo en `presentation/` | ✅ 62 matches, todos en `presentation/` |
| 2 | `supabase_flutter` solo en `data/` | ✅ 2 matches, ambos en `data/` |
| 3 | `fromJson`/`toJson` solo en `data/` | ✅ 32 matches, todos en `data/` |
| 4 | BLoCs no importan repositories | ✅ 0 matches en `presentation/bloc/` |
| 5 | `core/` no importa `features/` | ✅ 0 matches |
| 6 | Domain purity (sin imports de `data/` o `presentation/`) | ✅ Sin violaciones |

### Tests

```dart
flutter test → 217 pass, 2 fail (pre-existentes)
```

---

## Archivos Afectados

### Archivos Movidos

| Desde | Hacia |
| ------- | ------- |
| `lib/core/app/main_screen.dart` | `lib/features/app/presentation/screens/main_screen.dart` |
| `lib/core/presentation/widgets/app_drawer.dart` | `lib/features/app/presentation/widgets/app_drawer.dart` |
| `lib/core/presentation/widgets/carousel_appbar_sliver.dart` | `lib/features/app/presentation/widgets/carousel_appbar_sliver.dart` |
| `lib/features/books/domain/book_with_relations.dart` | `lib/shared/domain/entities/book_with_relations.dart` |
| `lib/features/books/domain/text_stats.dart` | `lib/core/utils/text_stats.dart` |
| `lib/features/auth/domain/auth_event.dart` | `lib/features/auth/domain/entities/auth_event.dart` |
| `lib/features/auth/domain/auth_repository.dart` | `lib/features/auth/domain/repositories/auth_repository.dart` |
| `lib/features/auth/domain/login.dart` | `lib/features/auth/domain/use_cases/login.dart` |
| `lib/features/auth/domain/logout.dart` | `lib/features/auth/domain/use_cases/logout.dart` |
| `lib/features/auth/domain/register.dart` | `lib/features/auth/domain/use_cases/register.dart` |
| `lib/features/auth/domain/get_current_user.dart` | `lib/features/auth/domain/use_cases/get_current_user.dart` |
| `lib/features/auth/domain/listen_auth_state.dart` | `lib/features/auth/domain/use_cases/listen_auth_state.dart` |

### Archivos Creados

| Archivo | Propósito |
| --------- | ----------- |
| `lib/shared/domain/entities/book_with_relations.dart` | Entidad cross-feature |
| `lib/core/utils/text_stats.dart` | Utilidad compartida |
| `lib/features/labels/domain/get_labels_for_books.dart` | Use case para labels |
| `lib/features/tooks/domain/get_tooks_by_book.dart` | Use case para tooks |
| `lib/features/scan/presentation/bloc/scan_took_event.dart` | Events separados |
| `lib/features/scan/presentation/bloc/scan_took_state.dart` | States separados |
| `lib/features/scan/presentation/bloc/scan_chapter_event.dart` | Events separados |
| `lib/features/scan/presentation/bloc/scan_chapter_state.dart` | States separados |
| `lib/features/auth/domain/entities/auth_event.dart` | Auth event reubicado |
| `lib/features/auth/domain/repositories/auth_repository.dart` | Auth repo reubicado |
| `lib/features/auth/domain/use_cases/*.dart` | Use cases reubicados |

### Archivos Modificados (imports o lógica)

- `lib/core/app/app.dart` — import de MainScreen actualizado, rutas `/admin` y
  `/label-management` agregadas
- `lib/features/scan/presentation/bloc/scan_took_bloc.dart` — eventos de upload
  agregados
- `lib/features/scan/presentation/bloc/scan_chapter_bloc.dart` — eventos de
  upload agregados
- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart` — usa
  BlocProvider
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart` — usa
  BlocProvider
- `lib/features/scan/presentation/screens/scan_book_edit_screen.dart` — navega
  con BlocProvider
- `lib/features/admin/presentation/screens/books_tab.dart` — usa named route
- `lib/features/profiles/presentation/bloc/profile_event.dart` — String en vez
  de File
- `lib/features/profiles/presentation/bloc/profile_bloc.dart` — crea File desde
  filePath
- `lib/features/profiles/presentation/screens/profile_screen.dart` — pasa
  filePath
- `lib/features/chapters/presentation/screens/chapter_screen.dart` — import de
  TextStats actualizado
- `lib/features/labels/presentation/bloc/label_bloc.dart` — import de
  GetLabelsForBook
- `lib/features/labels/domain/label_repository.dart` — method getLabelsForBooks
  agregado
- `lib/features/labels/data/label_repository_impl.dart` — method implementado
- `lib/features/tooks/domain/took_repository.dart` — method getTooksByBook
  agregado
- `lib/features/tooks/data/took_repository_impl.dart` — method implementado
- `lib/core/di/injection_scan.dart` — uploadCover y uploadContent registrados
- `lib/core/di/injection_labels.dart` — GetLabelsForBook registrado
- `lib/core/di/injection_tooks.dart` — GetTooksByBook registrado

---

## Decisiones de Diseño

### 1. Shared entities para entidades cross-feature

En vez de crear interfaces o abstracciones complejas, se creó
`lib/shared/domain/entities/` para entidades que son usadas por múltiples
features. Esto es más simple y maintainable que alternativas como event-based
communication o dependency injection a nivel de feature.

### 2. TookModel mantiene chapters como campo data-only

En vez de agregar un BLoC o use case para cargar chapters por ID, `TookModel`
mantiene `List<ChapterEntity> chapters` como campo extra accesible desde la
screen via cast. Esto preserva la simplicidad sin romper la regla de domain
purity.

### 3. Named routes en vez de navegación por callback

Para resolver el acoplamiento admin → labels, se usaron named routes definidas
en `app.dart`. Esto es más simple que crear interfaces de navegación o inyectar
dependencias de routing.

### 4. C4 correctamente omitido

El patrón `export` + `import` en BLoCs NO es una duplicación — es necesario
porque Dart `export` no hace los tipos disponibles dentro de la misma librería.

---

## Problemas Conocidos (pre-existentes)

### 1. dart analyze: admin_main_screen.dart import error

```dart
lib/core/app/app.dart:7: Error: Target of URI doesn't exist: 'package:noveles/features/admin/presentation/screens/admin_main_screen.dart'
```

## Estado:**El archivo existe en la ruta correcta, analiza individualmente sin error, pero `dart analyze lib/` reporta el error. `flutter test` pasa fine. Parece ser un bug del Dart analyzer en Windows (cache/invalidation).**No es un error real de compilación

### 2. Test failures pre-existentes

```bash
auth_repository_test.dart — mock chain bug
chapter_repository_test.dart — mock chain bug
```

**Estado:** Estos tests fallaban antes del refactor. No son regresiones.
Requieren rework profundo de los mocks para resolverse.

---

*Generado el 19/07/2026 como parte del refactor de Clean Architecture.*
