# Plan complementario de diagramas interactivos

Fecha: Tue Sep 22 2026  
HEAD: 313e3941de74e3d33aa73bc3850630c557a39773  
Referencia: docs/AUDITORIA-PROYECTO.md (sección 10)

## 1. Objetivo y criterio

- Complementar (no duplicar) los 6 diagramas existentes (architecture, supabase, pipeline, secuencia-clave, ciclo-de-vida, roles-interaccion).
- Criterio: valor/impacto según auditoría; cada diagrama debe responder una pregunta que los actuales NO responden.
- Los nuevos diagramas seguirán el catálogo canónico de `archify-suite` (arquitectura, pipeline/workflow, secuencia, ciclo-de-vida, datos/dataflow) y se agregan como fichas complementarias para cubrir huecos funcionales (favoritos, analytics, admin, labels, covers, registro, lectura, ingesta detallada, RPCs).

## 2. Candidatos priorizados (fases)

### Fase A (prioridad alta)
1. `favoritos-recientes` (workflow)
2. `book-views-analytics` (dataflow)
3. `admin-users-gestion` (workflow)

Justificación Fase A: cubren los huecos funcionales más importantes detectados. Favoritos/recientes son features visibles al usuario (user_favorites + recent_views). Book-views-analytics explica el tracking y fuentes de datos para analytics (book_views/chapter_reads). Admin-users-gestion detalla gestión crítica de roles/suspensión más allá de los lanes generales. Dependencias mínimas entre sí; esfuerzo razonable.

### Fase B (prioridad media)
4. `labels-asignacion` (workflow)
5. `covers-chapters-storage` (dataflow)
6. `registro-auth` (sequence)
7. `lectura-capitulo` (sequence)

Justificación Fase B: completan casos de uso relevantes (labels, storage/covers, registro auth, flujo de lectura). No bloquean Fase A; algunos aprovechan conceptos ya establecidos (auth, storage, chapters).

### Fase C (prioridad baja)
8. `scan-ingesta-detallada` (workflow)
9. `rpc-analytics` (architecture/dataflow)

Justificación Fase C: granularidad mayor o foco en extensiones servidor (RPCs). Complementarios, menor urgencia operativa.

## 3. Fichas de autoría (UNA POR CANDIDATO)

### 3.1 Ficha 1: favoritos-recientes
- **Slug propuesto**: `favoritos-recientes`
- **Tipo archify**: `workflow`
- **Pregunta que responde**: ¿Cómo funciona el toggle de favoritos y el registro/listado de vistas recientes (recent_views) en Noveles?

**Nodos/Lanes**: Lane User (MainScreen/BookScreen/FavoritesScreen), FavoritesBloc/UseCases, FavoriteRepository (domain/data), DataGateway, Supabase (user_favorites), BookRepository/track_book_view, recent_views (BookBloc/App).

**Flujo principal paso a paso**:
1. User abre BookScreen → ve botón favorito.
2. Toggle favorito: FavoriteBloc recibe evento → ToggleFavoriteUseCase → FavoriteRepository.toggleFavorite(userId, bookId) → DataGateway (tabla user_favorites, PK compuesto user_id+book_id) → upsert/delete → retorna Result<bool>.
3. Listar favoritos: GetFavoritesUseCase → FavoriteRepository.getFavorites → carga booksWithRelationsByIds o consulta user_favorites + join → presenta FavoritesScreen.
4. Track vista reciente: BookViewTracker/BookScreen dispara trackBookView → TrackBookView use case → BookRepository.trackBookView() → persiste tracking (book_views implícito) y actualiza recent_views (getRecentViews) → sección Recent Views en MainScreen.
5. Listar recientes: GetRecentViewsUseCase → retorna últimos libros vistos por usuario.

**Cards sugeridas (dot+title+items)**:
- `favoritos-recientes`: "Favoritos y Vistas Recientes" → ["Toggle favorito (user_favorites PK compuesto)", "Listar favoritos", "track_book_view", "GetRecentViews", "RLS por usuario"]

