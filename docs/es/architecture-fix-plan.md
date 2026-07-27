# Plan de Reparación — Clean Architecture Audit (v2 Corregido)

**Fecha:** 2026-07-25
**Auditoría:** 3 sub-agentes (Architecture, State Management, Books Deep Dive)
**Revisión:** 3 sub-agentes (Reality Check, Dependency Analysis, Risk Assessment)
**Resultado original:** 25 críticos, 19 warnings, 8 mediums, 10 lows

---

## Resumen de Correcciones v2

| Paso | Problema en v1 | Corrección |
|------|---------------|------------|
| 1.2 | Decía "agregar campo chapters" — ya existe | Solo eliminar casts + agregar took_screen.dart:26 |
| 1.3 | Fallback secuencial preservaba el bug | Eliminar fallback, fallar duro si RPC no disponible |
| 1.4 | No mencionaba AuthBloc dependency ni LogoutFooter | Agregar parámetro `UserRole role`, desacoplar LogoutFooter |
| 2.3 | Mover a books/domain/ no resuelve coupling | Retirar paso — requiere diseño más profundo |
| 2.4 | Decía 12 pantallas, son 53 llamadas (22 válidas) | Reducir a ~18 sitios problemáticos reales |
| Nuevo | N+1 queries en favorites ignorado | Agregado como 1.5 |
| Nuevo | B2 shadowed getIt ignorado | Agregado como paso en 2.4 |
| Nuevo | Test de código muerto (3.1) | Agregado limpieza de test |

---

## FASE 1 — BLOCKERS (urgente, antes del próximo PR)

### 1.1 Mover composition root fuera de core/

- **RESTRICCIÓN:** Este paso DEBE ser UN SOLO COMMIT para que `git revert` funcione correctamente
- CREAR directorio `lib/bootstrap/`
- MOVER `lib/core/di/injection.dart` → `lib/bootstrap/injection.dart`
- MOVER `lib/core/app/app.dart` → `lib/bootstrap/app.dart`
- ACTUALIZAR las **24 importaciones** afectadas (1 en main.dart, 23 en features/)
- VERIFICAR que `core/` ya NO importa de `features/`
- Comando verificación: `dart analyze lib/core/` (debe mostrar 0 errores de dependencia)

**Nota:** Después de este paso, `bootstrap/app.dart` seguirá importando features (auth, admin, scan, app, labels). Esto es aceptable — el objetivo es que `core/` no conozca features, y eso se cumple. El routing completo se refactoriza en una FUTURE phase.

**Archivos a modificar:**
- CREAR `lib/bootstrap/` (directorio nuevo)
- MOVER `lib/core/di/injection.dart` → `lib/bootstrap/injection.dart`
- MOVER `lib/core/app/app.dart` → `lib/bootstrap/app.dart`
- ACTUALIZAR `lib/main.dart` — import apunta a `bootstrap/app.dart` y `bootstrap/injection.dart`
- ACTUALIZAR 23 archivos en features/ que importen `core/di/injection.dart`

### 1.2 Eliminar cast is TookModel en presentation

- **NOTA:** El campo `List<ChapterEntity> chapters` YA EXISTE en `TookEntity` (línea 13). No hay que agregar nada al entity ni al model. Solo eliminar los casts.

**Cast a eliminar:**

| Archivo | Línea | Cast actual | Fix |
|---------|-------|-------------|-----|
| `lib/features/books/presentation/screens/book_screen.dart` | 57 | `(took is TookModel) ? took.chapters : <ChapterEntity>[]` | `took.chapters` |
| `lib/features/books/presentation/screens/book_screen.dart` | 78 | `(firstTook is TookModel) ? firstTook.chapters : <ChapterEntity>[]` | `firstTook.chapters` |
| `lib/features/tooks/presentation/screens/took_screen.dart` | 26 | `(widget.tooks is TookModel) ? (widget.tooks as TookModel).chapters : []` | `widget.tooks.chapters` |

**Pasos:**
1. Eliminar el cast en `book_screen.dart:57` — reemplazar por `took.chapters`
2. Eliminar el cast en `book_screen.dart:78` — reemplazar por `firstTook.chapters`
3. Eliminar el cast en `took_screen.dart:26` — reemplazar por `widget.tooks.chapters`
4. VERIFICAR: `dart analyze lib/features/books/` y `dart analyze lib/features/tooks/`

### 1.3 Transacciones en operaciones CRUD de books

- ARCHIVO: `lib/features/books/data/book_repository_impl.dart`
- LÍNEAS: 62-123 (createBook), 127-172 (updateBook)
- PROBLEMA: delete+insert de genres/labels sin transacción — riesgo de pérdida de datos

