# Noveles — Documentación general del proyecto

> Noveles es una app lectora y gestora de novelas construida con **Flutter**,
> **Clean Architecture** (feature-first) y **BLoC**, sobre un backend **Supabase**
> (Postgres + Auth + Storage). Soporta tres roles — **usuario lector**, **scan**
> (creador de contenido) y **admin** — cada uno con pantallas y permisos propios.
>
> Este documento consolida la visión transversal del proyecto. Para el detalle
> por tema, seguí los enlaces a la documentación existente en `docs/es/`.

---

## 1. Resumen ejecutivo

| Aspecto | Detalle |
|---|---|
| **Nombre / paquete** | `noveles` v1.1.0 |
| **Plataforma** | Flutter 3.3+ / Dart `>=3.3.4 <4.0.0` (Android, iOS, Web) |
| **Arquitectura** | Clean Architecture, feature-first, 3 capas por feature (`domain` / `data` / `presentation`) |
| **Manejo de estado** | BLoC / Cubit (`bloc`, `flutter_bloc`, `equatable`) |
| **Inyección de dependencias** | GetIt (service locator, sin código generado) |
| **Backend** | Supabase: Postgres 17 + Auth + Storage (buckets `covers`, `chapters`, `avatars`) |
| **Roles** | `user`, `scan`, `admin`, `suspended` |
| **Testing** | `flutter_test` + `mocktail` + `bloc_test` — 64 archivos en `test/` |
| **Idioma de UI y docs** | Español (rioplatense); documentación bilingüe ES/EN |

## 2. Mapa de módulos (`lib/`)

```text
lib/
├── main.dart                 # Punto de entrada: dotenv → Supabase → DI → runApp
├── bootstrap/                # Composición raíz (app.dart, injection.dart)
├── core/                     # Transversal: errores, tema, supabase, constants, utils
├── shared/                   # Entidades y widgets compartidos entre features
└── features/                 # 10 features (feature-first)
    ├── admin/                # Panel de administración + analíticas
    ├── app/                  # Shell del lector: MainScreen, drawer, secciones del home
    ├── auth/                 # Autenticación (login, registro, sesión)
    ├── books/                # Feature principal: CRUD de libros + subfeature favorites/
    ├── chapters/             # Capítulos y pantalla de lectura
    ├── genres/               # Géneros (clasificación de libros)
    ├── labels/               # Etiquetas + Label Rules automáticas
    ├── profiles/             # Perfiles, roles, avatar, contraseña
    ├── scan/                 # Creación de contenido (solo presentación, reutiliza UC)
    └── tooks/                # Tomos/volúmenes de un libro
```

### Estructura interna de una feature

```text
lib/features/{feature}/
├── domain/                   # Dart puro: entities, repo interfaces, use_cases
├── data/                     # models + *_repository_impl.dart (llamadas a Supabase)
├── presentation/
│   ├── bloc/                 # Blocs / Cubits + events + states
│   ├── screens/              # Pantallas
│   └── widgets/              # Widgets propios de la feature
└── di/                       # injection_{feature}.dart (registro GetIt)
```

**Regla de dependencia**: `presentation` → `domain` ← `data`. `domain` es Dart
puro (sin imports de Flutter ni de Supabase), lo que lo hace directamente
testeable. Los repositorios `data` implementan las interfaces de `domain` y son
los únicos que hablan con Supabase.

> Detalle: [es/architecture/overview.md](es/architecture/overview.md)

## 3. Features e inventario por capa

### 3.1 Resumen cuantitativo

| Concepto | Cantidad | Notas |
|---|---|---|
| Features en `lib/features/` | 10 | + subfeature `books/favorites` |
| Entidades de dominio | 13 | `BookEntity`, `BookWithRelations`, `ChapterEntity`, `ChapterRef`, `TookEntity`, `GenreEntity`, `LabelEntity`, `LabelRuleEntity`, `UserEntity`, `FavoriteEntity`, 3 de analíticas |
| Casos de uso | 58 | 10 features (ver catálogo en `es/domain/use-cases.md`) |
| Repositorios (interfaz + impl) | 10 | Auth, Book, Favorite, Chapter, Genre, Label, LabelRule, Profiles, Took, Analytics |
| Blocs / Cubits | 19 | 18 en features + `ThemeBloc` en core |
| Pantallas (`*_screen.dart`) | 22 | + 5 tabs de admin |
| Archivos de test | 67 | 65 tests + 2 helpers |

