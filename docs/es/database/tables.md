# Tablas y Esquema

> Las 12 tablas tienen RLS habilitado.
> Última auditoría: 2026-07-23

## Relación de Entidades

```text
auth.users ──1:1──> profiles
    │
    ├──1:N──> books (created_by)
    │           ├──1:N──> books_genres ──> genres
    │           ├──1:N──> books_labels ──> labels
    │           ├──1:N──> tooks (book_id)
    │           │           └──1:N──> chapters (took_id)
    │           │                           └──1:N──> chapter_reads (chapter_id)
    │           ├──1:N──> book_views (book_id)
    │           └──1:N──> user_favorites (book_id)
    │           └──1:N──> label_rules (label_id)
    │
    ├──1:N──> tooks (created_by)
    ├──1:N──> chapters (created_by)
    │           └──1:N──> chapter_reads (chapter_id)
    ├──1:N──> user_favorites (user_id)
    └──1:N──> chapter_reads (user_id)

authors ──1:N──> books (author_id)
genres ──M:N──> books (via books_genres)
labels ──M:N──> books (via books_labels)
```text

---

## Tabla: `profiles`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | UUID | NO | — | FK → auth.users(id), PK |
| `role` | TEXT | NO | `'user'` | CHECK: user/scan/admin/suspended |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `display_name` | TEXT | SÍ | — | |
| `bio` | TEXT | SÍ | — | |
| `avatar_url` | TEXT | SÍ | — | |

### Mapeo de Código

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| E | user_entity.dart | isUser, isScan, isAdmin, isSuspended |
| Model | `user_model.dart` | Mapeo JSON, `_validateRole()` |
| Repo | profiles_repository.dart | Abstracto: getProfile, getAllProfiles,... |
| Repo Impl | profiles_repository_impl.dart | Llamadas Supabase + avatar store |
| Casos de Uso | `update_user_role.dart` | Admin cambia rol de usuario |
| BLoC | `profile_bloc.dart` | Gestión de estado de perfil |
| BLoC | admin_users_bloc.dart | Gestiona usuarios admin (rol, suspender) |
| Pantalla | `profile_screen.dart` | Ver/editar perfil de usuario |
| Pantalla | `users_tab.dart` | Lista usuarios admin: búsqueda, rol, suspender |
| Pantalla | `register_screen.dart` | Auto-crea perfil mediante trigger |
| Auth | `auth_repository_impl.dart` | `_getProfile()` lee/crea perfil |
| DI | ``profiles`` | Registra ProfilesRepository, UpdateUserRole |
| Migración | `20260515161849_profiles_and_auth.sql` | Crea tabla profiles |
| Migración | add_suspended_role.sql | Agrega 'suspended' al CHECK |
| Función SQL | `handle_new_user()` | Trigger: auto-crea perfil al registrarse |

### Políticas Requeridas

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | User (propio) | El usuario lee su propio perfil |
| SELECT | Admin (todos) | Admin gestiona usuarios |
| SELECT | Scan (todos) | Scan necesita ver nombres de autores |
| INSERT | User (propio) | Trigger crea perfil, usuario puede actualizar |
| UPDATE | User (propio) | Usuario edita display_name, bio, avatar |
| UPDATE | Admin (todos) | Admin cambia roles, suspende usuarios |

---

## Tabla: `books`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | SÍ | `now()` | |
| `cover` | TEXT | NO | — | URL de Storage |
| `name` | TEXT | NO | — | Título del libro |
| `short` | TEXT | SÍ | `''` | Descripción corta |
| `alternative` | TEXT | SÍ | `''` | Título alternativo |
| `description` | TEXT | SÍ | `''` | Descripción completa |
| `country` | TEXT | SÍ | `''` | País de origen |
| `state` | TEXT | SÍ | `''` | Estado/región |
| `type` | TEXT | SÍ | `''` | Tipo de libro |
| `release` | TEXT | SÍ | `''` | Información de lanzamiento |
| `source` | TEXT | SÍ | `''` | URL de origen |
| `link` | TEXT | SÍ | `''` | Enlace externo |
| `is_favorite` | BOOL | SÍ | `false` | Legado — usar user_favorites |
| `author_id` | INT | NO | — | FK → authors(id) |
| `created_by` | UUID | SÍ | — | FK → auth.users(id) |
| `is_visible` | BOOL | NO | `true` | Indicador de visibilidad |
| `took_count` | INT | SÍ | `0` | Conteo desnormalizado |
| `chapter_count` | INT | SÍ | `0` | Conteo desnormalizado |