**Fuentes reales del repo**:
- `lib/features/books/favorites/domain/favorite_repository.dart`
- `lib/features/books/favorites/domain/use_cases/toggle_favorite_use_case.dart`, `is_favorite_use_case.dart`, `get_favorites_use_case.dart`
- `lib/features/books/favorites/data/favorite_repository_impl.dart`
- `lib/features/books/favorites/presentation/bloc/*`, `presentation/screens/favorites_screen.dart`, `presentation/widgets/favorite_button.dart`
- `lib/features/books/domain/track_book_view.dart`, `get_recent_views.dart`
- `supabase/migrations/20260720223802_create_user_favorites.sql`

**Hechos que debe reflejar**: tabla `user_favorites` (user_id UUID FK auth.users CASCADE, book_id INT FK books CASCADE, PK (user_id,book_id)), RLS por usuario (auth.uid() = user_id), tracking de vistas recientes, separación use cases/domain/data.

**Trampas conocidas**: no confundir book_views (tracking/analytics) con recent_views (listado UI). PK compuesto en user_favorites.

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: bajo  
**Prioridad**: alta

### 3.2 Ficha 2: book-views-analytics
- **Slug propuesto**: `book-views-analytics`
- **Tipo archify**: `dataflow`
- **Pregunta que responde**: ¿De dónde salen los datos de vistas/lecturas (book_views, chapter_reads) y cómo fluyen hacia analytics?

**Nodos/Participantes**: BookViewTracker/ChapterScreenRead, TrackBookView, BookRepository, DataGateway, Supabase (book_views implícito/tracking, chapter_reads), AdminAnalyticsBloc/Repository, RPCs/analytics functions.

**Flujo principal paso a paso**:
1. Usuario lee capítulo → `chapter_screen_read` marca leído o visualiza.
2. Tracking vista libro: `track_book_view` invocado → BookRepository.trackBookView() persiste evento/registro de vista (relacionado con book_views).
3. Lecturas capítulo: `mark_chapter_as_read` → ChapterRepository → guarda en `chapter_reads` (user_id, chapter_id, read_at).
4. Agregación: Admin analytics consulta datos agregados (get_top_viewed_books, get_top_users_by_views, get_admin_stats/get_system_stats) vía repositorios admin.
5. Funciones servidor: migraciones incluyen `create_analytics_functions.sql`, `book_relations_rpc.sql` para agregados/RPCs.

**Cards sugeridas**:
- `book-views-analytics`: "Vistas y Lecturas → Analytics" → ["track_book_view", "chapter_reads", "book_views", "Agregados admin", "RPCs analytics"]

**Fuentes reales del repo**:
- `lib/features/books/domain/track_book_view.dart`
- `lib/features/chapters/domain/use_cases/mark_chapter_as_read.dart`, `get_read_chapter_ids.dart`
- `lib/features/chapters/data/chapter_repository_impl.dart`
- `lib/features/admin/domain/use_cases/get_top_viewed_books.dart`, `get_top_users_by_views.dart`, `get_admin_stats.dart`, `get_system_stats.dart`
- `lib/features/admin/data/admin_repository_impl.dart`, `presentation/bloc/admin_analytics_bloc*`
- `supabase/migrations/chapter_reads.sql`, `20260723041644_add_email_to_profiles.sql` (contexto), `20260720223843_create_analytics_functions.sql` (nombre migración aproximado en contenido: create_analytics_functions), `20260725172716_create_book_relations_rpc.sql`

**Hechos que debe reflejar**: `chapter_reads` (lecturas por capítulo/usuario), tracking de vistas libro, flujo hacia agregados admin, uso de funciones RPC/analytics, separación tracking vs UI recent_views.

**Trampas conocidas**: book_views no siempre aparece como tabla CRUD explícita en UI — es fuente de agregados/tracking. Diferenciar recent_views (UI) de analytics (agregados).

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: medio  
**Prioridad**: alta

### 3.3 Ficha 3: admin-users-gestion
- **Slug propuesto**: `admin-users-gestion`
- **Tipo archify**: `workflow`
- **Pregunta que responde**: ¿Cómo gestiona un admin usuarios (listar perfiles, cambiar rol, suspender/reactivar)?

**Nodos/Lanes**: Lane Admin, AdminUsersScreen/Bloc, AdminUsersBloc, AdminRepository, UseCases (get_all_profiles, update_user_role, suspend_user, unsuspend_user), DataGateway, Supabase (profiles), AuthState impact.

