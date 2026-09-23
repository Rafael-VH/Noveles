# Auditoría completa del proyecto Noveles

Fecha: Tue Sep 22 2026  
HEAD: 313e3941de74e3d33aa73bc3850630c557a39773  
Branch: main  
Stack: Flutter (Dart 3.3.4+) + BLoC + GetIt + Supabase (Flutter SDK)

## 1. Resumen ejecutivo

Noveles es una aplicación móvil (Flutter) para lectura de novelas web con backend gestionado en Supabase (Postgres + RLS + Auth + Storage). El proyecto implementa una separación explícita entre dominios (ports/gateways) y adaptadores Supabase, siguiendo un estilo orientado a Clean Architecture a nivel de capas (domain/data/presentation) dentro de cada feature.

La arquitectura cliente está desacoplada del vendor: los feature repositories dependen de `DataGateway`/`AuthGateway`/`StorageGateway` (ports en `lib/core/backend/`) y las implementaciones concretas viven en `lib/core/backend/supabase/*`. Esto se verifica en los tests de arquitectura existentes (`test/architecture/backend_seam_test.dart`, `test/architecture/diagrams_guard_test.dart`).

Ya existen 6 diagramas interactivos Archify en `docs/diagramas/` (architecture, supabase, pipeline, secuencia-clave, ciclo-de-vida, roles-interaccion). La auditoría mapea módulos, backend, tests y documenta qué cubren y qué huecos dejan, proponiendo candidatos a nuevos diagramas interactivos para complementar (no duplicar) ese conjunto, siguiendo el criterio de `archify-suite`.

Estado general: proyecto maduro con buena separación de capas, cobertura razonable (tests por feature: blocs, repositories, use cases, widgets), y fuerte énfasis en seguridad (RLS fina por rol, políticas restrictivas, migraciones con hardening). Existen áreas sin diagrama explícito (favoritos/recientes, analytics, paneles admin, flujo de labels, edición de capítulos/portadas, ciclo de lectura/book_views, RPCs).

## 2. Stack y arquitectura general

### 2.1 Dependencias (pubspec.yaml)
- Flutter SDK ^3.3.4
- State management: `bloc ^8.1.4`, `flutter_bloc ^8.1.6`, `equatable ^2.0.5`
- DI: `get_it ^7.6.0`
- Backend: `supabase_flutter ^2.10.0`
- UI: `carousel_slider ^5.1.2`, `cached_network_image ^3.4.1`
- Persistencia/otros: `shared_preferences ^2.2.2`, `image_picker ^1.1.2`, `file_picker ^8.0.0`, `path_provider ^2.1.4`, `flutter_native_splash ^2.4.1`, `flutter_dotenv ^6.0.1`, `url_launcher ^6.3.1`
- Dev: `flutter_test`, `flutter_lints ^5.0.0`, `mocktail ^1.0.4`, `bloc_test ^9.1.7`

### 2.2 Bootstrap y backend seam (Ports & Adapters)
- `lib/main.dart`: inicializa backend (`initializeBackend()`), registra DI (`setupDependencies()`), configura UI overlay, corre `App()`.
- `lib/bootstrap/injection.dart`: registro de dependencias (incluye `registerBackendDependencies(getIt)` y registros por feature: auth, books, chapters, tooks, scan, genres, labels, profiles, admin, app).
- `lib/bootstrap/app.dart`: `MaterialApp` con `navigatorKey`, `ThemeBloc`, `AuthBloc` (provider), guards por ruta (`/admin`, `/label-management`) y listener para navegación según `AuthState`. Home via `_homeFor(AuthState)` (admin/scan/user/login). Role guards en onGenerateRoute leen `AuthBloc.state`.
- `lib/core/backend/`: ports (`auth_gateway.dart`, `auth_identity.dart`, `data_gateway.dart`, `storage_gateway.dart`). `DataGateway` define aggregates nombrados para evitar leak de sintaxis backend.
- `lib/core/backend/supabase/`: adaptadores (`supabase_config.dart`, `supabase_auth_gateway.dart`, `supabase_data_gateway.dart`, `supabase_storage_gateway.dart`, `backend_module.dart`).

Features no conocen Supabase. Backend vendor confinado a `lib/core/backend/supabase/`.

## 3. Mapa de features (lib/features/*)

10 features: `admin`, `app`, `auth`, `books`, `chapters`, `genres`, `labels`, `profiles`, `scan`, `tooks`.