### 3.2 Features, Blocs y pantallas

| Feature | Blocs/Cubits | Pantallas principales | Rol que la usa |
|---|---|---|---|
| `auth` | `AuthBloc` | `LoginScreen`, `RegisterScreen` | todos |
| `app` (home) | `RecentViewsBloc`, `PopularViewsBloc` | `SplashScreen`, `MainScreen` | user (lector) |
| `books` | `BookBloc`, `FavoriteBloc` | `BookScreen`, `FavoritesScreen` | todos (lectura) |
| `chapters` | `ChapterBloc` | `ChapterScreen` (lector con precarga y ajustes) | user |
| `genres` | `GenreBloc` (app/admin) + `GenreCubit` (scan, legacy) | `GenreScreen`, selector en scan | admin/scan |
| `labels` | `LabelBloc`, `LabelRulesBloc` | `LabelManagementScreen`, `LabelRulesAdminTab` | admin/scan |
| `profiles` | `ProfileBloc` | `ProfileScreen` | todos |
| `tooks` | — | `TookScreen` | user (lectura) |
| `scan` | `ScanBookBloc`, `ScanCoverBloc`, `ScanChapterBloc`, `ScanTookBloc` | `ScanMainScreen`, `ScanBookEditScreen`, `ScanTookEditScreen`, `ScanChapterEditScreen` | scan |
| `admin` | `AdminBloc`, `AdminAnalyticsBloc`, `AdminUsersBloc` | `AdminDashScreen` + 5 tabs | admin |

> Catálogos detallados: [es/domain/entities.md](es/domain/entities.md),
> [es/domain/use-cases.md](es/domain/use-cases.md), README por feature en
> [es/features/](es/features/)

### 3.3 Notas estructurales

- `scan/` y `app/` **no tienen capa `domain`/`data`**: reutilizan los casos de
  uso de books/chapters/tooks/genres (ver [es/features/scan/README.md](es/features/scan/README.md)).
- `genres` tiene **dos implementaciones de estado** conviviendo: `GenreBloc`
  (presentation/bloc, usado por app principal y admin) y `GenreCubit`
  (legacy en la raíz de `presentation/`, usado por scan).
- `books/favorites/` es una **subfeature anidada** con su propio
  `domain`/`data`/`presentation`.
- `BookWithRelations` (en `lib/shared/`) es el **tipo con el que trabaja la UI**:
  extiende `BookEntity` y agrega `listGenre`, `listTook` y `listLabel` hidratadas.
  `BookModel` (data) extiende a `BookWithRelations`.

## 4. Bootstrap, DI y arranque

**`lib/main.dart`** (orden de arranque):

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `initializeBackend()` → resuelve las credenciales (`.env`, o `--dart-define`)
   e inicializa el SDK del backend
3. `setupDependencies()` → registra todo en GetIt
4. `SystemChrome` → modo inmersivo (`immersiveSticky`)
5. `runApp(App())`

**`lib/bootstrap/injection.dart`** define el `GetIt` global y `setupDependencies()`,
que ejecuta `_registerCore()` — que llama a `registerBackendDependencies()` (ata los
tres ports de backend a los adaptadores del backend actual) y registra
`CoverUrlService` — y luego los 10 `initXxxDependencies()` por feature. El vendor
solo se nombra dentro de `lib/core/backend/`. Convenciones:

- Repositorios y casos de uso → `registerLazySingleton`
- Blocs → `registerFactory` (estado fresco por pantalla)

**`lib/bootstrap/app.dart`** es el widget raíz `App`: `MultiBlocProvider` con
`ThemeBloc` + `AuthBloc` → `BlocBuilder<ThemeBloc>` construye la `MaterialApp`
(tema claro/oscuro vía Material 3, oscuro por defecto) con un
`BlocListener<AuthBloc>` en el `builder` que hace **navegación reactiva por rol**.

### Navegación y routing

- `home`: `SplashScreen` (timer de ~5 s; `SplashScreen.isReady` habilita la
  navegación por auth).
- **2 rutas nombradas**: `'/label-management'` → `LabelManagementScreen`,
  `'/admin'` → `AdminDashScreen`.