### Mapeo de Código (Parte 2)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `book_entity.dart` | Modelo de dominio `BookEntity` |
| Modelo | `book_model.dart` | Mapeo JSON con `BookWithRelations` |
| Repo | book_repository.dart | Abstracto: getBooks, getBookById... (9) |
| Repo Impl | book_repository_impl.dart | Llamadas Supabase, limpieza, joins |
| Casos de Uso | `lib/features/books/domain/get_book.dart` | UC `GetBook` |
| Casos de Uso | track_book_view.dart | UC TrackBookView (fire-and-forget) |
| BLoC | `book_bloc.dart` | `LoadBooks`, `LoadMoreBooks` (scroll infinito) |
| BLoC | `admin_bloc.dart` | Admin CRUD + alternar visibilidad |
| BLoC | `scan_book_bloc.dart` | Scan crear/actualizar/eliminar |
| BLoC | `admin_analytics_bloc.dart` | Lee book_views mediante RPC |
| Pantalla | `main_screen.dart` | Lista de libros (vista de usuario) |
| Pantalla | `book_screen.dart` | Detalle de libro + disparador de seguimiento |
| Pantalla | `books_tab.dart` | Gestión de libros admin |
| Pantalla | `analytics_tab.dart` | Panel de analytics |
| Pantalla | `scan_main_screen.dart` | Lista de libros scan |
| Pantalla | `scan_book_edit_screen.dart` | Scan crear/editar libro |
| DI | ``books`` | Registra BookRepository, TrackBookView, BookBloc |
| DI | `injection_admin.dart` | Registra AdminBloc, AnalyticsRepository |
| DI | `lib/features/scan/di/injection_scan.dart` | Registra ScanBookBloc |
| Migración | `20260514220000_initial_schema.sql` | Crea tabla books |
| Migración | fix_books_rls_scan_visibility.sql | Corrige visibilidad scan |

### Políticas Requeridas (Parte 2)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | User (visible) | Usuario lee libros publicados |
| SELECT | Admin (todos) | Admin gestiona todos los libros |
| SELECT | Scan (propios) | Scan lee sus propios libros para editar |
| INSERT | Admin | Admin crea libros |
| INSERT | Scan (propios) | Scan crea libros |
| UPDATE | Admin | Admin edita cualquier libro |
| UPDATE | Scan (propios) | Scan edita sus propios libros |
| DELETE | Admin | Admin elimina cualquier libro |
| DELETE | Scan (propios) | Scan elimina sus propios libros |

---

## Tabla: `authors`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | SÍ | `now()` | |
| `name` | TEXT | NO | — | Nombre del autor |
| `description` | TEXT | SÍ | `''` | |

### Mapeo de Código (Parte 3)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | Lee autores con relaciones |
| Pantalla | `genres_tab.dart` | Gestión admin de géneros/autores |
| Migración | authors_and_constraints.sql | Crea tabla authors |

**Nota**: No hay un `AuthorRepository` dedicado — los autores se gestionan a
través de las pestañas de libros y géneros.

### Políticas Requeridas (Parte 3)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Los autores son datos públicos |
| INSERT | Admin/Scan | Ambos pueden crear autores |
| UPDATE | Admin/Scan | Ambos pueden editar autores |
| DELETE | Admin/Scan | Ambos pueden eliminar autores |

---

## Tabla: `genres`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | INT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | SÍ | `now()` | |
| `name` | TEXT | NO | — | Nombre del género |
| `description` | TEXT | SÍ | `''` | |

### Mapeo de Código (Parte 4)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `genre_entity.dart` | Modelo de dominio `GenreEntity` |
| Repo | genre_repository.dart | Abstracto: getGenres, getGenreById,... |
| Repo Impl | `genre_repository_impl.dart` | Llamadas Supabase |
| BLoC | `genre_bloc.dart` | Gestión de estado de géneros |
| Cubit | `genre_cubit.dart` | Carga de géneros compartida (scan) |
| Pantalla | `genre_screen.dart` | Lista de géneros |
| Pantalla | `genres_tab.dart` | CRUD de géneros admin |
| Pantalla | `main_screen.dart` | Chips de filtro de géneros |
| DI | `injection_genres.dart` | Registra GenreRepository, GenreBloc |
| DI | `lib/features/scan/di/injection_scan.dart` | Registra GenreCubit |
| Migración | `20260514220000_initial_schema.sql` | Crea tabla genres |

### Políticas Requeridas (Parte 4)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Los géneros son datos públicos |
| INSERT | Admin/Scan | Ambos pueden crear géneros |
| UPDATE | Admin/Scan | Ambos pueden editar géneros |
| DELETE | Admin/Scan | Ambos pueden eliminar géneros |