**Flujo principal paso a paso**:
1. Admin accede a gestión usuarios (AdminDash → AdminUsersScreen).
2. Carga perfiles: GetAllProfilesUseCase → AdminRepository.getAllProfiles() → consulta profiles.
3. Cambiar rol: UpdateUserRoleUseCase → AdminRepository.updateUserRole(userId, role) → actualiza profiles.role (valida permisos admin).
4. Suspender: SuspendUserUseCase → AdminRepository.suspendUser(userId) → set role 'suspended'. Efecto: policies RESTRICTIVE deny suspended aplican; usuario suspendido redirige a Login/SuspendedScreen.
5. Reactivar: UnsuspendUserUseCase → set role a activo (user/scan/admin según política) → reestablece acceso.

**Cards sugeridas**:
- `admin-users-gestion`: "Gestión de Usuarios (Admin)" → ["Listar perfiles", "Cambiar rol", "Suspender", "Reactivar", "Validaciones admin"]

**Fuentes reales del repo**:
- `lib/features/admin/presentation/bloc/admin_users_bloc*` (events/states)
- `lib/features/admin/domain/use_cases/get_all_profiles.dart`, `update_user_role.dart`, `suspend_user.dart`, `unsuspend_user.dart`
- `lib/features/admin/data/admin_repository_impl.dart`, `domain/admin_repository.dart`
- `lib/features/profiles/domain/user_role.dart`, `profile_entity.dart`
- Migraciones roles/suspended: `20260515210000_admin_roles.sql`, `20260520000000_rename_admin_to_scan.sql`, `20260520010000_add_admin_role.sql`, `20260720223821_add_suspended_role.sql`, fixes `20260906004135_fix_profiles_role_escalation.sql`, `20260727151957_security_storage_fix.sql` (enforcement suspended)

**Hechos que debe reflejar**: transiciones role (user↔scan/admin↔suspended), enforcement via suspended (RESTRICTIVE policies), validación permisos admin, efecto en routing/AuthState.

**Trampas conocidas**: suspended no es terminal (recuperable). Reactivación requiere setear rol activo. Prevenir escalación de roles (ver fix migración).

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: bajo  
**Prioridad**: alta

### 3.4 Ficha 4: labels-asignacion
- **Slug propuesto**: `labels-asignacion`
- **Tipo archify**: `workflow`
- **Pregunta que responde**: ¿Cómo se gestionan labels y su asignación a libros (books_labels) con label_rules?

**Nodos/Lanes**: Lane Admin/Scan (según permisos), LabelManagementScreen, LabelBloc, LabelRepository, UseCases (CRUD labels, assign/remove/get book labels), DataGateway, Supabase (labels, books_labels, label_rules).

**Flujo principal paso a paso**:
1. Acceso a gestión: `/label-management` (permitido admin o scan según guard en App).
2. CRUD labels: create/update/delete/getAll → LabelRepository → tabla `labels`.
3. Asociación: assignLabelToBook/removeLabelFromBook → books_labels (relación M:N libro-label).
4. Consultar labels libro: getBookLabels/getBookLabelsList → carga etiquetas asociadas.
5. Reglas: `label_rules` (migración 20260723043750) con RLS corregido (usa `is_admin()` tras fix 20260727151957).

**Cards sugeridas**:
- `labels-asignacion`: "Gestión y Asignación de Labels" → ["CRUD labels", "books_labels (M:N)", "Asignar/remover a libro", "label_rules", "Permisos admin/scan"]

**Fuentes reales del repo**:
- `lib/features/labels/domain/label_entity.dart`, `label_repository.dart`, use cases (create/delete/get_all/update/assign/remove/get_book_labels)
- `lib/features/labels/data/label_repository_impl.dart`, `label_model.dart`
- `lib/features/labels/presentation/bloc/label_bloc*`, `screens/label_management_screen.dart`
- `supabase/migrations/labels.sql`, `20260723043750_label_rules.sql`, `20260727151957_security_storage_fix.sql` (fix label_rules policies)

**Hechos que debe reflejar**: tablas `labels`, `books_labels` (M:N), `label_rules`, permisos (admin/scan pueden gestionar según guard), RLS label_rules corregido.

**Trampas conocidas**: books_labels relación intermedia; políticas label_rules cambiaron (fix función is_admin sin args). Guard ruta permite admin o scan.

**Geometría objetivo**: 1440×900  
**Esfuerzo**: bajo  
**Prioridad**: media