### 3.1 auth
- Domain: `entities/auth_event.dart`, `repositories/auth_repository.dart`, use cases (`login.dart`, `logout.dart`, `register.dart`, `listen_auth_state.dart`, `get_current_user.dart`), exports en `domain/auth.dart`.
- Data: `auth_repository_impl.dart`, modelo/exports en `data/auth.dart`.
- Presentation: BLoC (`auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`), screens (`login_screen.dart`, `register_screen.dart`, `suspended_screen.dart`).
- DI: `di/injection_auth.dart`.

Responsabilidad: autenticación Supabase Auth, estado de auth (listenAuthState), rol desde profiles (AuthUser mapea role).

### 3.2 books
- Domain: `book_entity.dart`, `book_repository.dart`, use cases/ops (`create_book.dart`, `update_book.dart`, `delete_book.dart`, `get_book.dart`, `get_book_by_id.dart`, `get_books_by_genre.dart`, `track_book_view.dart`, `toggle_book_visibility.dart`, `get_recent_views.dart`, `get_most_viewed_books.dart`, `get_book_labels.dart`, `upload_image.dart`, utils `text_stats.dart`, barrel `books.dart`).
- Data: `book_repository_impl.dart`, `book_model.dart`, barrel `data/books.dart`.
- Presentation: BLoC (`book_bloc.dart`, `book_event.dart`, `book_state.dart`), screen `book_screen.dart`, widgets (`sliver_app_bar_book.dart`, `book_view_tracker.dart`, `book_took_list.dart`, `book_quick_stats_bar.dart`, `book_metadata_grid.dart`, `book_detail_content.dart`, `book_action_bar.dart`, `card_info_detail.dart`).
- Favorites (subfeature): domain (`favorite_entity.dart`, `favorite_repository.dart`, use cases `toggle_favorite_use_case.dart`, `is_favorite_use_case.dart`, `get_favorites_use_case.dart`), data (`favorite_repository_impl.dart`), presentation (`favorite_bloc*`, widget `favorite_button.dart`, screen `favorites_screen.dart`).
- DI: `di/injection_books.dart`.

Responsabilidad: CRUD de libros, visibilidad, views, labels, favoritos (por usuario).

### 3.3 tooks
- Domain: `took_entity.dart`, `took_repository.dart`, use cases (`create_took.dart`, `delete_took.dart`, `update_took.dart`, `get_tooks_by_book.dart`, `get_took.dart`), barrels `tooks.dart`.
- Data: `took_repository_impl.dart`, `took_model.dart`.
- Presentation: BLoC (`took_bloc.dart`, `took_event.dart`, `took_state.dart`), screens/widgets relacionados.
- DI: `di/injection_tooks.dart`.

Responsabilidad: volúmenes (tooks) dentro de un libro.

### 3.4 chapters
- Domain: `chapter_entity.dart`, `chapter_repository.dart`, use cases (`create_chapter.dart`, `update_chapter.dart`, `delete_chapter.dart`, `get_chapter.dart`, `get_chapters_by_took.dart`, `get_chapter_content.dart`, `upload_chapter_content.dart`, `get_read_chapter_ids.dart`, `mark_chapter_as_read.dart`, `remove_chapter_cover.dart`, `upload_chapter_cover.dart`, `delete_chapter_files.dart`), barrels `chapters.dart`.
- Data: `chapter_repository_impl.dart`, `chapter_model.dart`, `chapter_cache.dart`.
- Presentation: BLoC (`chapter_bloc.dart`, `chapter_event.dart`, `chapter_state.dart`), screen `chapter_screen_read.dart`, widgets (incluye lectura).
- DI: `di/injection_chapters.dart`.

Responsabilidad: capítulos, contenido (.md/.txt subido a Storage), lecturas marcadas por usuario, portadas opcionales.

### 3.5 scan (panel de escaneo/ingesta)
- Domain: use cases CRUD por rol scan (`create_book_scan.dart`, `update_book_scan.dart`, `create_took_scan.dart`, `update_took_scan.dart`, `create_chapter_scan.dart`, `update_chapter_scan.dart`, `delete_chapter_scan.dart`, `upload_chapter_content_scan.dart`, `upload_chapter_cover_scan.dart`, `remove_chapter_cover_scan.dart`), repos relacionados y entities compartidos.
- Data: repos impl para scan (orquesta con chapters/books/tooks).
- Presentation: BLoC (`scan_book_bloc*`, `scan_took_bloc*`, `scan_chapter_bloc*`, `scan_cover_bloc*`), screens (`scan_main_screen.dart`, `scan_book_form_screen.dart`, `scan_took_form_screen.dart`, `scan_chapter_edit_screen.dart`, `scan_chapter_form_screen.dart`, `scan_chapters_list_screen.dart`), widgets relacionados.
- DI: `di/injection_scan.dart`.