---

## Tabla: `labels`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | BIGINT | NO | identity | PK |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `name` | TEXT | NO | — | Nombre de la etiqueta |
| `color` | TEXT | NO | `'#71A202'` | Color hex |

### Mapeo de Código (Parte 5)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `label_entity.dart` | Modelo de dominio `LabelEntity` |
| Repo | label_repository.dart | Abstracto: getLabels, getLabelById,... |
| Repo Impl | label_repository_impl.dart | Llamadas Supabase para etiquetas |
| BLoC | `label_bloc.dart` | Gestión de estado de etiquetas |
| Pantalla | `genres_tab.dart` | CRUD de etiquetas admin (pestaña compartida) |
| Pantalla | `scan_book_edit_screen.dart` | Scan asigna etiquetas a libros |
| DI | `injection_labels.dart` | Registra LabelRepository, LabelBloc |
| Migración | `20260520020000_labels.sql` | Crea tabla labels |

### Políticas Requeridas (Parte 5)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Las etiquetas son datos públicos |
| INSERT | Admin/Scan | Ambos pueden crear etiquetas |
| UPDATE | Admin/Scan | Ambos pueden editar etiquetas |
| DELETE | Admin/Scan | Ambos pueden eliminar etiquetas |

---

## Tabla: `books_genres` (unión M:N)

| Columna | Tipo | Nulable | Notas |
| ------- | ---- | ------- | ----- |
| `book_id` | INT | NO | FK → books(id) |
| `genre_id` | INT | NO | FK → genres(id) |

**PK**: (book_id, genre_id)

### Mapeo de Código (Parte 6)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | CRUD: insertar/eliminar libros |
| Migración | `20260514220000_initial_schema.sql` | Crea tabla de unión |

### Políticas Requeridas (Parte 6)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Los datos de unión son públicos |
| INSERT | Admin/Scan | Ambos asignan géneros a libros |
| DELETE | Admin/Scan | Ambos eliminan géneros de libros |

---

## Tabla: `books_labels` (unión M:N)

| Columna | Tipo | Nulable | Notas |
| ------- | ---- | ------- | ----- |
| `book_id` | INT | NO | FK → books(id) |
| `label_id` | BIGINT | NO | FK → labels(id) |

**PK**: (book_id, label_id)

### Mapeo de Código (Parte 7)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | Leer etiquetas de libros |
| Repo Impl | `label_repository_impl.dart` | Asignar/eliminar etiquetas libros |
| Migración | `20260520020000_labels.sql` | Crea tabla de unión |

### Políticas Requeridas (Parte 7)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Los datos de unión son públicos |
| INSERT | Admin/Scan | Ambos asignan etiquetas a libros |
| DELETE | Admin/Scan | Ambos eliminan etiquetas de libros |

---

## Tabla: `tooks`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | SÍ | `now()` | |
| `book_id` | INT | NO | — | FK → books(id) |
| `cover` | TEXT | SÍ | `''` | URL de Storage |
| `number` | TEXT | SÍ | `''` | Número de tomo |
| `title` | TEXT | SÍ | `''` | Título del tomo |
| `created_by` | UUID | SÍ | — | FK → auth.users(id) |
| `chapter_count` | INT | SÍ | `0` | Conteo desnormalizado |

### Mapeo de Código (Parte 8)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `took_entity.dart` | Modelo de dominio `TookEntity` |
| Repo | took_repository.dart | Abstracto: getTooks, getTookById,... |
| Repo Impl | `took_repository_impl.dart` | Llamadas Supabase |
| BLoC | `chapter_bloc.dart` | Gestiona tomos + capítulos |
| BLoC | `scan_took_bloc.dart` | Scan CRUD para tomos |
| Pantalla | `book_screen.dart` | Muestra lista de tomos en pestaña "Took" |
| Pantalla | `scan_took_edit_screen.dart` | Scan crear/editar tomo |
| DI | `lib/features/tooks/di/injection_tooks.dart` | Registra TookRepository |
| DI | `lib/features/scan/di/injection_scan.dart` | Registra ScanTookBloc |
| Migración | `20260514220000_initial_schema.sql` | Crea tabla tooks |

### Políticas Requeridas (Parte 8)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | Los metadatos de tomos son públicos |
| INSERT | Admin/Scan (propios) | Scan crea tomos |
| UPDATE | Admin/Scan (propios) | Scan edita sus propios tomos |
| DELETE | Admin/Scan (propios) | Scan elimina sus propios tomos |

---