**Pasos:**
1. Crear función SQL `upsert_book_with_relations` en `supabase/migrations/`
2. Recibir JSON con book, genres[], labels[]
3. Dentro de la función: BEGIN → delete genres → insert genres → delete labels → insert labels → COMMIT
4. **INCLUIR** el upsert del author (líneas 65-81 del createBook actual) en la misma transacción
5. Modificar `book_repository_impl.dart` para llamar al RPC
6. **NO INCLUIR FALLBACK SECUENCIAL** — si el RPC falla, retornar error explícito. El fallback preserva el bug de pérdida de datos.
7. Agregar test de fallo parcial en `test/repositories/book_repository_test.dart` (no existe actualmente)
8. VERIFICAR: Test manual — crear libro con 3 genres, actualizar a 1 genre, verificar que no quedan huérfanos

**RESTRICCIÓN:** La migración SQL DEBE desplegarse en Supabase ANTES del cambio en Dart. Orden de deploy: SQL → Dart.

### 1.4 Desacoplar app_drawer.dart (mega-coupler)

- ARCHIVO: `lib/features/app/presentation/widgets/app_drawer.dart`
- PROBLEMA: Importa de auth, books/favorites, labels, profiles (4 features)

**Imports actuales del drawer:**
- `core/di/injection.dart` (getIt)
- `features/auth/presentation/bloc/auth_bloc.dart` ← problemático
- `features/books/favorites/presentation/bloc/favorite_bloc.dart` ← problemático
- `features/books/favorites/presentation/screens/favorites_screen.dart` ← problemático
- `features/labels/presentation/screens/label_management_screen.dart` ← problemático
- `features/profiles/domain/user_entity.dart` ← problemático
- `features/profiles/domain/user_role.dart` ← problemático
- `features/profiles/presentation/screens/profile_screen.dart` ← problemático

**Pasos:**
1. Agregar parámetro `UserRole role` como required al constructor del drawer (ya tiene `user` y `role` pero los ignora)
2. Eliminar `BlocBuilder<AuthBloc, AuthState>` del drawer — recibir `role` desde el padre
3. Mover `LogoutFooter` (`lib/features/app/presentation/widgets/drawer/logout_footer.dart`) a `lib/shared/presentation/widgets/drawer/logout_footer.dart`
4. Crear callbacks: `onNavigateToProfile`, `onNavigateToFavorites`, `onNavigateToLabels`, `onLogout`
5. Eliminar imports de features/ del drawer
6. Actualizar `main_screen.dart` y `scan_main_screen.dart` para pasar `role` y callbacks
7. VERIFICAR: Navegación completa del drawer funciona en todas las pantallas

### 1.5 Fix N+1 queries en favorites (NUEVO)

- ARCHIVO: `lib/features/books/favorites/presentation/screens/favorites_screen.dart:73-74`
- PROBLEMA: `FutureBuilder` dentro de `ListView.builder` dispara 1 query Supabase por cada favorito visible
- Con 20 favoritos = 20 queries + 20 select queries
- **No hay test para esto**

**Pasos:**
1. Modificar `getFavorites` en el repository para incluir join con books en una sola query
2. O alternativamente: hacer batch fetch de todos los bookIds después de obtener la lista
3. Eliminar el `FutureBuilder` interno del `ListView.builder`
4. VERIFICAR: Performance con 20+ favoritos — debe hacer 1 query en vez de N

---

## FASE 2 — CONSISTENCIA (después de Fase 1)

### 2.1 Crear use cases para favorites

- **NOTA:** Los use cases serían wrappers triviales sin lógica adicional. Solo crear si se prevé lógica futura (validación, transformación). Si no, OMITIR este paso — el patrón BLoC→Repository ya es aceptable.

**Crear `lib/features/books/favorites/domain/use_cases/`:**
- `toggle_favorite_use_case.dart` — wrapper de repository.toggleFavorite
- `get_favorites_use_case.dart` — wrapper de repository.getFavorites
- `is_favorite_use_case.dart` — wrapper de repository.isFavorite

**Modificar `lib/features/books/favorites/presentation/bloc/favorite_bloc.dart`:**
- Inyectar use cases en vez de repository
- Cambiar llamadas directas a use cases
- VERIFICAR: `dart analyze lib/features/books/favorites/`

### 2.2 Crear use cases para admin analytics

- **MISMA NOTA que 2.1:** Solo crear si se prevé lógica futura.

**Crear `lib/features/admin/domain/use_cases/`:**
- `get_analytics_overview_use_case.dart`
- `get_views_trend_use_case.dart`
- `get_top_books_use_case.dart`