### 3.5 Ficha 5: covers-chapters-storage
- **Slug propuesto**: `covers-chapters-storage`
- **Tipo archify**: `dataflow`
- **Pregunta que responde**: ¿Cómo fluyen covers y contenido de capítulos entre app y Storage (buckets chapters/covers), incluyendo paths y cleanup?

**Nodos/Participantes**: Scan/Books UI, ChapterRepository/Book ops, StorageGateway, Supabase Storage (buckets `chapters`, `covers`), DataGateway (bookContentTree para cleanup), File pickers.

**Flujo principal paso a paso**:
1. Subida contenido capítulo: uploadChapterContent (scan/use cases) → ChapterRepository.uploadContent() → StorageGateway.upload a bucket `chapters` (path/filename según implementación) → guarda URL/público o referencia → persiste en chapters.
2. Subida portada capítulo/libro: uploadChapterCover/uploadImage (covers) → bucket `covers` → guarda URL/cover.
3. Lectura: getChapterContent → recupera contenido (puede ser URL/storage).
4. Cleanup orphaned: delete book/chapter → bookContentTree (DataGateway.bookContentTree) obtiene cover + árbol capítulos/contenido para limpiar objetos Storage huérfanos antes/borrado (patrón visto en DataGateway).
5. Separación buckets: contenido capítulos vs portadas/covers distintos.

**Cards sugeridas**:
- `covers-chapters-storage`: "Storage: Covers vs Chapters + Cleanup" → ["Bucket chapters (contenido)", "Bucket covers (portadas)", "Upload/lectura", "bookContentTree (cleanup orphaned)", "Paths/ownership"]

**Fuentes reales del repo**:
- `lib/features/chapters/domain/use_cases/upload_chapter_content.dart`, `upload_chapter_cover.dart`, `remove_chapter_cover.dart`, `delete_chapter_files.dart`
- `lib/features/chapters/data/chapter_repository_impl.dart`
- `lib/features/books/domain/upload_image.dart`
- `lib/core/backend/storage_gateway.dart`, `supabase/supabase_storage_gateway.dart`
- `lib/core/backend/data_gateway.dart` (bookContentTree), `supabase/supabase_data_gateway.dart` (_bookContentTreeProjection)
- `lib/core/constants/storage_constants.dart`
- Migraciones storage: `20260515200000_storage_migration.sql`, `20260520171320_storage_authenticated_upload.sql`, `20260515235000_fix_storage_buckets.sql`, `20260617153406_fix_chapters_storage_rls.sql`, `20260720223740_fix_storage_rls_ownership.sql`, fixes 2026-07-27

**Hechos que debe reflejar**: buckets separados (chapters vs covers), bookContentTree usado para cleanup objetos huérfanos, RLS ownership en Storage (fixes), paths/filenames, distinción contenido vs portada.

**Trampas conocidas**: pipeline actual cubre solo chapters; covers va a bucket covers. bookContentTree es aggregate nombrado (evita leak backend) usado para limpieza.

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: medio  
**Prioridad**: media

### 3.6 Ficha 6: registro-auth
- **Slug propuesto**: `registro-auth`
- **Tipo archify**: `sequence`
- **Pregunta que responde**: ¿Qué ocurre en el flujo de registro (register) desde UI hasta creación de perfil?

**Nodos/Participantes**: RegisterScreen, AuthBloc, RegisterUseCase, AuthRepository, AuthGateway (Supabase Auth), DataGateway, Supabase (auth.users, profiles), triggers/migraciones perfiles.

**Secuencia paso a paso**:
1. Usuario completa formulario RegisterScreen → AuthBloc emite Register event.
2. RegisterUseCase → AuthRepository.register(email, password, displayName) → AuthGateway.signUp/create user en Supabase Auth.
3. Post-registro: creación/perfilado en `profiles` (migraciones profiles_and_auth, triggers o lógica repositorio). AuthUser mapea role desde profiles.
4. AuthBloc escucha auth state (listenAuthState) → AuthAuthenticated/estado resultante.
5. Routing según rol (user por defecto) → home (_homeFor).

**Cards sugeridas**:
- `registro-auth`: "Flujo de Registro (Auth)" → ["RegisterScreen → AuthBloc", "AuthGateway signUp", "Creación perfil (profiles)", "listenAuthState", "Routing post-registro"]