## Tabla: `chapters`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | INT | NO | nextval | PK |
| `created_at` | TIMESTAMPTZ | SÍ | `now()` | |
| `took_id` | INT | NO | — | FK → tooks(id) |
| `number` | TEXT | SÍ | `''` | Número de capítulo |
| `title` | TEXT | SÍ | `''` | Título del capítulo |
| `content` | TEXT | SÍ | `''` | Contenido del capítulo |
| `created_by` | UUID | SÍ | — | FK → auth.users(id) |

### Mapeo de Código (Parte 9)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `chapter_entity.dart` | Modelo de dominio `ChapterEntity` |
| Repo | chapter_repository.dart | Abstracto: getChapters, getChapterById,... |
| Repo Impl | `chapter_repository_impl.dart` | Llamadas Supabase |
| BLoC | `chapter_bloc.dart` | Gestión de estado de capítulos |
| BLoC | `scan_chapter_bloc.dart` | Scan CRUD para capítulos |
| Pantalla | `chapter_screen.dart` | Lector de capítulos |
| Pantalla | `scan_chapter_edit_screen.dart` | Scan crear/editar capítulo |
| DI | `injection_chapters.dart` | Registra ChapterRepository, ChapterBloc |
| DI | `lib/features/scan/di/injection_scan.dart` | Registra ScanChapterBloc |
| Migración | `20260514220000_initial_schema.sql` | Crea tabla chapters |

### Políticas Requeridas (Parte 9)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos | El contenido de los capítulos es público |
| INSERT | Admin/Scan (propios) | Scan crea capítulos |
| UPDATE | Admin/Scan (propios) | Scan edita sus propios capítulos |
| DELETE | Admin/Scan (propios) | Scan elimina sus propios capítulos |

---

## Tabla: `book_views`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | BIGINT | NO | identity | PK |
| `book_id` | BIGINT | NO | — | FK → books(id) CASCADE |
| `viewed_at` | TIMESTAMPTZ | NO | `now()` | |
| `user_id` | UUID | SÍ | — | FK → auth.users(id) SET NULL |

### Mapeo de Código (Parte 10)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Repo Impl | book_repository_impl.dart | INSERT en book_views |
| Caso de Uso | track_book_view.dart | TrackBookView — fire-and-forget |
| Pantalla | book_screen.dart | Llama a TrackBookView en initState() |
| Repo Impl | `analytics_repository_impl.dart` | Lee mediante funciones RPC |
| BLoC | `admin_analytics_bloc.dart` | Carga datos de analytics |
| Pantalla | `analytics_tab.dart` | Muestra panel de analytics |
| DI | `lib/features/books/di/injection_books.dart` | Registra TrackBookView |
| DI | `lib/features/admin/di/injection_admin.dart` | Registra AnalyticsRepository |
| Migración | `20260523000000_admin_panels.sql` | Crea tabla book_views |
| Migración | audit_fixes_v2.sql | Agrega user_id, relaja política INSERT |
| Migración | create_analytics_functions.sql | Crea funciones SQL analytics |
| Funciones SQL | get_views_trend(),... | Consultas de analytics |

### Políticas Requeridas (Parte 10)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Admin | Solo el admin ve analytics |
| INSERT | Cualquier autenticado | Cualquier usuario registrando una vista |

---

## Tabla: `chapter_reads`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `user_id` | UUID | NO | — | FK → auth.users(id) |
| `chapter_id` | INTEGER | NO | — | FK → chapters(id) |
| `read_at` | TIMESTAMPTZ | NO | `now()` | Cuándo se leyó el capítulo |

**PK**: (user_id, chapter_id)

**RLS**: Habilitado — los usuarios SELECT/INSERT solo sus propias filas.

### Mapeo de Código

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| N/A (solo BD) | — | Sin entidad dominio; se rastrea por repo |
| Repo | `chapter_repository.dart` | `markChapterAsRead`, `getReadChapterIds` |
| Casos de Uso | `mark_chapter_as_read`, `get_read_chapter_ids` | Delega repo |
| Migración | `20260722000000_chapter_reads.sql` | Crea tabla chapter_reads |

### Políticas Requeridas

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | User (propio) | Usuario ve su propio progreso de lectura |
| INSERT | User (propio) | Usuario marca capítulos como leídos |

---

## Tabla: `user_favorites`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `user_id` | UUID | NO | — | FK → auth.users(id) CASCADE |
| `book_id` | INT | NO | — | FK → books(id) CASCADE |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |

**PK**: (user_id, book_id)