**Modificar `lib/features/admin/presentation/bloc/admin_analytics_bloc.dart`:**
- Inyectar use cases en vez de repository
- VERIFICAR: `dart analyze lib/features/admin/`

### 2.3 ~~Mover BookWithRelations~~ — RETIRADO

- **RAZÓN:** `BookWithRelations` importa entidades de 4 features (books, genres, labels, tooks). Moverlo a `features/books/domain/` no resuelve el cross-feature coupling — solo cambia la dirección de la dependencia.
- **REQUIERE:** Diseño más profundo (interfaces base en shared, o kernel compartido). Dejar para fase futura.
- **ESTADO:** Retirado del plan actual.

### 2.4 Unificar acceso a getIt (ALCANCE REDUCIDO)

- **RESTRICCIÓN:** NO tocar `BlocProvider(create: (_) => getIt<T>())` — es patrón válido de flutter_bloc + get_it
- **RESTRICCIÓN:** NO tocar llamadas en injection files — esas son el composition root

**Sitios problemáticos reales (~18):**

| Archivo | Línea | Tipo de llamada | Fix |
|---------|-------|-----------------|-----|
| `tooks/presentation/screens/took_screen.dart` | 40, 87 | `getIt<GetReadChapterIds>()` directo | Inyectar vía BLoC |
| `books/presentation/screens/book_screen.dart` | 44 | `GetIt.instance<TrackBookView>()` directo | Inyectar vía BLoC |
| `books/presentation/screens/book_screen.dart` | 85, 102 | `getIt<ChapterBloc>()`, `getIt<FavoriteBloc>()` | Inyectar vía BlocProvider |
| `admin/presentation/screens/genres_tab.dart` | 15 | `getIt<GenreBloc>()` | Inyectar vía BlocProvider |
| `admin/presentation/screens/admin_dash_screen.dart` | 62, 66-67, 73 | `getIt<AdminBloc>()`, etc. | Inyectar vía BlocProvider |
| `scan/presentation/screens/scan_main_screen.dart` | ~20 | `getIt<GenreCubit>()` | Inyectar vía BlocProvider |
| `scan/presentation/screens/scan_book_edit_screen.dart` | ~15 | `getIt<GenreCubit>()` | Inyectar vía BlocProvider |
| `app/presentation/widgets/book_card_vertical.dart` | ~4 | `getIt<CoverUrlService>()` | Inyectar vía constructor |
| Y ~6 más | — | — | Evaluar caso por caso |

**Fix B2 (NUEVO):**
- ARCHIVO: `lib/features/books/di/injection_books.dart:22`
- PROBLEMA: `final getIt = GetIt.instance;` sombrea la variable global
- FIX: Eliminar esta línea, usar import de `core/di/injection.dart` (o `bootstrap/injection.dart` después de 1.1)

- VERIFICAR: `dart analyze` completo

### 2.5 Mover fromJson de admin/domain a data/

- ARCHIVO: `lib/features/admin/domain/analytics_entities.dart:16-65`
- PROBLEMA: `fromJson` en domain layer (serialization leak)
- CREAR: `lib/features/admin/data/analytics_model.dart` con fromJson/toJson
- MANTENER: Entities en domain/ como pure data classes
- ACTUALIZAR: Repository impl para usar el model en vez de la entity para deserializar
- VERIFICAR: `dart analyze lib/features/admin/`

---

## FASE 3 — LIMPIEZA (después de Fase 2)

### 3.1 Eliminar código muerto

- ARCHIVO: `lib/features/books/presentation/screens/widgets/book_detail_content.dart`
  - **NOTA:** Path correcto incluye `widgets/` intermedio
- VERIFICAR: `grep -r "BookDetailContent" lib/` — solo debe retornar resultados en el propio archivo
- ELIMINAR: El archivo completo
- TAMBIÉN: `CardInfoDetail` (solo se usa en el archivo muerto)
- **ELIMINAR TEST:** `test/widgets/book_detail_content_test.dart` (181 líneas) — testeaba código muerto, se romperá si no se elimina

### 3.2 Merge de GenreState duplicado

**Archivos:**
- `lib/features/genres/presentation/bloc/genre_state.dart` (usado por GenreBloc — abstract, tiene campo `message`)
- `lib/features/genres/presentation/genre_state.dart` (usado por GenreCubit — no abstract, sin `message`)