Responsabilidad: flujo de ingesta para rol `scan` (subida de archivo a Storage bucket `chapters`, guardar URL/contenido, CRUD propio por `created_by`).

### 3.6 app (home/sections/views)
- Presentation: BLoC `popular_views/*`, `recent_views/*`, screens `main_screen.dart`, `splash_screen.dart`, secciones/widgets.
- Responsabilidad: home (novedades, populares, recientes, géneros), vistas recientes/populares.

### 3.7 admin
- Domain: use cases `get_all_profiles.dart`, `update_user_role.dart`, `suspend_user.dart`, `unsuspend_user.dart`, `get_admin_stats.dart`, `get_system_stats.dart`, `get_top_viewed_books.dart`, `get_top_users_by_views.dart`, repos (`admin_repository.dart`).
- Data: `admin_repository_impl.dart`.
- Presentation: BLoC (`admin_bloc*`, `admin_users_bloc*`, `admin_analytics_bloc*`), screens (`admin_dash_screen.dart`, `admin_users_screen.dart`, `admin_analytics_screen.dart`, `admin_main_screen.dart`).
- DI: `di/injection_admin.dart`.

Responsabilidad: gestión de usuarios (roles), suspensión/reactivación, analytics.

### 3.8 profiles
- Domain: `user_role.dart`, `profile_entity.dart`, `profile_repository.dart`, use cases (`get_profile.dart`, `get_current_profile.dart`, `update_profile.dart`).
- Data: `profile_repository_impl.dart`, `profile_model.dart`.
- Presentation: BLoC `profile_bloc*`.
- DI: `di/injection_profiles.dart`.

Responsabilidad: perfil de usuario, mapeo rol (enum `UserRole`: user, scan, admin, suspended). Helper `is_user()` existe.

### 3.9 genres
- Domain: `genre_entity.dart`, `genre_repository.dart`, use case `get_all_genres.dart`.
- Data: `genre_repository_impl.dart`, `genre_model.dart`.
- Presentation: BLoC `genre_bloc*`, Cubit `genre_cubit*`.
- DI: `di/injection_genres.dart`.

### 3.10 labels
- Domain: `label_entity.dart`, `label_repository.dart`, use cases CRUD/gestión, barrel `labels.dart`.
- Data: `label_repository_impl.dart`, `label_model.dart`.
- Presentation: BLoC `label_bloc*`, screen `label_management_screen.dart`.
- DI: `di/injection_labels.dart`.

Responsabilidad: etiquetas personalizadas (asociación book-labels).

## 4. Núcleo cross-cutting (lib/core)
- `constants/`: `app_constants.dart`, `storage_constants.dart`, `theme_constants.dart`, `user_role_constants.dart`.
- `cover/`: utilidades de portada (`book_cover_utils.dart`).
- `errors/`: `app_exception.dart`, `error_mapper.dart`, `exceptions.dart`, `failure.dart`, `result.dart`.
- `presentation/`: `app_notification.dart`, `notification_listener.dart`, `notification_service.dart`, blocs (`theme_bloc*`), delegates, widgets compartidos.
- `utils/`: helpers (`context_extensions.dart`, `date_formatters.dart`, `html_utils.dart`, `image_utils.dart`, `navigation_utils.dart`, `responsive_utils.dart`, `string_utils.dart`, `url_utils.dart`).
- `backend/`: ports + supabase adaptadores.

## 5. Backend Supabase