- **Redirección por rol** en el listener de `AuthBloc`
  (`pushAndRemoveUntil` sobre `navigatorKey`):
  `admin` → `AdminDashScreen`, `scan` → `ScanMainScreen`, `user` →
  `MainScreen`; `suspended` / sin rol → `LoginScreen`. `AuthError` → SnackBar.
- El resto de la navegación es **imperativa** (`Navigator.push` /
  `MaterialPageRoute` / transiciones `PageRouteBuilder` de 1 s hacia `BookScreen`).
  No se usa `go_router`.

> Detalle: [es/architecture/routing.md](es/architecture/routing.md)

## 5. Capa de datos — Supabase

Backend en el proyecto Supabase `Noveles`
(ref `xozqqjcuuesxcqwhillr`). La app se conecta con la API de cliente
(`supabase_flutter`) usando URL + anon key desde `.env`.

### 5.1 Esquema (13 tablas)

```text
auth.users (Supabase Auth)
   │ 1─1
profiles (role: user|scan|admin|suspended)
   │
   │ 1─N            N─N ── books_genres ── N─N
authors ──1─N── books ──┬─ N─N ── books_labels ── N─N ── labels
                        │
                        └─ 1─N ── tooks ── 1─N ── chapters
                          (libro → tomos → capítulos)

Registros de actividad / preferencias:
  book_views (analítica de vistas)     → auth.users + books
  chapter_reads (progreso de lectura)  → auth.users + chapters
  user_favorites (favoritos)           → auth.users + books
  label_rules (reglas automáticas)     → labels

Storage buckets: avatars, covers, chapters
```

| Tabla | Propósito | Relaciones clave |
|---|---|---|
| `authors` | Autores de las novelas | 1—N `books.author_id` |
| `books` | Novelas (con `is_visible`, contadores, `created_by`) | N—1 authors, 1—N tooks |
| `books_genres` | N:M libros ↔ géneros | FK `book_id`, `genre_id` |
| `tooks` | Tomos/volúmenes | 1—N `chapters.took_id` |
| `chapters` | Capítulos (`content_type`: `inline` / `storagePath`) | N—1 tooks |
| `genres` | Géneros de clasificación | N—M books (join) |
| `labels` | Etiquetas editoriales con color | N—M books (join) |
| `books_labels` | N:M libros ↔ etiquetas | FK `book_id`, `label_id` |
| `profiles` | Perfil + rol por usuario | 1—1 auth.users |
| `book_views` | Vista de libro (analítica) | N—1 books, users |
| `chapter_reads` | Marcado de capítulo leído | N—1 chapters, users |
| `user_favorites` | Favoritos del lector | N—M books, users |
| `label_rules` | Reglas automáticas de etiquetado | N—1 labels |

### 5.2 Roles y modelo de permisos (RLS)

La autorización se apoya en helpers SQL `SECURITY DEFINER` con
`search_path = ''`: `is_admin()`, `is_scan()`, `is_admin_or_scan()`,
`is_user()`, `is_suspended()`.

| Contenido | Lectura | Escritura |
|---|---|---|
| `books` | Usuarios: solo `is_visible = true`; admin: todos; scan: los propios | `scan` (solo `created_by = auth.uid()`) o `admin` |
| `tooks` / `chapters` | Pública | `scan` (propios) o `admin` |
| `authors` / `genres` / `books_genres` | Pública | Solo admin |
| `labels` / `books_labels` | Pública | Scan y admin |
| `profiles` | Propio; admin: todos; scan: solo el propio (PII) | Propio; admin: todos |
| `user_favorites` / `chapter_reads` | Propias (`auth.uid() = user_id`) | Propias |
| `book_views` | Solo admin | INSERT con `user_id = auth.uid()` |
| `label_rules` | Pública | Solo admin (`FOR ALL`) |

Todas las tablas de contenido tienen una política **RESTRICTIVE**
"Deny suspended users" que bloquea a `suspended`. En Storage, las subidas a
`covers`/`chapters`/`avatars` se limitan a la **carpeta propia** `{user_id}/…`.

> Detalle: [es/database/rls-policies.md](es/database/rls-policies.md)

### 5.3 Funciones y RPC destacados

- Helpers de rol: `is_admin()`, `is_scan()`, `is_admin_or_scan()`, `is_user()`, `is_suspended()`.
- `create_book_with_relations(...)` / `update_book_with_relations(...)` —
  RPC transaccionales que crean/actualizan libro + autor + géneros + etiquetas
  de forma **atómica**, con role-check y `created_by = auth.uid()` forzado.