**Decisión:** Usar el de bloc (tiene campo `message`) como base
- MERGE: Unificar en un solo archivo que soporte ambos casos
- HACER: La clase base debe ser abstract para que tanto GenreBloc como GenreCubit la usen
- ACTUALIZAR: GenreCubit para importar del nuevo ubicación
- VERIFICAR: `dart analyze lib/features/genres/`
- VERIFICAR: Tests existentes (`genre_bloc_test.dart`, `genre_cubit_test.dart`) pasan

### 3.3 Extraer select string duplicado

- ARCHIVO: `lib/features/books/data/book_repository_impl.dart`
- LÍNEAS: 26, 50, 326, 344
- PROBLEMA: String de 150 chars duplicado 4 veces
- CREAR: Constante `kBookSelectWithRelations` en el archivo o en un archivo de constants
- REEMPLAZAR: Las 4 ocurrencias por la constante
- VERIFICAR: `dart analyze lib/features/books/data/`

**RESTRICCIÓN:** Ejecutar DESPUÉS de FASE 2.3 si se reactiva, ya que ambos tocan `book_repository_impl.dart`

### 3.4 Agregar LRU a ChapterBloc._cache

- ARCHIVO: `lib/features/chapters/presentation/bloc/chapter_bloc.dart:16`
- PROBLEMA: Map `_cache` crece sin límite
- SOLUCIÓN: Reemplazar Map por un LRU Cache de tamaño máximo (ej: 50 capítulos)
- OPCIÓN: Usar `collection` package o implementar LRU manual con LinkedHashMap
- AGREGAR: Limpiar cache en `_setChapterOrder` (línea 117) cuando cambia de libro
- VERIFICAR: Cargar >50 capítulos y verificar que los más viejos se eliminan

### 3.5 Corregir barrel files incompletos

- ARCHIVO: `lib/features/books/domain/books.dart`
- FALTAN EXPORTS: `get_most_viewed_books.dart`, `get_recent_views.dart`, `track_book_view.dart`
- AGREGAR: Los exports faltantes
- VERIFICAR: Todos los use cases se pueden importar vía el barrel

### 3.6 Nomenclatura inconsistente

- ARCHIVO: `lib/features/books/presentation/screens/widgets/sliver_app_bar_book.dart:15`
  - **NOTA:** Path correcto incluye `screens/widgets/`
- PROBLEMA: Parámetro `books` (plural) para un solo libro
- CAMBIAR: `books` → `book` en el constructor
- ACTUALIZAR: Call site en `book_screen.dart:107` — `SliverAppBarBook(books: book)` → `SliverAppBarBook(book: book)`
- VERIFICAR: `dart analyze lib/features/books/`

---

## Comandos de Verificación Globales

Después de CADA fase, ejecutar:
```bash
dart analyze lib/
flutter test
```

Después de completar TODAS las fases:
```bash
dart analyze lib/ --fatal-infos
flutter test --coverage
```

---

## Orden de Ejecución Recomendado

1. **Fase 1.2** (eliminar casts) — rápido, sin dependencias, arregla 2 critical issues
2. **Fase 1.1** (mover composition root) — mecánico, alto volumen pero bajo riesgo, UN SOLO COMMIT
3. **Fase 1.3** (transacciones DB) — independiente, fix de integridad de datos
4. **Fase 1.4** (desacoplar drawer) — manejar AuthBloc primero, luego extraer
5. **Fase 1.5** (N+1 queries) — fix de performance para usuarios
6. **Fase 2.1-2.2** (use cases) — solo si se decide que aportan valor
7. **Fase 2.4** (unificar getIt) — solo los ~18 sitios problemáticos
8. **Fase 2.5** (fromJson admin) — clean
9. **Fase 3.1-3.6** (limpieza) — en cualquier orden

---

## Hallazgos Detallados por Sub-Agente

### Arquitectura Limpia (23 violaciones)