Migraciones en `supabase/migrations/` (48 archivos). Destacan elementos clave:
- Schema inicial + autores, constraints (`20260514220000_initial_schema.sql`, `20260515000000_authors_and_constraints.sql`).
- Profiles/Auth: `profiles_and_auth.sql`, `profiles_extended.sql`, `add_email_to_profiles.sql` (20260723041644).
- Storage: `storage_migration.sql`, `storage_authenticated_upload.sql`, buckets y RLS, fixes (`20260515235000_fix_storage_buckets.sql`, `20260720223740_fix_storage_rls_ownership.sql`, `20260617153406_fix_chapters_storage_rls.sql`).
- Roles: admin/scan/suspended (múltiples migraciones incluyendo `20260720223821`).
- Labels/label_rules: `labels.sql`, `label_rules.sql` (20260723043750), fixes RLS (20260727151957).
- Favorites: `create_user_favorites.sql` (20260720223802) — tabla `user_favorites` con PK (user_id,book_id), RLS por usuario.
- Analytics/reads: `create_analytics_functions.sql`, `chapter_reads.sql`, `book_relations_rpc.sql`, `add_is_user_helper.sql`.
- Hardening/críticos 2026-07-27: múltiples fixes (security_critical_fix, security_storage_fix, security_authz_fix, security_hardening, security_low_fix).
- Fixes recientes 2026-09-06: `fix_profiles_role_escalation.sql`, `fix_public_most_viewed_books.sql`, `enforce_suspended_all_tables.sql`, `add_performance_indexes.sql`, `refine_profiles_update_grants.sql`, `revoke_security_definer_from_public.sql`.
- Fix RLS: suspended enforcement crea `is_suspended()` SECURITY DEFINER, policies RESTRICTIVE deny suspended en tablas sensibles: books, tooks, chapters, user_favorites, chapter_reads, book_views.
- Storage policy crítica corregida: elimina `"Chapters authenticated all"` (FOR ALL demasiado permisivo) dejando políticas por ownership.

Elementos relevantes:
- Tabla `user_favorites` (user_id UUID FK auth.users CASCADE, book_id INT FK books CASCADE, PK compuesto).
- `profiles` con `role` (text + CHECK) y `email`.
- `label_rules` con RLS corregido (usa `is_admin()`).
- `is_suspended()` SECURITY DEFINER para enforcement global vía policies RESTRICTIVE.
- Funciones/RPCs: analytics, book relations RPC, helpers (`is_user()`).

## 6. Testing
- Unitarios: entidades (`test/entities/*`), utils (`test/utils/backend_mocks.dart`), use cases (`test/use_cases/*`).
- Repositories: `test/repositories/*` (book, auth, took, profiles, label, genre, chapter, chapter_cache, analytics).
- Bloc: `test/bloc/*` amplio (auth, book, chapter, genre, label, profile, recent/popular views, scan blocs, admin blocs).
- Widgets: `test/widgets/*` (screens/secciones/componentes, helpers).
- Arquitectura: `test/architecture/backend_seam_test.dart`, `test/architecture/diagrams_guard_test.dart` (guardia de diagramas HTML/SVG).

## 7. Herramientas y CI
- `tools/build-diagrams.mjs`, `tools/diagram-drift.mjs`, `tools/inject-ui.mjs`, templates.
- `.github/workflows/docs.yml`: valida dashboard actualizado y frescura de diagramas (drift).
- Tests guard: `diagrams_guard_test.dart` verifica afirmaciones en diagramas HTML/SVG (cuenta features, prohíbe afirmaciones desactualizadas).

## 8. Documentación existente
- `docs/es/*`, `docs/en/*`, `docs/diagramas/*` (manifest.json, specs JSON + HTML, PLANes), `docs/index.html`, `docs/404.html`.
- `PLAN-detallado.md`, `PLAN-correccion-arquitectura.md`, feature READMEs (scan, tooks, chapters, etc.).

## 9. Diagramas interactivos actuales (qué cubren, qué NO cubren)

| Diagrama | Tipo (archify) | Qué cubre | Qué hueco deja |
|---|---|---|---|
| architecture | architecture | Cliente Flutter + Ports&Adapters (Data/Auth/Storage gateways), backend seam, inyección. | No detalla favoritos, views recientes/populares, analytics, labels/book_labels, flujo de lectura (chapter_reads/book_views), ni orquestación por subfeatures. |
| supabase | architecture | 13 tablas, RLS por rol, Auth, Storage, Edge Functions (visión backend). | No expone relaciones many-to-many explícitas (user_favorites, books_labels, books_genres) ni funciones RPC (analytics, book_relations) ni políticas RESTRICTIVE suspend ni detalle buckets/paths. |
| pipeline | workflow | Ingesta: archivo → Storage (chapters) → INSERT chapters (RLS is_scan) → lector. | No cubre covers en bucket covers, reintentos detallados, validación, limpieza orphaned (bookContentTree cleanup), edición offline/errores UI. |
| secuencia-clave | sequence | Login + ruteo por rol (auth stream, profiles load/create, routing admin/scan/user). | No muestra logout explícito, expiración token, suspended path detallado, ni flows de registro. |
| ciclo-de-vida | lifecycle | Estados user/scan/admin/suspended, transiciones (promociones, suspend/reactivate). | No vincula estados a acciones permitidas/RLS ni a pantallas/resultados; transición suspend→user/reactivación no queda trazada con actores. |
| roles-interaccion | workflow (swimlanes) | Qué ve/hace cada rol, contraste RLS por lane (is_visible, created_by, is_admin), suspended cae a LoginScreen. | No incluye favoritos, recientes, analytics (admin), gestión de labels/genres, chapter_reads, book_views, ni Storage paths por rol. |