**Fuentes reales del repo**:
- `lib/features/auth/presentation/screens/register_screen.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`, events/states
- `lib/features/auth/domain/use_cases/register.dart`
- `lib/features/auth/data/auth_repository_impl.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/core/backend/auth_gateway.dart`, `supabase/supabase_auth_gateway.dart`
- Migraciones: `20260515161849_profiles_and_auth.sql`, `20260515170000_profiles_extended.sql`, `20260723041644_add_email_to_profiles.sql`

**Hechos que debe reflejar**: signup via Supabase Auth, sincronización/creación profiles, rol por defecto (user), escucha estado auth (stream), diferencia con login (secuencia-clave existente).

**Trampas conocidas**: secuencia-clave cubre login; este cubre register (complementario). No duplicar segmentos routing salvo necesario.

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: bajo  
**Prioridad**: media

### 3.7 Ficha 7: lectura-capitulo
- **Slug propuesto**: `lectura-capitulo`
- **Tipo archify**: `sequence`
- **Pregunta que responde**: ¿Qué sucede al abrir un capítulo y marcarlo como leído (chapter_reads), con tracking de vista y cache?

**Nodos/Participantes**: ChapterScreenRead (UI), ChapterBloc, GetChapterContent/MarkChapterAsRead, ChapterRepository, ChapterCache, StorageGateway, DataGateway, Supabase (chapters/content, chapter_reads).

**Secuencia paso a paso**:
1. Usuario abre capítulo (desde Book/Took) → ChapterScreenRead inicializa.
2. Carga contenido: GetChapterContentUseCase → ChapterRepository.getChapterContent() → intenta cache (ChapterCache) si existe; sino lee desde Storage/DB → guarda en cache.
3. Marcar leído: MarkChapterAsReadUseCase → ChapterRepository.markChapterAsRead(userId, chapterId) → inserta en `chapter_reads` (user_id, chapter_id, read_at). Idempotente según lógica repo.
4. Tracking vista libro: track_book_view puede dispararse (BookViewTracker) → persiste tracking vista.
5. Render lectura: UI muestra contenido con settings lectura.

**Cards sugeridas**:
- `lectura-capitulo`: "Flujo de Lectura de Capítulo" → ["Abrir capítulo", "Cargar contenido (cache→storage)", "Marcar leído (chapter_reads)", "Track vista libro", "Render UI"]

**Fuentes reales del repo**:
- `lib/features/chapters/presentation/screens/chapter_screen_read.dart`
- `lib/features/chapters/presentation/bloc/chapter_bloc*`
- `lib/features/chapters/domain/use_cases/get_chapter_content.dart`, `mark_chapter_as_read.dart`, `get_read_chapter_ids.dart`
- `lib/features/chapters/data/chapter_repository_impl.dart`, `chapter_cache.dart`
- `lib/features/books/domain/track_book_view.dart`
- `supabase/migrations/chapter_reads.sql`

**Hechos que debe reflejar**: `chapter_reads` (registro lectura usuario), cache contenido (ChapterCache) para evitar re-fetch, separación carga contenido vs marcar leído, tracking vista libro opcional.

**Trampas conocidas**: cache puede evitar fetch Storage; marcar leído es operación por usuario. Diferenciar de analytics agregados.

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: medio  
**Prioridad**: media

### 3.8 Ficha 8: scan-ingesta-detallada
- **Slug propuesto**: `scan-ingesta-detallada`
- **Tipo archify**: `workflow`
- **Pregunta que responde**: ¿Cómo detalla el flujo de ingesta del rol scan (validaciones, errores, timeouts, covers, forms) complementando el pipeline existente?

**Nodos/Lanes**: Lane Scan, ScanMainScreen, ScanBook/Took/Chapter forms, ScanChapterEditScreen, Scan Blocs (Book/Took/Chapter/Cover), Scan use cases, ChapterRepository, StorageGateway, DataGateway, Supabase (books/tooks/chapters, Storage chapters/covers), RLS (is_scan(), created_by).