### Mapeo de Código (Parte 11)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `favorite_entity.dart` | Modelo de dominio `FavoriteEntity` |
| Repo | favorite_repository.dart | Abstracto: getFavorites, isFavorite,... |
| Repo Impl | `favorite_repository_impl.dart` | Llamadas Supabase |
| BLoC | `favorite_bloc.dart` | Gestión de estado de favoritos |
| Pantalla | `detail_view.dart` | Widget FavoriteButton |
| DI | ``favorites`` | Registra FavoriteRepository, FavoriteBloc |
| Migración | create_user_favorites.sql | Crea tabla user_favorites |

### Políticas Requeridas (Parte 11)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | User (propio) | Usuario ve sus propios favoritos |
| INSERT | User (propio) | Usuario agrega favoritos |
| DELETE | User (propio) | Usuario elimina favoritos |

---

## Tabla: `label_rules`

| Columna | Tipo | Nulable | Por Defecto | Notas |
| ------- | ---- | ------- | ----------- | ----- |
| `id` | BIGINT | NO | identity | PK |
| `label_id` | BIGINT | NO | — | FK → labels(id) ON DELETE CASCADE |
| `rule_type` | TEXT | NO | — | CHECK: new_release / most_read / most_popular |
| `params` | JSONB | NO | `'{}'` | Configuración de regla (días, límite) |
| `created_at` | TIMESTAMPTZ | NO | `now()` | |
| `updated_at` | TIMESTAMPTZ | NO | `now()` | Auto-actualizado por trigger |

### Mapeo de Código (Parte 12)

| Capa | Archivo | Propósito |
| ---- | ------ | --------- |
| Entidad | `label_rule_entity.dart` | `LabelRuleEntity`, enum `LabelRuleType` |
| Modelo | `label_rule_model.dart` | Mapeo JSON |
| Repo | label_rule_repository.dart | Abstracto: getRules, CRUD |
| Repo Impl | label_rule_repository_impl.dart | Llamadas Supabase |
| Casos de Uso | get, create, update, delete rules | Lógica de negocio |
| BLoC | `label_rules_bloc.dart` | Gestión de estado de reglas de etiquetas |
| Pantalla | `label_rules_admin_tab.dart` | UI de pestaña admin |
| DI | `injection_labels.dart` | Registra LRR, 4 casos de uso, LRBloc |
| Edge Function | `sync-labels` | Evaluación del lado del servidor |
| Migración | `20260723043750_label_rules.sql` | Crea tabla label_rules |

### Políticas Requeridas (Parte 12)

| Operación | Rol | Por qué |
| --------- | --- | ------- |
| SELECT | Todos los autenticados | Todos leen reglas (necesario mostrar) |
| ALL | Admin | Admin gestiona reglas de etiquetas (CREATE, UPDATE, DELETE) |

---

## Resumen: Requisitos de Políticas por Rol

### Admin

- **profiles**: SELECT todos, UPDATE todos (cambios de rol)
- **books**: CRUD completo todos
- **authors**: CRUD completo
- **genres**: CRUD completo
- **labels**: CRUD completo
- **books_genres**: CRUD completo
- **books_labels**: CRUD completo
- **tooks**: CRUD completo
- **chapters**: CRUD completo
- **book_views**: solo SELECT (analytics)
- **user_favorites**: Sin acceso (solo usuario)
- **chapter_reads**: Sin acceso (solo admin es responsabilidad del usuario)

### Scan

- **profiles**: SELECT todos (nombres de autores)
- **books**: CRUD propios (created_by = auth.uid())
- **authors**: CRUD completo (recurso compartido)
- **genres**: CRUD completo (recurso compartido)
- **labels**: CRUD completo (recurso compartido)
- **books_genres**: CRUD completo
- **books_labels**: CRUD completo
- **tooks**: CRUD propios (created_by = auth.uid())
- **chapters**: CRUD propios (created_by = auth.uid())
- **book_views**: solo INSERT (seguimiento)
- **user_favorites**: Sin acceso (solo usuario)
- **chapter_reads**: Sin acceso (solo scan es responsabilidad del usuario)

### User

- **profiles**: SELECT/UPDATE propio
- **books**: solo SELECT visibles
- **authors**: solo SELECT
- **genres**: solo SELECT
- **labels**: solo SELECT
- **books_genres**: solo SELECT
- **books_labels**: solo SELECT
- **tooks**: solo SELECT
- **chapters**: solo SELECT
- **book_views**: solo INSERT (seguimiento)
- **user_favorites**: CRUD completo propio
- **chapter_reads**: CRUD completo propio

### Suspended

- **Todas las tablas**: Sin acceso (bloqueado a nivel de routing de la app, no
  RLS)