- Analíticas (admin-only, chequeo interno): `get_analytics_overview()`,
  `get_views_trend(days_back)`, `get_top_books(limit)`,
  `get_most_viewed_books(max_results)`.
- `get_user_recent_views(uid, max_results)` — solo propio o admin (fix IDOR).
- Triggers: `handle_new_user` (crea `profiles` al registrarse),
  `update_label_rules_updated_at`.

> Catálogo completo: [es/database/sql-functions.md](es/database/sql-functions.md)

### 5.4 Migraciones y Edge Functions

- **42 migraciones** en `supabase/migrations/` (2026-05-14 → 2026-07-27) que
  construyen el esquema, los roles (evolución `admin` → `scan` → `admin` +
  `suspended`), RLS, storage y las 5 fases de **hardening de seguridad**
  (2026-07-27): revoke de `EXECUTE` a `anon`, `search_path=''`, fix de IDOR,
  PII en profiles, políticas anti-suspendidos.
- **1 Edge Function** (Deno): `supabase/functions/sync-labels/` — evalúa las
  `label_rules` contra `books`, `book_views` y `user_favorites` y sincroniza
  `books_labels` (tipos `new_release`, `most_read`, `most_popular`,
  `most_favorited`).
- Seed: `supabase/seed.sql` (6 autores, 20 géneros, 7 libros, 6 tomos, ~148
  capítulos y perfil `admin@noveles.com`).

> Detalle: [es/database/README.md](es/database/README.md),
> [es/database/tables.md](es/database/tables.md), [es/database/storage.md](es/database/storage.md)

### 5.5 Repositorios que consumen Supabase

| Repositorio (`data/`) | Tablas / RPC / Storage que usa |
|---|---|
| `book_repository_impl.dart` | `books` + joins (authors, genres, labels, tooks→chapters), RPC `create/update_book_with_relations`, `get_user_recent_views`, `get_most_viewed_books`, `book_views`, bucket `covers` |
| `favorite_repository_impl.dart` | `user_favorites`, `books` |
| `took_repository_impl.dart` | `tooks` + `chapters` |
| `chapter_repository_impl.dart` | `chapters`, `chapter_reads`, bucket `chapters` + **caché local 7 días** (`chapter_cache.dart`) |
| `genre_repository_impl.dart` | `genres` |
| `label_repository_impl.dart` | `labels`, `books_labels` |
| `label_rule_repository_impl.dart` | `label_rules` |
| `profiles_repository_impl.dart` | `profiles`, bucket `avatars`, Auth `updateUser` |
| `auth_repository_impl.dart` | Auth API (`signInWithPassword`, `signUp`, `signOut`, `onAuthStateChange`), `profiles` |
| `analytics_repository_impl.dart` | RPC de analíticas |

## 6. Manejo de estado y errores

### Blocs por rol / pantalla

- **Auth (raíz)**: `AuthBloc` mantiene la sesión; sus estados
  (`AuthAuthenticated`, `AuthUnauthenticated`, …) disparan la navegación por rol.
- **Home / lector**: `RecentViewsBloc` (Continuar leyendo) y `PopularViewsBloc`
  (Más vistos) alimentan las secciones de `MainScreen`, junto con
  `SectionNovedades`, `SectionMasVistos`, etc.
- **Lectura**: `ChapterBloc` soporta carga por índice, precarga de capítulos
  adyacentes (`ChapterPreloading`) y ajustes de lectura
  (`ReadingMode { normal, sepia, night }`).
- **Favoritos**: `FavoriteBloc` (toggle, listado, estado por libro).
- **Scan**: 4 blocs (`ScanBook`, `ScanCover`, `ScanChapter`, `ScanTook`) para
  alta/edición de contenido con portadas y archivos.
- **Admin**: `AdminBloc` (libros), `AdminUsersBloc` (roles/suspensión),
  `AdminAnalyticsBloc` (KPIs, tendencia, top libros).

### Patrón `Result<T>`

Todos los casos de uso devuelven `Future<Result<T>>` con `Result` sellado
(`Ok<T>` / `Err<T>`) y una jerarquía de `Failure` por feature
(`AuthFailure`, `BookFailure`, `ChapterFailure`, `StorageFailure`, …). Los blocs
mapean `Result` a estados `Loading`/`Loaded`/`Error`. No se usan excepciones
para control de flujo.