## 10. Candidatos a nuevos diagramas interactivos

Basado en archify-suite (arquitectura, flujo principal, secuencia clave, ciclo de vida, datos). Se priorizan complementar sin duplicar.

| Candidato | Tipo (archify) | Qué representa | Aporta sobre existentes | Fuentes reales (repo) | Esfuerzo (bajo/medio/alto) | Prioridad (alta/media/baja) |
|---|---|---|---|---|---|---|
| favoritos-recientes | workflow | Flujo: toggle favorito, listar favoritos, recent_views (track_book_view + get_recent_views). | No hay diagrama de favoritos ni de vistas recientes. Explica almacenamiento (user_favorites) + tracking. | `lib/features/books/favorites/*`, `lib/features/books/domain/track_book_view.dart`, `lib/features/books/domain/get_recent_views.dart`, `supabase/migrations/20260720223802_create_user_favorites.sql` | bajo | alta |
| book-views-analytics | dataflow | Dataflow lectura/vistas: track_book_view → book_views (tabla implícita por tracking), chapter_reads, agregados analytics. | Completa analytics (admin). Expone fuentes datos para reportes. | `lib/features/books/domain/track_book_view.dart`, `supabase/migrations/20260723041644_*`/`chapter_reads.sql`, `create_analytics_functions.sql`, `admin analytics blocs/repos` | medio | alta |
| admin-users-gestion | workflow | Flujo admin: listar perfiles, cambiar rol, suspender/reactivar (con validaciones). | Detalla caso de uso admin (más allá de lanes generales). Muestra transiciones + efectos. | `lib/features/admin/presentation/bloc/admin_users_bloc*`, `lib/features/admin/domain/use_cases/*`, migraciones role/suspended | bajo | alta |
| labels-asignacion | workflow | Asignación/gestión labels + books_labels, reglas (label_rules). | Roles-interaccion no detalla labels; pipeline/otros tampoco. Muestra CRUD + asociación. | `lib/features/labels/*`, `supabase/migrations/labels.sql`, `label_rules.sql` | bajo | media |
| covers-chapters-storage | dataflow | Flujo covers (bucket covers) vs content (bucket chapters), paths, cleanup orphaned (bookContentTree). | Pipeline solo cubre chapters. Expone separación buckets y cleanup. | chapters upload cover/remove, `bookContentTree` en `DataGateway`, storage migrations/constants | medio | media |
| registro-auth | sequence | Flujo register: signup → profiles creation/triggers, validación, error handling. | secuencia-clave solo cubre login. Caso importante auth. | auth/register use case/bloc/screens, profiles migrations/triggers | bajo | media |
| lectura-capitulo | sequence | Lectura: abrir capítulo, marcar leído (chapter_reads), tracking view, cache contenido. | No hay secuencia de lectura. Conecta UI → repo → cache/storage. | `chapter_screen_read`, `mark_chapter_as_read`, `chapter_cache`, `chapter_reads.sql` | medio | media |
| scan-ingesta-detallada | workflow | Expande pipeline con validaciones, errores, timeouts, covers, tooks/chapter forms. | Complementa pipeline (más granular) sin duplicar. Útil para rol scan. | `lib/features/scan/*`, constants, pipeline existente | medio | baja |
| rpc-analytics | architecture/dataflow | Mapa RPCs (book relations, analytics functions) + cómo repos las consumen. | Supabase backend no detalla RPCs. Útil entender extensiones servidor. | migraciones `*rpc*`, `*analytics_functions*`, `book_relations_rpc.sql` | bajo | baja |

## 11. Recomendaciones generales

- Mantener diagramas sincronizados con código: aprovechar `diagrams_guard_test.dart` y CI (`docs.yml` con drift).
- Priorizar alta: `favoritos-recientes` y `book-views-analytics` (cubren huecos funcionales importantes).
- No duplicar existentes: los candidatos complementan (workflows/sequences/dataflow) vs arquitectura/lifecycle ya cubiertos.
- Verificar rutas fuentes con `archify-drift` (añadir `revision`/`sources` en specs) al entregar nuevos diagramas.
- Destacar separación backend seam (Ports&Adapters) en futuros diagramas — ya está bien documentado.
- Considerar dataflow (archify-suite `datos`) para analytics/views (book_views, chapter_reads) — justificado por tracking ingest+lectura.