**Flujo principal paso a paso**:
1. Scan selecciona/crea Book → ScanBookForm → ScanBookBloc → create/update book (scan use cases). Books creados con visibilidad/propiedad según lógica scan.
2. Crea Took → forms + blocs.
3. Crea Capítulo → ScanChapterForm/Edit → selecciona archivo (.md/.txt) en ScanChapterEditScreen.
4. Upload contenido: uploadChapterContentScan → ChapterRepository.uploadContent() → Storage bucket `chapters` (upload). Completer/timeout (10s mencionado en docs existentes) y manejo errores/reintento.
5. Upload cover opcional: uploadChapterCoverScan → bucket `covers`.
6. Persistencia: INSERT chapters con RLS is_scan() y ownership (created_by=auth.uid()).
7. Validaciones/errores UI y cleanup ante fallo.

**Cards sugeridas**:
- `scan-ingesta-detallada`: "Ingesta Detallada (Rol Scan)" → ["Forms Book/Took/Chapter", "Selección archivo", "Upload chapters/covers", "Validaciones/errores", "Timeout/reintento", "RLS is_scan() + created_by"]

**Fuentes reales del repo**:
- `lib/features/scan/presentation/screens/scan_main_screen.dart`, `scan_book_form_screen.dart`, `scan_took_form_screen.dart`, `scan_chapter_edit_screen.dart`, `scan_chapter_form_screen.dart`, `scan_chapters_list_screen.dart`
- `lib/features/scan/presentation/bloc/scan_book_bloc*`, `scan_took_bloc*`, `scan_chapter_bloc*`, `scan_cover_bloc*`
- `lib/features/scan/domain/use_cases/*` (create/update/upload/delete chapter cover/content scan)
- `lib/core/constants/storage_constants.dart`
- Pipeline existente: `docs/diagramas/pipeline/*` (referencia para no duplicar)
- Migraciones RLS: ownership/scan (20260521000000_fix_scan_rls_own_books.sql, etc.)

**Hechos que debe reflejar**: expande pipeline con validaciones, errores, timeout/reintento, covers (bucket covers), forms, ownership (created_by), RLS is_scan(). Complementa pipeline sin duplicarlo.

**Trampas conocidas**: no duplicar pipeline — enfocarse en granularidad (forms, errores, covers, timeouts). Referenciar pipeline existente.

**Geometría objetivo**: 1600×1000  
**Esfuerzo**: medio  
**Prioridad**: baja

### 3.9 Ficha 9: rpc-analytics
- **Slug propuesto**: `rpc-analytics`
- **Tipo archify**: `architecture/dataflow` (híbrido: arquitectura servidor + dataflow consumo)
- **Pregunta que responde**: ¿Qué RPCs y funciones de analytics existen (book_relations, analytics functions) y cómo los consumen los repositorios?

**Nodos/Participantes**: Feature Repos (Books/Admin/Analytics), DataGateway.rpc(), Supabase (Postgres RPCs/functions), Migraciones (book_relations_rpc, analytics_functions), Tablas base (books, tooks, chapters, book_views, chapter_reads).

**Flujo principal paso a paso**:
1. Repositorio necesita datos agregados/relaciones complejas → llama DataGateway.rpc(function, params).
2. Supabase ejecuta función RPC definida en migraciones: `book_relations_rpc.sql` (relaciones libro), `create_analytics_functions.sql` (funciones analytics).
3. Retorna datos agregados → mapeo a entidades/models → UI (Admin analytics, vistas).
4. Helpers: `is_user()` (migración 20260720223717_add_is_user_helper.sql), funciones auxiliares.
5. Seguridad: revisar SECURITY DEFINER/SET search_path según hardening (migraciones security_*).

**Cards sugeridas**:
- `rpc-analytics`: "RPCs y Analytics Functions" → ["DataGateway.rpc()", "book_relations RPC", "Analytics functions", "Repos consumidores (books/admin)", "Seguridad/SECURITY DEFINER"]

**Fuentes reales del repo**:
- `lib/core/backend/data_gateway.dart` (rpc method), `supabase/supabase_data_gateway.dart` (rpc impl)
- `supabase/migrations/20260725172716_create_book_relations_rpc.sql`
- `supabase/migrations/20260720223843_create_analytics_functions.sql` (referenciado)
- `supabase/migrations/20260720223717_add_is_user_helper.sql`
- `supabase/migrations/20260727152112_security_hardening.sql`, `20260906005956_revoke_security_definer_from_public.sql`
- Consumo: `lib/features/admin/data/admin_repository_impl.dart`, `lib/features/books/data/book_repository_impl.dart`