> Detalle: [es/architecture/error-handling.md](es/architecture/error-handling.md)

## 7. Seguridad (post-auditoría)

Auditoría de seguridad (2026-07) con **31 hallazgos** (3 CRITICAL, 7 HIGH,
8 MEDIUM, 8 LOW, 5 INFO), remediados en **5 fases** desplegadas a Supabase:

1. Lockdown de funciones `SECURITY DEFINER`: `REVOKE EXECUTE … FROM anon`,
   `SET search_path=''`, role-checks internos.
2. Storage: eliminación de políticas demasiado amplias; subida por carpeta propia.
3. Fix de IDOR en `get_user_recent_views`; admin-only en escritura de
   authors/genres/books_genres.
4. PII: scan solo lee su propio perfil; `profiles.email` protegido.
5. Ajustes low: buckets con MIME/tamaño máximo, limpieza de extensiones.

Los RPC transaccionales reescritos fuerzan `created_by = auth.uid()` y restringen
a scan la edición de libros propios.

> Detalle: [es/security-audit-plan.md](es/security-audit-plan.md)

## 8. Testing

**67 archivos** de test (65 tests + 2 helpers en `test/utils/` y `test/widgets/`),
todos en español, con `mocktail` (mocking) y `bloc_test` (verificación de
estados). La suite está en verde (**506 tests aprobados**; incluye la guardia de
arquitectura que mantiene el SDK del vendor detrás de los ports — ver
[es/testing/README.md](es/testing/README.md)).

| Categoría | Archivos | Ruta |
|---|---|---|
| Tests BLoC | 16 | `test/bloc/` |
| Tests de entidades | 5 | `test/entities/` |
| Tests de repositorios | 9 | `test/repositories/` |
| Tests de casos de uso | 7 | `test/use_cases/` |
| Tests de widgets | 27 (26 tests + helper) | `test/widgets/` |

Comandos:

```bash
flutter test                # toda la suite
flutter test test/bloc/     # categoría
flutter analyze             # análisis estático
```

## 9. Configuración y entorno

- **`.env`** (no versionado) requiere: `SUPABASE_URL` y `SUPABASE_ANON_KEY`
  (clave *publishable*; nunca commitear la `service_role`).
- Config local de Supabase en `supabase/config.toml` (API :54321, DB :54322,
  Studio :54323). Setup: ver [es/guides/getting-started.md](es/guides/getting-started.md).
- Análisis estático con `flutter_lints` (`analysis_options.yaml`), sin reglas
  personalizadas salvo `unintended_html_in_doc_comment: ignore`.
- **Sin CI/CD configurado** (no hay `.github/`). Builds: ver
  [es/guides/deployment.md](es/guides/deployment.md).

## 10. Estado del repo y convenciones

- **Rama**: `main`. Sin cambios sin commitear (solo `.commandcode/`, local).
- **Commits**: Conventional Commits con scope (`fix(auth):`, `feat(ui):`,
  `docs(es): …`). Actividad reciente: remediación de tests (cleanup de
  `bloc.close()`, `tearDown` con unregister de mocks, checks de `mounted`).
- **Documentación**: bilingüe ES/EN espejada (`docs/es` ↔ `docs/en`), con
  voseo rioplatense en ES y "Última verificación" al pie. Las features
  absorbidas dejan README de redirección.
- **OpenSpec**: `openspec/specs/` (10 specs activas) y `openspec/changes/`
  (cambios activos + `archive/`), ciclo proposal → design → tasks → verify.
- **Licencia**: proyecto privado — todos los derechos reservados.

## 11. Índice de referencias

| Tema | Documento |
|---|---|
| Inicio rápido | [es/guides/getting-started.md](es/guides/getting-started.md) |
| Arquitectura | [es/architecture/overview.md](es/architecture/overview.md) |
| Entidades | [es/domain/entities.md](es/domain/entities.md) |
| Casos de uso | [es/domain/use-cases.md](es/domain/use-cases.md) |
| Base de datos (tablas, RLS, funciones, storage) | [es/database/README.md](es/database/README.md) |
| Testing | [es/testing/README.md](es/testing/README.md) |
| Roles de usuario | [es/user-types/](es/user-types/) |
| README extenso | [README.es.md](README.es.md) |

---

> Última verificación: 2026-09-05
