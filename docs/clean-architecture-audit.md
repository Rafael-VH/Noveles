# Clean Architecture Audit — Noveles

> Auditoría completa del 18/07/2026 sobre la estructura de arquitectura limpia
  del proyecto.

---

## Índice

- [Reglas de Arquitectura](#reglas-de-arquitectura)
- [Resumen Global](#resumen-global)
- [Violaciones Críticas](#violaciones-críticas-top-5)
- [Auditoría por Feature](#auditoría-por-feature)
- [Lo que el Proyecto Hace Bien](#lo-que-el-proyecto-hace-bien)
- [Plan de Corrección](#plan-de-corrección)
- [Diagrama de Dependencias](#diagrama-de-dependencias)

---

## Reglas de Arquitectura

El proyecto sigue Clean Architecture con esta dirección de dependencias:

```
domain/  → NO depende de nada (capa más interna)
data/    → depende de domain/
presentation/ → depende de domain/
core/    → NO depende de features/
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

## Resumen Global

| Severidad | Cantidad | Descripción |
| ----------- | ---------- | ------------- |
| 🔴 **Crítico** | **4** | Inversión de dependencias core→features, screens bypassing BLoC |
| 🟠 **Alto** | **10** | Acoplamiento cross-feature en domain, dart:io en eventos |
| 🟡 **Menor** | **10** | Estructura inconsistente, imports duplicados, archivos monolíticos |
| **Total** | **24** | |

### Features Completamente Compliant: 0/9

### Features con Violaciones: 9/9

---

## Violaciones Críticas (Top 5)

### 🔴 1. Screens bypassing BLoC para llamar use_cases directamente

## Archivos afectados

- `lib/features/scan/presentation/screens/scan_took_edit_screen.dart:114`
- `lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart:86`

**Problema:** Las pantallas crean use_cases vía `getIt<UploadCover>()` y los
ejecutan directamente, saltándose toda la capa BLoC. Esto rompe el patrón de
presentación.

## Ejemplo del problema

```dart
// ❌ MAL — Screen llama use_case directamente
final uploadCover = getIt<UploadCover>();
final result = await uploadCover(UploadCoverParams(...));

// ✅ BIEN — Screen emite evento al BLoC
context.read<ScanTookBloc>().add(UploadCoverRequested(file: file));
```

**Fix:** Agregar eventos `UploadCoverRequested` y
`UploadChapterContentRequested` al BLoC, mover la lógica de upload ahí, y que la
screen solo emita el evento.

---

### 🔴 2. Core depende de features (dependencia invertida)

## Archivos afectados: (Part 2)

- `lib/core/app/main_screen.dart` — importa books/domain, genres/domain,
  books/presentation, genres/presentation
- `lib/core/presentation/widgets/carousel_appbar_sliver.dart` — importa
  books/domain
- `lib/core/presentation/widgets/app_drawer.dart` — importa auth/presentation,
  admin/presentation, profiles/presentation

**Problema:** `core/` es la capa más interna y NO debería conocer `features/`.
La flecha de dependencia está invertida.

**Fix:** Mover estos archivos a un módulo `features/app/` o crear interfaces de
navegación en core que features implemente.

---

### 🔴 3. Acoplamiento cross-feature vía BookWithRelations

**Archivo:** `lib/features/books/domain/book_with_relations.dart`

## Dependencias que importa

- `genres/domain/genre_entity.dart`
- `labels/domain/label_entity.dart`
- `tooks/domain/took_entity.dart`

**Problema:** Una sola entidad crea una telaraña de dependencias entre 4
features. Al menos 5 archivos en 4 features distintas dependen de esta entidad.

**Fix:** Crear un módulo compartido `lib/shared/domain/entities/` o hacer que
`BookWithRelations` use solo IDs en domain y se hidrate en data.

---

### 🔴 4. TookEntity embede ChapterEntity

**Archivo:**`lib/features/tooks/domain/took_entity.dart`**Problema:**
`TookEntity` tiene `List<ChapterEntity>` como campo, creando una
dependencia cross-feature en domain.

**Fix:** Cambiar a `List<int> listChapterIds` (IDs puros) y hidratar en data
layer.

---

### 🟠 5. dart:io en BLoC Event

**Archivo:**`lib/features/profiles/presentation/bloc/profile_event.dart:1`**Prob
lema:** El evento `PickAvatar` lleva un objeto `File` de `dart:io`,
creando una dependencia de plataforma en lo que debería ser un transportador de
datos puro.

**Fix:** Cambiar `File file` por `String filePath` y crear el objeto `File` en
la screen.

---

## Auditoría por Feature

### CORE

#### ✅ Correcto

- `errors/failure.dart` y `errors/result.dart` son Dart puro
- `cover/cover_url_service.dart` es infraestructura pura
- `constants/`, `utils/` son puros
- `presentation/bloc/theme_bloc/` es autocontenido
- DI files (`injection.dart` + todos `injection_*.dart`) son la capa de wiring
  correctamente

#### ❌ Violaciones

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| C1 | `app/main_screen.dart` | Core importa features/domain Y features/presentation | 🔴 Crítico |
| C2 | `widgets/carousel_appbar_sliver.dart` | Core widget importa features/books/domain | 🔴 Crítico |
| C3 | `widgets/app_drawer.dart` | Core widget importa features/auth,admin,profiles/presentation | 🔴 Crítico |

---

### AUTH

#### ✅ Correcto (Part 2)

- Entidades puras con equatable
- 5 use cases dependen solo de `core/errors` + `auth_repository.dart`
- `AuthRepositoryImpl` depende de domain + Supabase
- BLoC usa use_cases exclusivamente
- Screens importan solo de `auth/presentation/` + `auth/domain/`

#### ❌ Violaciones (Part 2)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| A1 | Domain folder structure | Estructura plana (sin subdirectorios entities/, use_cases/, repositories/) | 🟡 Menor |

---

### BOOKS

#### ✅ Correcto (Part 3)

- `BookEntity` es entidad escalar pura — sin imports de otras features
- 9 use cases dependen solo de `core/errors` + `book_repository.dart`
- `BookModel` y `BookRepositoryImpl` en data/
- `BookBloc` recibe use cases por constructor, nunca llama repository

#### ❌ Violaciones (Part 3)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| B1 | `domain/book_with_relations.dart` | Domain importa 3 features externas (genres, labels, tooks) | 🟠 Alto |
| B2 | `domain/get_book_labels.dart` | Nombre engañoso — es un use case de books que accede labels data | 🟡 Menor |

---

### CHAPTERS

#### ✅ Correcto (Part 4)

- `ChapterEntity` pura — sin imports externos
- 7 use cases dependen solo de `core/errors` + `chapter_repository.dart`
- `ChapterBloc` usa solo `GetChapterContent` use case

#### ❌ Violaciones (Part 4)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| CH1 | `presentation/chapter_screen.dart` | Presentation importa `books/domain/text_stats.dart` | 🟠 Alto |
| CH2 | `presentation/bloc/chapter_bloc.dart` | Duplicación export+import de event/state | 🟡 Code smell |

---

### GENRES

#### ✅ Correcto (Part 5)

- `GenreEntity` pura — sin imports de features externas
- 5 use cases dependen solo de `core/errors` + `genre_repository.dart`
- `GenreBloc` usa use_cases

#### ❌ Violaciones (Part 5)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| G1 | `presentation/screens/genre_screen.dart` | Importa `books/domain/book_with_relations.dart` | 🟠 Alto |

---

### LABELS

#### ✅ Correcto (Part 6)

- `LabelEntity` pura
- 6 use cases dependen solo de domain
- `LabelModel` y `LabelRepositoryImpl` en data/

#### ❌ Violaciones (Part 6)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| L1 | `presentation/bloc/label_bloc.dart` | BLoC importa `books/domain/get_book_labels.dart` | 🟠 Alto |
| L2 | `presentation/bloc/label_bloc.dart` | Duplicación export+import | 🟡 Code smell |

---

### PROFILES

#### ✅ Correcto (Part 7)

- `UserEntity` pura
- 5 use cases dependen solo de domain + `core/errors`
- `ProfileBloc` usa use_cases

#### ❌ Violaciones (Part 7)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| P1 | `presentation/bloc/profile_event.dart` | Evento importa `dart:io` (objeto File) | 🟠 Alto |

---

### TOOKS

#### ✅ Correcto (Part 8)

- 5 use cases dependen solo de domain + `core/errors`
- `TookModel` y `TookRepositoryImpl` en data/

#### ❌ Violaciones (Part 8)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| T1 | `domain/took_entity.dart` | Domain importa `chapters/domain/chapter_entity.dart` | 🟠 Alto |
| T2 | `domain/tooks.dart` | Falta use case `get_tooks_by_book` | 🟡 Menor |

---

### SCAN

#### ✅ Correcto (Part 9)

- ScanBloc usa use_cases de books (no repositories) — patrón correcto
- Events y States son puros
- 3 BLoCs siguen el patrón correcto

#### ❌ Violaciones (Part 9)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| S1 | `bloc/scan_took_bloc.dart` | Events+States+BLoC en un solo archivo | 🟡 Code smell |
| S2 | `bloc/scan_chapter_bloc.dart` | Mismo problema — archivo monolítico | 🟡 Code smell |
| S3 | `bloc/scan_bloc.dart` | Duplicación export+import | 🟡 Code smell |
| S4 | `screens/scan_took_edit_screen.dart` | Crea BLoC con `getIt<>()` en vez de `context.read<>()` | 🟠 Alto |
| S5 | `screens/scan_chapter_edit_screen.dart` | Mismo problema con `getIt<>()` | 🟠 Alto |
| S6 | `screens/scan_took_edit_screen.dart:114` | Screen llama `getIt<UploadCover>()` directamente | 🔴 Crítico |
| S7 | `screens/scan_chapter_edit_screen.dart:86` | Screen llama `getIt<UploadChapterContent>()` directamente | 🔴 Crítico |
| S8 | Feature structure | Sin capa domain/ o data/ propia | 🟡 Design note |

---

### ADMIN

#### ✅ Correcto (Part 10)

- `AdminBloc` usa use_cases de books — nunca toca repositories
- `AdminUsersBloc` usa use_cases de profiles
- Screens son presentación limpia
- Aliasing inteligente para evitar colisión de eventos

#### ❌ Violaciones (Part 10)

| # | Archivo | Violación | Severidad |
| --- | --------- | ----------- | ---------- |
| ADM1 | Feature structure | Sin capa domain/ o data/ propia | 🟡 Design note |
| ADM2 | `screens/books_tab.dart` | Importa `labels/presentation/screens/label_management_screen.dart` | 🟠 Alto |
| ADM3 | `admin_state.dart` | Importa `books/domain/book_with_relations.dart` | 🟡 Acceptable |

---

## Lo que el Proyecto Hace Bien

| # | Aspecto | Detalle |
| --- | --------- | --------- |
| 1 | **BLoC → Use Case** | Ningún BLoC importa repositories directamente. Siempre pasa por use_cases. |
| 2 | **Result Pattern** | `Result<T>`, `Ok<T>`, `Err<T>` usado consistentemente en todos los use cases. |
| 3 | **Entities Inmutables** | Todas las entidades usan `copyWith` y `equatable`. |
| 4 | **Serialización en Data** | `fromJson`/`toJson` está correctamente confinado a `data/models/`. |
| 5 | **DI Limpia** | GetIt registra implementaciones contra interfaces. Separado por feature. |
| 6 | **Traducción de Errores** | `data/repositories/` captura Supabase exceptions y devuelve Failures de dominio. |
| 7 | **Testing** | 217 tests pass, estructura de test refleja la estructura de lib/. |

---

## Plan de Corrección

### Fase A — Críticas (debería hacerse primero)

| # | Tarea | Archivos | Esfuerzo |
| --- | ------- | ---------- | ---------- |
| A1 | Mover upload logic de scan screens al BLoC | `scan_took_edit_screen.dart`, `scan_chapter_edit_screen.dart`, `scan_took_bloc.dart`, `scan_chapter_bloc.dart` | Alto |
| A2 | Mover `main_screen` de `core/app/` a `features/app/` o crear interfaz de navegación | `main_screen.dart`, `app_drawer.dart`, `carousel_appbar_sliver.dart` | Alto |
| A3 | Resolver acoplamiento `BookWithRelations` → crear módulo compartido o usar IDs | `book_with_relations.dart`, 5+ consumidores | Alto |
| A4 | Cambiar `TookEntity.chapter` a `List<int>` IDs | `took_entity.dart`, `took_model.dart`, hidratación en data | Medio |

### Fase B — Altas

| # | Tarea | Archivos | Esfuerzo |
| --- | ------- | ---------- | ---------- |
| B1 | Quitar `dart:io` de `profile_event.dart` | `profile_event.dart`, `profile_screen.dart` | Bajo |
| B2 | Mover `text_stats.dart` a `core/utils/` | `text_stats.dart` + 2 consumidores | Bajo |
| B3 | Quitar acoplamiento `label_bloc.dart` → `books/domain/` | `label_bloc.dart`, crear `get_labels_for_book.dart` en labels | Medio |
| B4 | Quitar acoplamiento `genre_screen.dart` → `books/domain/` | `genre_screen.dart`, mover a books o crear interface | Medio |
| B5 | Quitar acoplamiento `chapter_screen.dart` → `books/domain/` | `chapter_screen.dart` | Bajo |
| B6 | Quitar acoplamiento `admin/books_tab.dart` → `labels/presentation/` | `books_tab.dart`, usar ruta o callback | Bajo |
| B7 | Quitar `getIt<>()` de scan screens, usar `context.read<>()` | `scan_took_edit_screen.dart`, `scan_chapter_edit_screen.dart` | Bajo |

### Fase C — Menores

| # | Tarea | Archivos | Esfuerzo |
| --- | ------- | ---------- | ---------- |
| C1 | Estructurar auth/domain/ con subdirectorios | `auth/domain/` (reorganizar) | Bajo |
| C2 | Separar scan_took_bloc.dart en event/state/bloc files | `scan_took_bloc.dart` | Bajo |
| C3 | Separar scan_chapter_bloc.dart en event/state/bloc files | `scan_chapter_bloc.dart` | Bajo |
| C4 | Eliminar duplicación export+import en todos los BLoCs | 10 archivos BLoC | Bajo |
| C5 | Agregar use case `get_tooks_by_book` | `tooks/domain/use_cases/` | Bajo |

---

## Diagrama de Dependencias

### Estado Actual (con violaciones)

```dart
core/app/main_screen ──────→ features/books/domain
                          ──→ features/genres/domain
                          ──→ features/books/presentation
                          ──→ features/genres/presentation

core/widgets/carousel ─────→ features/books/domain

core/widgets/app_drawer ──→ features/auth/presentation
                         ──→ features/admin/presentation
                         ──→ features/profiles/presentation

features/books/domain ─────→ features/genres/domain  (BookWithRelations)
                          ──→ features/labels/domain
                          ──→ features/tooks/domain

features/tooks/domain ─────→ features/chapters/domain (TookEntity)

features/chapters/presentation → features/books/domain (TextStats)

features/labels/presentation ──→ features/books/domain (GetBookLabels)

features/genres/presentation ──→ features/books/domain (BookWithRelations)

features/admin/presentation ───→ features/labels/presentation (LabelManagementScreen)

features/scan/screens ──────────→ use_cases directamente (bypass BLoC)
```

### Estado Objetivo

```bash
core/                    ← NO depende de features/
features/app/            ← main_screen, app_drawer, carousel (si necesitan features)

shared/domain/entities/  ← BookWithRelations (con IDs), relations interfaces
shared/utils/            ← TextStats

features/books/          ← usa solo shared, core, y sus propios domain/data/presentation
features/chapters/       ← usa solo shared, core, y sus propios
features/genres/         ← usa solo shared, core, y sus propios
features/labels/         ← usa solo shared, core, y sus propios
features/tooks/          ← usa solo shared, core, y sus propios
features/scan/           ← usa use_cases de otras features (permitido)
features/admin/          ← usa use_cases de otras features (permitido)
features/profiles/       ← usa solo shared, core, y sus propios
features/auth/           ← usa solo shared, core, y sus propios
```

---

*Generado por auditoría de ArquiC — 18/07/2026*