**Hechos que debe reflejar**: mapa RPCs servidor, punto de entrada único via DataGateway.rpc() (no leak vendor fuera backend), funciones book_relations y analytics, consumo por repos admin/books, consideraciones seguridad (SECURITY DEFINER).

**Trampas conocidas**: backend seam mantiene rpc abstraído en DataGateway (port). No documentar SQL interno, solo contrato/consumo y qué función invoca cada caso de uso.

**Geometría objetivo**: 1440×900  
**Esfuerzo**: bajo  
**Prioridad**: baja

## 4. Orden de ejecución y dependencias

**Orden sugerido (por fases):**
- **Fase A primero**: `favoritos-recientes` → `book-views-analytics` → `admin-users-gestion`. Son independientes entre sí; alta prioridad. Book-views-analytics referencia tracking pero no depende de favoritos.

- **Fase B**: `labels-asignacion` → `covers-chapters-storage` → `registro-auth` → `lectura-capitulo`. `covers-chapters-storage` complementa pipeline; `registro-auth` complementa secuencia-clave; `lectura-capitulo` conecta con chapter_reads (ya tocado en Fase A conceptualmente).

- **Fase C**: `scan-ingesta-detallada` → `rpc-analytics`. `scan-ingesta-detallada` referencia pipeline existente (evitar duplicación). `rpc-analytics` depende de comprensión backend (supabase) pero bajo esfuerzo.

**Dependencias clave**: ninguna fuerte (diagramas complementarios). Evitar duplicar existentes: referenciar pipeline/secuencia-clave/ciclo-de-vida/roles-interaccion/architecture/supabase, no rehacerlos.

**Dashboard (archify-diagrams-dashboard)**: al finalizar cada fase (o al cierre completo), regenerar dashboard para incluir los nuevos diagramas en `docs/diagramas/manifest.json` y `docs/index.html`. Tras regeneración, reaplicar inyección UI (`archify-ui-injection`) si corresponde (botón "Volver al dashboard") — recordar que `archify deliver` regenera solo `<slug>.html`, NO `index.html`.

## 5. Criterios de aceptación (estándar del proyecto)

- Cada diagrama: `archify validate` (standard) → 0 errores, 0 warnings.
- `archify deliver` → 9/9 artifact checks en 0 errores.
- `viewBox` contiene la geometría objetivo definida por ficha (1440×900 / 1600×1000 / 1920×1080).
- `index.html` sincronizado con HTML principal + botón "Volver al dashboard" presente (aplicar `archify-ui-injection` tras regenerar dashboard).
- Specs JSON commiteadas junto al HTML (`<slug>/<slug>.json` + `<slug>/index.html`).
- Los hechos verificables de cada ficha están reflejados en el diagrama (no inventar rutas/entidades).
- No duplica diagramas existentes; complementa con pregunta/respuesta distinta.

## 6. Riesgos y trampas transversales

- **deliver vs index.html**: `archify deliver` regenera solo `<slug>.html`, NO `index.html`. El dashboard y botón "Volver" viven en `index.html` → sincronizar/regenerar dashboard (`archify-diagrams-dashboard`) y reaplicar inyección UI tras cada entrega.
- **Botón "Volver" e inyección de UI**: vive solo en `index.html` → reaplicar tras cada regeneración (skill `archify-ui-injection`).
- **Drift (frescura)**: los nuevos diagramas sin `revision`/`sources` quedarán "sin evidencia" (igual que los 4 actuales con ese estado). Se acepta por ahora; al hacerlos auditables por `archify-drift`, añadir `revision` (HEAD) y `sources[].path` por nodo con rutas reales del repo.
- **Encoding UTF-8 en PowerShell**: para inyecciones/operaciones git, usar cmd /c git show + lectura UTF-8, escribir sin BOM.
- **Evitar duplicación**: pipeline/secuencia-clave/ciclo-de-vida/roles-interaccion ya existen. Las fichas complementan (expanden casos específicos) sin rehacerlos.
- **Precisión de fuentes**: usar rutas exactas listadas (lib/, supabase/migrations). No inventar nombres; si algún dato requiere confirmación, marcarlo como "para verificar" en brief.
- **Geometría**: elegir según densidad (workflow con 3 lanes usa 1600×1000; dataflow simple usa 1440×900). Ajustar si diagram crece, respetando rangos objetivo.