| # | Severidad | Archivo | Violación |
|---|-----------|---------|-----------|
| C1 | Crítico | `tooks/presentation/screens/took_screen.dart:5` | Feature→Feature coupling (auth) |
| C2 | Crítico | `tooks/presentation/screens/took_screen.dart:8` | Feature→Feature coupling (chapters) |
| C3 | Crítico | `tooks/presentation/screens/took_screen.dart:9` | Feature→Feature coupling (chapter_screen) |
| C4 | Crítico | `admin/presentation/screens/admin_dash_screen.dart:15` | Feature→Feature coupling (labels) |
| C5 | Crítico | `admin/presentation/screens/admin_dash_screen.dart:16` | Feature→Feature coupling (app_drawer) |
| C6 | Crítico | `admin/presentation/screens/admin_dash_screen.dart:17` | Feature→Feature coupling (auth) |
| C7 | Crítico | `admin/presentation/screens/genres_tab.dart:7` | Feature→Feature coupling (genres) |
| C8 | Crítico | `admin/presentation/screens/summary_tab.dart:7` | Feature→Feature coupling (auth) |
| C9 | Crítico | `scan/presentation/screens/scan_main_screen.dart:12` | Feature→Feature coupling (app_drawer) |
| C10 | Crítico | `scan/presentation/screens/scan_main_screen.dart:14` | Feature→Feature coupling (genre_cubit) |
| C11 | Crítico | `scan/presentation/screens/scan_book_edit_screen.dart:15-16` | Feature→Feature coupling (genre) |
| C12 | Crítico | `scan/presentation/screens/widgets/genre_selector.dart:2` | Feature domain→Feature domain |
| C13 | Crítico | `scan/presentation/screens/widgets/took_list_section.dart:2` | Feature domain→Feature domain |
| C14 | Crítico | `app/presentation/screens/main_screen.dart:8-12` | Feature→Feature coupling (auth, books, genres) |
| C15 | Crítico | `tooks/domain/took_entity.dart:2` | Feature→Feature domain coupling (chapters) — **EXISTENTE, aceptado** |
| C16 | Crítico | `tooks/data/took_model.dart:2-3` | Feature→Feature data+domain coupling |
| C17 | Crítico | `books/data/book_model.dart:2-4` | Feature→Feature data coupling (genres, labels, tooks) |
| C18 | Crítico | `auth/data/auth_repository_impl.dart:6` | Feature→Feature data coupling (profiles) |
| C19 | Crítico | `scan/di/injection_scan.dart:4` | Feature→Feature cross-layer coupling |
| C20 | Crítico | `books/presentation/screens/book_screen.dart:20` | Presentation→Data (skips domain!) |
| C21 | Crítico | `core/app/app.dart:5,7-11` | core → features (inverted) — **Fix en 1.1** |
| C22 | Crítico | `core/di/injection.dart:4-13` | core → features (inverted) — **Fix en 1.1** |
| C23 | Crítico | `shared/domain/entities/book_with_relations.dart:1-4` | shared → features (inverted) — **Retirado** |

### Manejo de Estados (3 mediums)

| # | Severidad | Archivo | Problema |
|---|-----------|---------|----------|
| M1 | Medium | `favorites/presentation/bloc/favorite_bloc.dart:11` | Bypass de use cases — **Fix en 2.1** |
| M2 | Medium | `admin/presentation/bloc/admin_analytics_bloc.dart:9` | Bypass de use cases — **Fix en 2.2** |
| M3 | Medium | `chapters/presentation/bloc/chapter_bloc.dart:16` | `_cache` Map sin límite — **Fix en 3.4** |

### Feature Books Deep Dive (3 blockers)

| # | Severidad | Archivo | Problema |
|---|-----------|---------|----------|
| B1 | Crítico | `book_screen.dart:57,78` + `took_screen.dart:26` | Cast runtime a TookModel — **Fix en 1.2** |
| B2 | Crítico | `injection_books.dart:22` | Variable `getIt` sombreada — **Fix en 2.4** |
| B3 | Crítico | `book_repository_impl.dart:62-123, 127-172` | Operaciones no atómicas — **Fix en 1.3** |

### Issues No Abordados (para fase futura)

| # | Descripción | Razón |
|---|-------------|-------|
| C1-C14 | Feature→Feature presentation coupling (12 no abordados) | Requiere diseño de módulos compartidos |
| C15 | TookEntity → ChapterEntity (domain→domain) | Dependencia existente, aceptada |
| C16-C19 | Feature→Feature data coupling | Requiere shared data contracts |

---

## Checklist de Progreso

- [x] Fase 1.1: Mover composition root (1 commit)
- [x] Fase 1.2: Eliminar cast TookModel (3 archivos)
- [ ] Fase 1.3: Transacciones DB (SQL + Dart)
- [ ] Fase 1.4: Desacoplar drawer (AuthBloc + callbacks)
- [ ] Fase 1.5: Fix N+1 queries favorites
- [ ] Fase 2.1: Use cases favorites (opcional)
- [ ] Fase 2.2: Use cases admin analytics (opcional)
- [ ] Fase 2.4: Unificar getIt (~18 sitios + B2 fix)
- [ ] Fase 2.5: Mover fromJson admin
- [ ] Fase 3.1: Eliminar código muerto + test
- [ ] Fase 3.2: Merge GenreState
- [ ] Fase 3.3: Extraer select string
- [ ] Fase 3.4: LRU ChapterBloc cache
- [ ] Fase 3.5: Barrel files
- [ ] Fase 3.6: Nomenclatura books
